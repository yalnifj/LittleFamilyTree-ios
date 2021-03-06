//
//  RelationshipCalculator.swift
//  Little Family Tree
//
//  Created by Melissa on 12/15/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class RelationshipCalculator {
    static func getRelationship(_ me:LittlePerson?, p:LittlePerson?) -> String {
        if (me == nil || p == nil) { return "" }
        if (me == p) { return "You" }
        let dataService = DataService.getInstance()
        if (p!.treeLevel == nil) {
            let children = dataService.dbHelper.getChildrenForPerson(p!.id!)
            if children != nil {
                for c in children! {
                    if c.treeLevel != nil {
                        p!.treeLevel = c.treeLevel! + 1
                        do {
                            try dataService.dbHelper.persistLittlePerson(p!)
                        } catch {
                        }
                        break
                    }
                }
            }
        }
        if (p!.treeLevel != nil && me!.treeLevel != nil) {
            if (p!.treeLevel == me!.treeLevel) {
                let spouses = dataService.dbHelper.getSpousesForPerson(me!.id!)
                if (spouses != nil && spouses!.contains(p!)) {
                    if (p!.gender == GenderType.female) {
                        return "Wife"
                    } else {
                        return "Husband"
                    }
                }
                let parents = dataService.dbHelper.getParentsForPerson(me!.id!)
                if parents != nil {
                    for parent in parents! {
                        let myFamily = dataService.dbHelper.getChildrenForPerson(parent.id!)
                        if myFamily != nil {
                            if (myFamily!.contains(p!)) {
                                if (p!.gender == GenderType.female) {
                                    return "Sister"
                                } else {
                                    return "Brother"
                                }
                            }
                            
                            //-- check for in-laws
                            for bs in myFamily! {
                                if (bs.treeLevel != nil && bs.treeLevel == me!.treeLevel) {
                                    let bsspouses = dataService.dbHelper.getSpousesForPerson(bs.id!)
                                    if (bsspouses != nil && bsspouses!.contains(p!)) {
                                        if (p!.gender == GenderType.female) {
                                            return "Sister in-law"
                                        } else {
                                            return "Brother in-law"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (p!.treeLevel <= 1) {
                    return "Cousin"
                }
                return ""
            }
            if (p!.treeLevel! == me!.treeLevel! - 1) {
                let myFamily = dataService.dbHelper.getRelativesForPerson(me!.id!)
                if myFamily != nil {
                    if (myFamily!.contains(p!)) {
                        if (p!.gender == GenderType.female) {
                            return "Daughter"
                        } else {
                            return "Son"
                        }
                    } else {
                        for c in myFamily! {
                            if (c.treeLevel == p!.treeLevel) {
                                let cspouses = dataService.dbHelper.getSpousesForPerson(c.id!)
                                if (cspouses != nil && cspouses!.contains(p!)) {
                                    if (p!.gender == GenderType.female) {
                                        return "Daughter in-law"
                                    } else {
                                        return "Son in-law"
                                    }
                                }
                            }
                        }
                        if (p!.gender == GenderType.female) {
                            return "Niece"
                        } else {
                            return "Nephew"
                        }
                    }
				}
            }
            if (p!.treeLevel! > me!.treeLevel!) {
                let distance = p!.treeLevel! - me!.treeLevel!
                var rel = getGreatness(distance)
                var d = 0
                var levelPeople = [LittlePerson]()
                levelPeople.append(me!)
                var inLaws = [LittlePerson]()
                let spouses = dataService.dbHelper.getSpousesForPerson(me!.id!)
                if spouses != nil {
                    inLaws.append(contentsOf: spouses!)
                }
                repeat {
                    var nextLevel = [LittlePerson]()
                    for pp in levelPeople {
                        let parents = dataService.dbHelper.getParentsForPerson(pp.id!)
                        if parents != nil {
                            nextLevel.append(contentsOf: parents!)
                        }
                    }
                    levelPeople = nextLevel;
    
                    var nextInLaw = [LittlePerson]()
                    for pp in inLaws {
                        let parents = dataService.dbHelper.getParentsForPerson(pp.id!)
                        if parents != nil {
                            nextInLaw.append(contentsOf: parents!)
                        }
                    }
                    inLaws = nextInLaw
    
                    d += 1
                } while(d < distance)
    
                if (levelPeople.contains(p!)) {
                    if (p!.gender == GenderType.female) {
                        rel += "Mother"
                    } else {
                        rel += "Father"
                    }
                }
                else if (inLaws.contains(p!)) {
                    if (p!.gender == GenderType.female) {
                        rel += "Mother"
                    } else {
                        rel += "Father"
                    }
                    rel += " in-law"
                }
                else {
                    rel = rel.replaceAll("Grand", replace: "Great");
                    if (p!.gender == GenderType.female) {
                        rel += "Aunt"
                    } else {
                        rel += "Uncle"
                    }
                }
                return rel
            }
            if (p!.treeLevel! < me!.treeLevel! - 1) {
                let distance = abs(p!.treeLevel! - me!.treeLevel!)
                var rel = getGreatness(distance)
                if (p!.gender == GenderType.female) {
                    rel += "Daughter"
                } else {
                    rel += "Son"
                }
                return rel
            }
        }
        return ""
    }
    
    static func getGreatness(_ depth:Int) -> String {
        var rel = "";
        if (depth > 4) {
            var great = "\(depth - 2)th"
            switch (depth) {
				case 5:
                    great = "Third"
                    break
				case 6:
                    great = "Fourth"
                    break
				case 7:
                    great = "Fifth"
                    break
				case 8:
                    great = "Sixth"
                    break
				case 9:
                    great = "Seventh"
                    break
				case 10:
                    great = "Eighth"
                    break
				case 11:
                    great = "Nineth"
                    break
				case 12:
                    great = "Tenth"
                    break
				case 13:
                    great = "Eleventh"
                    break
				case 14:
                    great = "Twelvth"
                    break
				case 15:
                    great = "Thirteenth"
                    break
				case 16:
                    great = "Fourteenth"
                    break
                default:
                    great = "Really Old"
                    break
            }
            rel = great + " Great ";
        } else if depth > 2 {
            for _ in 3..<depth+1 {
				rel += "Great "
            }
        }
        if (depth >= 2) {
            rel += "Grand ";
        }
        return rel
    }
    
    static func getAncestralRelationship(_ depth:Int, p:LittlePerson, me:LittlePerson, isRoot:Bool, isChild:Bool, isInLaw:Bool) -> String {
        var rel = getGreatness(depth)
    
        if (p.gender == GenderType.female) {
            if (depth==0) {
                if (isRoot) {
                    if (p==me) { rel = "You" }
                    else { rel = "Wife" }
                } else {
                    if (isChild) { "Daughter" }
                    else { rel = "Sister" }
                }
            } else {
                rel += "Mother"
            }
        }
        else if (p.gender == GenderType.male) {
            if (depth==0) {
                if (isRoot) {
                    if (p==me) { rel = "You" }
                    else { rel = "Husband" }
                } else {
                    if (isChild) { rel = "Son" }
                    else { rel = "Brother" }
                }
            } else {
                rel += "Father"
            }
        } else {
            rel += "Parent"
        }
        if (isInLaw) {
            rel += " in-law"
        }
        return rel
    }
}
