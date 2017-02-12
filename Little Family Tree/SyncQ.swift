import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class SyncQ : NSObject {
	var syncQ:[LittlePerson]
	var dataService:DataService
	var dbHelper:DBHelper
	var timer:Timer?
    var started = false
    var paused = false
    var pauseDelay = Double(0)
    var authCounter = 0
    var startCounter = 0
    var lastRunTime:Foundation.Date? = nil
	lazy var queue:OperationQueue = {
		var queue = OperationQueue()
		queue.name = "Sync queue"
		queue.maxConcurrentOperationCount = 1
		return queue
    }()
	
	static var instance:SyncQ?
	
	static func getInstance() -> SyncQ {
		if instance == nil {
			instance = SyncQ()
		}
		return instance!
	}
	
	fileprivate override init() {
		syncQ = [LittlePerson]()
		dataService = DataService.getInstance()
		dbHelper = DBHelper.getInstance()
        super.init()
	}
	
	func addToSyncQ(_ person:LittlePerson) {
        var diff = Double(-3700)
        if person.lastSync != nil {
            diff = person.lastSync!.timeIntervalSinceNow
        }
		if diff < -3600 || person.hasParents == nil || person.treeLevel == nil || (person.treeLevel! <= 2 && person.hasChildren == nil) {
			if !syncQ.contains(person) {
                startCounter += 1
				//dbHelper.addToSyncQ(person.id!)
				if person.treeLevel == nil {
					syncQ.append(person)
				}
				else {
					var index = 0
					for i in 0..<syncQ.count {
                        index = i
						if syncQ[i].treeLevel != nil && person.treeLevel < syncQ[i].treeLevel {
							break
						}
					}
					if index < syncQ.count-1 {
						syncQ.insert(person, at:index)
					} else {
						syncQ.append(person)
					}
                    if !started || lastRunTime?.timeIntervalSinceNow < -20 {
                        start()
                    }
				}
			}
		}
	}
    
    func start() {
        if self.timer != nil {
            self.timer!.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(SyncQ.processNextInQ), userInfo: nil, repeats: true)
        started = true
        startCounter = 0
        lastRunTime = Foundation.Date()
        print("SyncQ Timer started")
    }
    
    func pauseForTime(_ delay:Double) {
        paused = true
        pauseDelay = pauseDelay + delay
    }
	
	func processNextInQ() {
        lastRunTime = Foundation.Date()
        if !paused {
            startCounter -= 2
            let date = Foundation.Date()
            print("\(date) Sync Q has \(syncQ.count) people in it.");
            if dataService.remoteService != nil && dataService.remoteService!.sessionId != nil && syncQ.count > 0 {
                let backSync = dataService.dbHelper.getProperty(DataService.PROPERTY_SYNC_BACKGROUND)
                if backSync == nil || backSync == "true" {
                    let person = syncQ.removeFirst()
                    let operation = SyncOperation(person: person, syncQ: self)
                    queue.addOperation(operation)
                } else {
                    print("Sync queue disabled in settings")
                }
            } else {
                //-- if we are not authenticated try to authenticate again after 5 minutes
                authCounter += 1
                if authCounter > 30 {
                    authCounter = 0
                    dataService.autoLogin()
                }
            }
        } else {
            print("SyncQ is paused for \(pauseDelay)")
            pauseDelay -= 10
            if pauseDelay < 0 {
                paused = false
            }
        }
	}
	
	func syncPerson(_ person:LittlePerson, onCompletion: @escaping LittlePersonResponse) {
        self.dataService.remoteService!.getPerson(person.familySearchId!, ignoreCache: true, onCompletion: { fsPerson, err in
            if (fsPerson == nil && err == nil) { //TODO || fsPerson.transientProperty["deleted"] != nil {
                try! self.dbHelper.deletePersonById(person.id!)
                onCompletion(nil, nil)
            } else if fsPerson != nil {
                self.dataService.buildLittlePerson(fsPerson!, onCompletion: { (updated, err2) -> Void in
                    if updated != nil {
                        updated!.id = person.id
                        person.lastSync = updated!.lastSync
                        person.photoPath = updated!.photoPath
                        person.age = updated!.age
                        person.birthDate = updated!.birthDate
                        person.birthPlace = updated!.birthPlace
                        person.alive = updated!.alive
                        person.familySearchId = updated!.familySearchId
                        person.gender = updated!.gender
                        person.givenName = updated!.givenName
                        person.name = updated!.name
                        person.nationality = updated!.nationality
                        person.updateAge()
                        
                        let dqueue = DispatchQueue.global()
                        let group = DispatchGroup()
                        
                        group.enter()
                        //-- sync close relatives
                        self.dataService.remoteService!.getCloseRelatives(person.familySearchId!, onCompletion: { closeRelatives, err in
                            if (closeRelatives != nil && closeRelatives!.count > 0) {
                                let dqueue2 = DispatchQueue.global()
                                let group2 = DispatchGroup()
                                let oldRelations = self.dbHelper.getRelationshipsForPerson(person.id!)
                                var newRelations = [LocalRelationship]()
                                for r in closeRelatives! {
                                    var type = RelationshipType.parentchild
                                    if r.type == "http://gedcomx.org/Couple" {
                                        type = RelationshipType.spouse
                                    }
                                    group2.enter()
                                    self.syncRelationship(r.person1!.resourceId!, fsid2: r.person2!.resourceId!, type: type, onCompletion: { rels, err in
                                        if (rels != nil && rels!.count > 0) {
                                            for rel in rels! {
                                                newRelations.append(rel)
                                            }
                                        }
                                        group2.leave()
                                    })
                                }
                                
                                group2.notify(queue: dqueue2) {
                                    for rel in oldRelations! {
                                        if !newRelations.contains(rel) {
                                            self.dataService.dbHelper.deleteRelationshipById(rel.id);
                                        }
                                    }
                                }
                            } else if err == nil {
                                //-- person no longer has relationships so delete them all
                                let oldRelations = self.dataService.dbHelper.getRelationshipsForPerson(person.id!)
                                if (oldRelations != nil) {
                                    for rel in oldRelations! {
                                        self.dataService.dbHelper.deleteRelationshipById(rel.id)
                                    }
                                }
                                person.hasChildren = false
                                person.hasSpouses = false
                                person.hasParents = false
                                do {
                                    try self.dbHelper.persistLittlePerson(person)
                                } catch {
                                    print("Error persisting little person")
                                }
                            }
                            group.leave()
                        })
                        
                        //-- sync memories
                        group.enter()
                        self.dataService.remoteService!.getPersonMemories(person.familySearchId!, onCompletion: { sds, err in
                            var mediaFound = false
                            if sds != nil {
                                let oldMedia = self.dbHelper.getMediaForPerson(person.id!);
                                var allMedia = [Media]()
                                let dqueue2 = DispatchQueue.global()
                                let group2 = DispatchGroup()
                                for sd in sds! {
                                    var med = self.dbHelper.getMediaByFamilySearchId(sd.id!)
                                    if med == nil {
                                        let links = sd.links
                                        if links.count > 0 {
                                            for link in links {
                                                if (link.rel != nil && link.rel == "image") {
                                                    med = Media()
                                                    med?.type = "photo"
                                                    med?.familySearchId = sd.id
                                                    
                                                    group2.enter()
                                                    self.dataService.remoteService!.downloadImage(link.href!, folderName: person.familySearchId!, fileName: self.dataService.lastPath(link.href! as String), onCompletion: { path, err2 in
                                                        if path != nil {
                                                            med?.localPath = path
                                                            mediaFound = true
                                                            self.dbHelper.persistMedia(med!)
                                                            let tag = Tag()
                                                            tag.mediaId = med!.id
                                                            tag.personId = person.id!
                                                            do {
                                                                try self.dbHelper.persistTag(tag)
                                                            } catch {
                                                                print("Error saving tag")
                                                            }
                                                        }
                                                        group2.leave()
                                                    })
                                                }
                                            }
                                        }
                                    } else {
                                        mediaFound = true;
                                        allMedia.append(med!)
                                    }
                                }
                                
                                group2.notify(queue: dqueue2) {
                                    for m in oldMedia {
                                        if !allMedia.contains(m) {
                                            self.dbHelper.deleteMediaById(m.id)
                                        }
                                    }
                                    
                                    if mediaFound {
                                        if (person.hasMedia == nil || person.hasMedia == false) {
                                            person.hasMedia = true
                                            do {
                                                try self.dbHelper.persistLittlePerson(person)
                                            } catch {
                                                print("Error saving little person")
                                            }
                                        }
                                    } else {
                                        if (person.hasMedia == nil || person.hasMedia == true) {
                                            person.hasMedia = false
                                            do {
                                                try self.dbHelper.persistLittlePerson(person)
                                            } catch {
                                                print("Error saving little person")
                                            }
                                        }
                                    }
                                }
                            }
                            group.leave()
                        })
                        
                        group.notify(queue: dqueue) {
                            onCompletion(person, err2)
                        }
                    }
                })
            } else {
                onCompletion(nil, err)
            }
        })
    }
	
	func syncRelationship(_ fsid1:String, fsid2:String, type:RelationshipType, onCompletion: @escaping LocalRelationshipResponse) {
		dataService.getPersonByRemoteId(fsid1, onCompletion: { person, err in 
			self.dataService.getPersonByRemoteId(fsid2, onCompletion: { relative, err in
				if (person != nil && relative != nil) {
					var personChanged = false;
					var relativeChanged = false;
					var rel = self.dbHelper.getRelationship(person!.id!, id2: relative!.id!, type: type)
					if (rel == nil) {
						rel = LocalRelationship()
						rel!.id1 = person!.id
						rel!.id2 = relative!.id
						rel!.type = type
						self.dbHelper.persistRelationship(rel!);
					}

					if (rel!.type == RelationshipType.spouse) {
						if (person!.hasSpouses == nil || person!.hasSpouses == false) {
							person!.hasSpouses = true
							personChanged = true
						}
						if (relative!.hasSpouses == nil || relative!.hasSpouses == false) {
							relative!.hasSpouses = true
							relativeChanged = true;
						}
						if (person!.treeLevel == nil && relative!.treeLevel != nil) {
							person!.treeLevel = relative!.treeLevel
							personChanged = true
						}
						if (relative!.treeLevel == nil && person!.treeLevel != nil) {
							relative!.treeLevel = person!.treeLevel
							relativeChanged = true;
						}
						if (person!.age == nil && relative!.age != nil) {
							person!.age = relative!.age
							personChanged = true
						}
						if (relative!.age == nil && person!.age != nil) {
							relative!.age = person!.age
							relativeChanged = true
						}
					} else {
						if (person!.hasChildren == nil || person!.hasChildren == false) {
							person!.hasChildren = true
							personChanged = true
						}
						if (person!.treeLevel == nil && relative!.treeLevel != nil) {
							person!.treeLevel = relative!.treeLevel! + 1
							personChanged = true
						}
						if (relative!.age == nil && person!.age != nil) {
							relative!.age = person!.age! - 25
							relativeChanged = true
						}


						if (relative!.hasParents == nil || relative!.hasParents == false) {
							relative!.hasParents = true
							relativeChanged = true
						}
						if (relative!.treeLevel == nil && person!.treeLevel != nil) {
							relative!.treeLevel = person!.treeLevel! - 1
							relativeChanged = true
						}
						if (person!.age == nil && relative!.age != nil) {
							person!.age = relative!.age! + 25
							personChanged = true
						}
					}

					if (personChanged) {
                        do {
                            try self.dbHelper.persistLittlePerson(person!)
                        } catch {
                        }
					}
					if (relativeChanged) {
                        do {
                            try self.dbHelper.persistLittlePerson(relative!)
                        } catch { }
					}
                    
                    onCompletion([rel!], nil)
                    return
				}
                onCompletion([LocalRelationship](), nil)
			})
		})
	}
	
}

