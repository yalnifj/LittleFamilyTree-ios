//
//  HeritageCalculator.swift
//  Little Family Tree
//
//  Created by Melissa on 11/27/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class HeritageCalculator {
    static var MAX_PATHS=13
    var dataService:DataService
    var paths:[HeritagePath]
    var cultures:[String:HeritagePath]
    var culturePeople:[String:[LittlePerson]]
    var uniquePaths:[HeritagePath]
    
    init() {
        dataService = DataService.getInstance()
        paths = [HeritagePath]()
        cultures = [String:HeritagePath]()
        culturePeople = [String:[LittlePerson]]()
        uniquePaths = [HeritagePath]()
    }
    
    func canEndPath(path:HeritagePath, origin:String) -> Bool {
        if (path.treePath.count >= HeritageCalculator.MAX_PATHS) { return true; }
        if (path.place == origin) { return false; }
        if (path.place == PlaceHelper.UNKNOWN) { return false; }
        if (path.treePath.count <= 2) { return false; }
        if (origin.caseInsensitiveCompare("united states") == NSComparisonResult.OrderedSame && path.place.caseInsensitiveCompare("canada") == NSComparisonResult.OrderedSame) {
            return false;
        }
        if (origin.caseInsensitiveCompare("canada") == NSComparisonResult.OrderedSame && path.place.caseInsensitiveCompare("united states") == NSComparisonResult.OrderedSame) {
            return false;
        }
        return true;
    }
    
    func execute(person:LittlePerson) {
        var returnPaths = [HeritagePath]()
        var paths = [HeritagePath]()
        var origin = PlaceHelper.getPlaceCountry(person.birthPlace as String?)
        
        let first = HeritagePath(place: origin)
        first.percent = 1.0
        first.treePath.append(person);
        paths.append(first)
        
        while paths.count > 0 {
            let path = paths.removeFirst()
            if (canEndPath(path, origin: origin)) {
                returnPaths.append(path)
            }
            else {
                let pathPerson = path.treePath.last!
                let parents = dataService.dbHelper.getParentsForPerson(pathPerson.id!);
                if (parents != nil && parents!.count > 0) {
                    for parent in parents! {
                        var place = PlaceHelper.getPlaceCountry(parent.birthPlace as String?);
                        //-- sometimes people use nationality as a note, try to ignore those
                        if (parent.nationality != nil && parent.nationality!.length < 80) {
                            place = parent.nationality! as String
                        }
                        let ppath = HeritagePath(place: place)
                        ppath.percent = path.percent / Double(parents!.count)
                        ppath.treePath.append(parent)
                        paths.append(ppath)
                        if (origin == PlaceHelper.UNKNOWN && ppath.place != PlaceHelper.UNKNOWN) {
                            origin = ppath.place
                        }
                    }
                } else {
                    //-- if we don't know if this person has parents, then sync them to pick up the parents next time
                    if (pathPerson.hasParents == nil && path.treePath.count < HeritageCalculator.MAX_PATHS) {
                        dataService.addToSyncQ(pathPerson)
                    }
                    returnPaths.append(path);
                }
            }
        }
        
        for path in returnPaths {
            let lastInPath = path.treePath.last!
            if (lastInPath.hasParents == nil && path.treePath.count < HeritageCalculator.MAX_PATHS) {
                dataService.addToSyncQ(lastInPath);
            }
        }

        self.paths = returnPaths
    }
    
    func mapPaths() {
        for path in self.paths {
            let place = path.place
            if (cultures[place] == nil) {
                cultures[place] = path
                var pl = [LittlePerson]()
                pl.append(path.treePath.last!)
                culturePeople[place] = pl
            } else {
                let percent = cultures[place]!.percent + path.percent
                if (cultures[place]!.treePath.count <= path.treePath.count) {
                    cultures[place]!.percent = percent;
                    culturePeople[place]?.append(path.treePath.last!)
                } else {
                    path.percent = percent
                    cultures[place] = path
                    culturePeople[place]?.insert(path.treePath.last!, atIndex: 0)
                }
            }
        }
        
        uniquePaths.appendContentsOf(cultures.values)
        
    }
}
