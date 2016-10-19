//
//  HeritageCalculator.swift
//  Little Family Tree
//
//  Created by Melissa on 11/27/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class HeritageCalculator {
    static var MAX_PATHS=12
    var dataService:DataService
    var paths:[HeritagePath]
    var workingPaths = [HeritagePath]()
    var cultures:[String:HeritagePath]
    var culturePeople:[String:[LittlePerson]]
    var uniquePaths:[HeritagePath]
    var listener:CalculatorCompleteListener
    var aCounter = 0
    
    init(listener:CalculatorCompleteListener) {
        dataService = DataService.getInstance()
        paths = [HeritagePath]()
        cultures = [String:HeritagePath]()
        culturePeople = [String:[LittlePerson]]()
        uniquePaths = [HeritagePath]()
        self.listener = listener
    }
    
    func canEndPath(_ path:HeritagePath, origin:String) -> Bool {
        if (path.treePath.count >= HeritageCalculator.MAX_PATHS) { return true; }
        if (path.place == origin) { return false; }
        if (path.place == PlaceHelper.UNKNOWN) { return false; }
        if (path.treePath.count <= 2) { return false; }
        if (origin.caseInsensitiveCompare("united states") == ComparisonResult.orderedSame && path.place.caseInsensitiveCompare("canada") == ComparisonResult.orderedSame) {
            return false;
        }
        if (origin.caseInsensitiveCompare("canada") == ComparisonResult.orderedSame && path.place.caseInsensitiveCompare("united states") == ComparisonResult.orderedSame) {
            return false;
        }
        return true;
    }
    
    func execute(_ person:LittlePerson) {
        let startdate = Foundation.Date()
        self.paths = [HeritagePath]()
        workingPaths = [HeritagePath]()
        var origin = PlaceHelper.getPlaceCountry(person.birthPlace as String?)
        
        let first = HeritagePath(place: origin)
        first.percent = 1.0
        first.treePath.append(person);
        workingPaths.append(first)
        
        while workingPaths.count > 0 {
            let path = workingPaths.removeFirst()
            if (canEndPath(path, origin: origin)) {
                self.paths.append(path)
            }
            else {
                let pathPerson = path.treePath.last!
                let parents = dataService.dbHelper.getParentsForPerson(pathPerson.id!);
                if (parents != nil && parents!.count > 0) {
                    for parent in parents! {
                        let place = PlaceHelper.getPersonCountry(parent)
                        let ppath = HeritagePath(place: place)
                        ppath.percent = path.percent / Double(parents!.count)
                        ppath.treePath.append(contentsOf: path.treePath)
                        ppath.treePath.append(parent)
                        self.workingPaths.append(ppath)
                        if (origin == PlaceHelper.UNKNOWN && ppath.place != PlaceHelper.UNKNOWN) {
                            origin = ppath.place
                        }
                    }
                } else {
                    //-- if we don't know if this person has parents, then sync them to pick up the parents next time
                    if (pathPerson.hasParents == nil && path.treePath.count < HeritageCalculator.MAX_PATHS) {
                        dataService.addToSyncQ(pathPerson)
                    }
                    self.paths.append(path);
                }
            }
        }
    
        for path in self.paths {
            let lastInPath = path.treePath.last!
            if (lastInPath.hasParents == nil && path.treePath.count < HeritageCalculator.MAX_PATHS) {
                self.dataService.addToSyncQ(lastInPath);
            }
        }
        
        let timediff = startdate.timeIntervalSinceNow
        print("Heritage Calculator took \(timediff)")
        
        self.listener.onCalculationComplete()
        
    }
    
    func mapPaths() {
        for path in self.paths {
            let place = path.place.lowercased()
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
                    culturePeople[place]?.insert(path.treePath.last!, at: 0)
                }
            }
        }
        
        uniquePaths.append(contentsOf: cultures.values)
        uniquePaths.sort()
        if (uniquePaths.count > 13) {
            uniquePaths.removeSubrange(14..<uniquePaths.count)
        }
        for path in uniquePaths {
            let lastInPath = path.treePath.last
            if (lastInPath!.hasParents == nil && path.treePath.count < HeritageCalculator.MAX_PATHS) {
                dataService.addToSyncQ(lastInPath!)
            }
        }
    }
}

protocol CalculatorCompleteListener {
    func onCalculationComplete()
}