class SyncOperation : Operation {
    var person:LittlePerson
    var dataService:DataService
	var syncQ:SyncQ
    
    init(person:LittlePerson, syncQ:SyncQ) {
        self.person = person
		self.syncQ = syncQ
        self.dataService = syncQ.dataService
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        let dbHelper = DBHelper.getInstance()
        //dbHelper.removeFromSyncQ(person.id!)
        
        print("Synchronizing person \(person.id!) \(person.familySearchId!) \(person.treeLevel)")
        
        dataService.remoteService!.getLastChangeForPerson(person.familySearchId!, onCompletion: { timestamp, err in
            if err != nil && err?.code == 401 {
                if self.dataService.remoteService != nil && self.dataService.remoteService!.sessionId != nil {
                    self.dataService.autoLogin()
                    self.syncQ.syncQ.insert(self.person, at: 0)
                }
                return
            }
            if timestamp != nil {
                print("Local date=\(self.person.lastSync?.timeIntervalSince1970) remote date=\(timestamp)")
            }
            if timestamp == nil || self.person.lastSync == nil
                    || timestamp!/1000 > Int64((self.person.lastSync?.timeIntervalSince1970)!) {
                self.syncQ.syncPerson(self.person, onCompletion: {updatedPerson, err in
                    //-- update person's lastsync date
                    if updatedPerson != nil {
                        updatedPerson!.lastSync = Foundation.Date()
                        do {
                            try dbHelper.persistLittlePerson(updatedPerson!)
                        } catch {
                            print("Unable to persist person \(updatedPerson!.id!)")
                        }
                    }
                })
            } else {
                self.person.lastSync = Foundation.Date()
                do {
                    try dbHelper.persistLittlePerson(self.person)
                } catch {
                    print("Unable to persist person \(self.person.id!)")
                }

                //-- force load of family members if we haven't previously loaded them
                //--- allows building the tree in the background
                if self.person.treeLevel < 13 {
                    if (self.person.hasParents == nil) {
                        let dbParents = self.dataService.dbHelper.getParentsForPerson(self.person.id!)
                        if (dbParents == nil || dbParents!.count == 0) {
                            print("SyncThread - Synchronizing parents for \(self.person.id!) \(self.person.familySearchId!)")
                            self.dataService.getParentsFromRemoteService(self.person, onCompletion: { parents, err in
                                if parents != nil && parents!.count > 0 {
                                    for p in parents! {
                                        self.dataService.addToSyncQ(p);
                                    }
                                    self.person.hasParents = true
                                    do {
                                        try dbHelper.persistLittlePerson(self.person)
                                    } catch {
                                        print("Unable to persist person \(self.person.id!)")
                                    }
                                }
                                else if err == nil {
                                    self.person.hasParents = false
                                    do {
                                        try dbHelper.persistLittlePerson(self.person)
                                    } catch {
                                        print("Unable to persist person \(self.person.id!)")
                                    }
                                }
                            })
                        } else {
                            self.person.hasParents = true
                            do {
                                try dbHelper.persistLittlePerson(self.person)
                            } catch {
                                print("Unable to persist person \(self.person.id!)")
                            }
                        }
                    }
                }
                //-- force load descendants of lower levels, picks up aunts, uncles, cousins, grandchildren
                if self.person.treeLevel < 2 {
                    if (self.person.hasChildren == nil) {
                        let dbChildren = self.dataService.dbHelper.getChildrenForPerson(self.person.id!);
                        if (dbChildren == nil || dbChildren!.count == 0) {
                            print("SyncThread - Synchronizing children for \(self.person.id!) \(self.person.familySearchId!)")
                            self.dataService.getChildrenFromRemoteService(self.person, onCompletion: { children, err in
                                if children != nil && children!.count > 0 {
                                    for p in children! {
                                        self.dataService.addToSyncQ(p)
                                    }
                                    self.person.hasChildren = true
                                    do {
                                        try dbHelper.persistLittlePerson(self.person)
                                    } catch {
                                        print("Unable to persist person \(self.person.id!)")
                                    }
                                }
                                else if err == nil {
                                    self.person.hasChildren = false
                                    do {
                                        try dbHelper.persistLittlePerson(self.person)
                                    } catch {
                                        print("Unable to persist person \(self.person.id!)")
                                    }
                                }
                            })
                        } else {
                            self.person.hasChildren = true
                            do {
                                try dbHelper.persistLittlePerson(self.person)
                            } catch {
                                print("Unable to persist person \(self.person.id!)")
                            }
                        }
                    }
                    
                    if (self.person.hasSpouses == nil) {
                        let dbSpouses = self.dataService.dbHelper.getSpousesForPerson(self.person.id!)
                        if (dbSpouses == nil || dbSpouses!.count == 0) {
                            print("SyncThread - Synchronizing spouses for \(self.person.id!) \(self.person.familySearchId!)")
                            self.dataService.getSpousesFromRemoteService(self.person, onCompletion: { spouses, err in
                                if spouses != nil && spouses!.count > 0  {
                                    for p in spouses! {
                                        self.dataService.addToSyncQ(p)
                                    }
                                    self.person.hasSpouses = true
                                    do {
                                        try dbHelper.persistLittlePerson(self.person)
                                    } catch {
                                        print("Unable to persist person \(self.person.id!)")
                                    }
                                } else if err == nil {
                                    self.person.hasSpouses = false
                                    do {
                                        try dbHelper.persistLittlePerson(self.person)
                                    } catch {
                                        print("Unable to persist person \(self.person.id!)")
                                    }
                                }
                            })

                        } else {
                            self.person.hasSpouses = true
                            do {
                                try dbHelper.persistLittlePerson(self.person)
                            } catch {
                                print("Unable to persist person \(self.person.id!)")
                            }
                        }
                    }
                }
            }
        })
    }
}
