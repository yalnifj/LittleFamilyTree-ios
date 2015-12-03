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
    
    init() {
        dataService = DataService.getInstance()
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
    
    func execute(person:LittlePerson, onCompletion: ([HeritagePath]) -> Void ) {
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

        onCompletion(returnPaths)
    }
}
