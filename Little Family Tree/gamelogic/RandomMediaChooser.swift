//
//  RandomMediaChooser.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class RandomMediaChooser {
    fileprivate static var instance:RandomMediaChooser?
    
    static func getInstance() -> RandomMediaChooser {
        if instance == nil {
            instance = RandomMediaChooser()
        }
        return instance!
    }
    
    var dataService:DataService
    var people:[LittlePerson]
    var familyLoaderQueue:[LittlePerson]
    var selectedPerson:LittlePerson?
    var photo:Media?
    var usedPhotos:[Int64 : Media]
    var noPhotos:[LittlePerson]
    var backgroundLoadIndex = 0
    var counter = 0
    var maxTries = 20
    var maxUsed = 20
    var listener:RandomMediaListener!
    
    fileprivate init() {
        self.dataService = DataService.getInstance()
        self.people = [LittlePerson]()
        self.familyLoaderQueue = [LittlePerson]()
        self.usedPhotos = [Int64 : Media]()
        self.noPhotos = [LittlePerson]()
    }
    
    func addPeople(_ people:[LittlePerson]) {
        for person in people {
            if (!self.people.contains(person)) {
                if (person.hasMedia != nil && person.hasMedia == false) {
                    self.noPhotos.append(person)
                } else {
                    self.people.append(person)
                }
            }
            if (!familyLoaderQueue.contains(person)) {
                familyLoaderQueue.append(person)
            }
        }
    }
    
    func loadRandomImage() {
        counter += 1;
        if (people.count > 0) {
            let r = Int(arc4random_uniform(UInt32(people.count)))
            selectedPerson = people[r]
            dataService.getMediaForPerson(selectedPerson!, onCompletion: { photos, err in
                if (photos.count == 0) {
                    self.people.removeObject(self.selectedPerson!)
                    self.noPhotos.append(self.selectedPerson!)
                    if (self.backgroundLoadIndex < self.maxTries && self.counter < self.maxTries) {
                        self.loadMoreFamilyMembers();
                    } else {
                        self.loadRandomDBImage()
                    }
                } else {
                    var index = Int(arc4random_uniform(UInt32(photos.count)))
                    let origIndex = index;
                    self.photo = photos[index]
                    while (self.usedPhotos[self.photo!.id] != nil) {
                        index += 1;
                        if (index >= photos.count) {
                            index = 0;
                        }
                        self.photo = photos[index]
                        //-- stop if we've used all of these images
                        if (index == origIndex) {
                            self.loadMoreFamilyMembers();
                            return;
                        }
                    }
                    if (self.usedPhotos.count >= self.maxUsed) {
                        self.usedPhotos.dropFirst()
                    }
                    self.usedPhotos[self.photo!.id] = self.photo!

                    self.listener.onMediaLoaded(self.photo!)
                }

            })
        } else {
            loadMoreFamilyMembers()
        }
    }
    
    func loadMoreFamilyMembers() {
        if (familyLoaderQueue.count > 0 && counter < self.maxTries) {
            counter += 1;
            selectedPerson = familyLoaderQueue.removeFirst()
            if (selectedPerson != nil) {
				var loadSpouse = true
				let showStepChildren = dataService.dbHelper.getProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN)
				if showStepChildren != nil && showStepChildren == "false" {
					loadSpouse = false
				}
                dataService.getFamilyMembers(selectedPerson!, loadSpouse: loadSpouse, onCompletion: {peeps, err in
                    if (peeps != nil) {
                        var c = 0
                        for p in peeps! {
                            if (!self.familyLoaderQueue.contains(p)) {
                                self.familyLoaderQueue.append(p)
                            }
                            if (!self.noPhotos.contains(p) && !self.people.contains(p)) {
                                if (p.hasMedia == nil || p.hasMedia == true) {
                                    self.people.append(p)
                                    c += 1
                                }
                                else {
                                    self.noPhotos.append(p)
                                }
                            }
                            self.dataService.addToSyncQ(p)
                        }
                        self.backgroundLoadIndex += 1
                        
                        //-- no pictures try again
                        if (c==0) {
                            self.loadMoreFamilyMembers()
                        } else {
                            self.loadRandomImage();
                        }

                    }
                })
            }
        } else {
            if (people.count > 0 && counter < self.maxTries) {
                loadRandomImage()
            } else {
                self.loadRandomDBImage()
            }
        }
    }
    
    func loadRandomDBImage() {
        let mediaCount = self.dataService.dbHelper.getMediaCount();
        if (mediaCount > 0) {
            self.selectedPerson = self.dataService.dbHelper.getRandomPersonWithMedia()
            if self.selectedPerson != nil {
                let media = self.dataService.dbHelper.getMediaForPerson(self.selectedPerson!.id!)
                var index = Int(arc4random_uniform(UInt32(media.count)))
                let origIndex = index;
                self.photo = media[index]
                while (self.usedPhotos[self.photo!.id] != nil) {
                    index += 1;
                    if (index >= media.count) {
                        index = 0;
                    }
                    self.photo = media[index]
                    //-- stop if we've used all of these images
                    if (index == origIndex) {
                        break;
                    }
                }
                if (self.usedPhotos.count >= self.maxUsed) {
                    self.usedPhotos.dropFirst()
                }
                self.usedPhotos[self.photo!.id] = self.photo!
                
                self.counter = 0;
                self.listener.onMediaLoaded(self.photo!)
            }
            else {
                self.usedPhotos.removeAll()
                self.counter = 0
                self.listener.onMediaLoaded(nil)
            }
            
        } else {
            self.listener.onMediaLoaded(nil)
            self.counter = 0
        }
    }
}

protocol RandomMediaListener {
    func onMediaLoaded(_ media:Media?)
}
