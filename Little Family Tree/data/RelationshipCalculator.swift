//
//  RelationshipCalculator.swift
//  Little Family Tree
//
//  Created by Melissa on 12/15/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class RelationshipCalculator {
    static func getRelationship(me:LittlePerson?, p:LittlePerson?) -> String {
        if (me == nil || p == nil) { return "" }
        if (me == p) { return "You" }
        if (p!.treeLevel != nil && me!.treeLevel != nil) {
            let dataService = DataService.getInstance()
            if (p!.treeLevel == me!.treeLevel) {
                let spouses = dataService.dbHelper.getSpousesForPerson(me!.id!)
                if (spouses != nil && spouses!.contains(p!)) {
                    if (p!.gender == GenderType.FEMALE) {
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
                                if (p!.gender == GenderType.FEMALE) {
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
                                        if (p!.gender == GenderType.FEMALE) {
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
                let myFamily = dataService.dbHelper.getRelativesForPerson(me!.id!, followSpouse: false)
                if myFamily != nil {
                    if (myFamily!.contains(p!)) {
                        if (p!.gender == GenderType.FEMALE) {
                            return "Daughter"
                        } else {
                            return "Son"
                        }
                    } else {
                        for c in myFamily! {
                            if (c.treeLevel == p!.treeLevel) {
                                let cspouses = dataService.dbHelper.getSpousesForPerson(c.id!)
                                if (cspouses != nil && cspouses!.contains(p!)) {
                                    if (p!.gender == GenderType.FEMALE) {
                                        return "Daughter in-law"
                                    } else {
                                        return "Son in-law"
                                    }
                                }
                            }
                        }
                        if (p!.gender == GenderType.FEMALE) {
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
                    inLaws.appendContentsOf(spouses!)
                }
                repeat {
                    var nextLevel = [LittlePerson]()
                    for pp in levelPeople {
                        let parents = dataService.dbHelper.getParentsForPerson(pp.id!)
                        if parents != nil {
                            nextLevel.appendContentsOf(parents!)
                        }
                    }
                    levelPeople = nextLevel;
    
                    var nextInLaw = [LittlePerson]()
                    for pp in inLaws {
                        let parents = dataService.dbHelper.getParentsForPerson(pp.id!)
                        if parents != nil {
                            nextInLaw.appendContentsOf(parents!)
                        }
                    }
                    inLaws = nextInLaw
    
                    d++
                } while(d < distance)
    
                if (levelPeople.contains(p!)) {
                    if (p!.gender == GenderType.FEMALE) {
                        rel += "Mother"
                    } else {
                        rel += "Father"
                    }
                }
                else if (inLaws.contains(p!)) {
                    if (p!.gender == GenderType.FEMALE) {
                        rel += "Mother"
                    } else {
                        rel += "Father"
                    }
                    rel += " in-law"
                }
                else {
                    rel = rel.replaceAll("Grand", replace: "Great");
                    if (p!.gender == GenderType.FEMALE) {
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
                if (p!.gender == GenderType.FEMALE) {
                    rel += "Daughter"
                } else {
                    rel += "Son"
                }
                return rel
            }
        }
        return ""
    }
    
    static func getGreatness(depth:Int) -> String {
        var rel = "";
        if (depth > 4) {
            var great = "\(depth - 2)th"
            switch (depth) {
				case 5:
                    great = "Third"
                    break;
				case 6:
                    great = "Fourth"
                    break;
				case 7:
                    great = "Fifth"
                    break;
				case 8:
                    great = "Sixth"
                    break;
				case 9:
                    great = "Seventh"
                    break;
				case 10:
                    great = "Eighth"
                    break;
				case 11:
                    great = "Nineth"
                    break;
				case 12:
                    great = "Tenth"
                    break;
				case 13:
                    great = "Eleventh"
                    break;
				case 14:
                    great = "Twelvth"
                    break;
				case 15:
                    great = "Thirteenth"
                    break;
				case 16:
                    great = "Fourteenth"
                    break;
            }
            rel = great + " Great ";
        } else {
            for _ in 3..<depth+1 {
				rel += "Great "
            }
        }
        if (depth >= 2) {
            rel += "Grand ";
        }
        return rel
    }
    
    static func getAncestralRelationship(depth:Int, p:LittlePerson, me:LittlePerson, isRoot:Bool, isChild:Bool, isInLaw:Bool) -> String {
        var rel = getGreatness(depth)
    
        if (p.gender == GenderType.FEMALE) {
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
        else if (p.gender == GenderType.MALE) {
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