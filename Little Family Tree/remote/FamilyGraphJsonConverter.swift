//
//  FamilyGraphJsonConverter.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 9/20/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class FamilyGraphJsonConverter {
    var gedcomParser = GedcomParser()
    
    func createJsonPerson(json:NSDictionary) -> Person {
        let person = Person()
        
        person.id = json["id"] as? NSString
        
        let gen = json["gender"] as? NSString
        
        var gender = GenderType.UNKNOWN
        if gen != nil {
            if "M" == gen {
                gender = GenderType.MALE
            } else if "F" == gen {
                gender = GenderType.FEMALE
            }
        }
        person.gender = gender
        
        let isAlive = json["is_alive"] as? Bool
        person.living = isAlive
        
        let link = Link()
        link.href = json["link"] as? NSString
        link.rel = "link"
        
        let name = Name()
        let form = NameForm()
        let ft = json["name"] as? String
        form.fulltext = ft?.replaceAll(" \\([\\w\\s]*\\)", replace: "")
        
        if json["first_name"] != nil {
            let part = NamePart()
            part.type = "http://gedcomx.org/Given"
            part.value = json["first_name"] as? String
            form.parts.append(part)
        }
        if json["last_name"] != nil {
            let part = NamePart()
            part.type = "http://gedcomx.org/Surname"
            part.value = json["last_name"] as? String
            form.parts.append(part)
        }
        if json["name_prefix"] != nil {
            let part = NamePart()
            part.type = "http://gedcomx.org/Prefix"
            part.value = json["name_prefix"] as? String
            form.parts.append(part)
        }
        if json["name_suffix"] != nil {
            let part = NamePart()
            part.type = "http://gedcomx.org/Suffix"
            part.value = json["name_suffix"] as? String
            form.parts.append(part)
        }
        
        name.nameForms.append(form)
        person.names.append(name)
        
        if json["nickname"] != nil {
            let nickname = Name()
            let nickform = NameForm()
            let part = NamePart()
            part.type = "http://gedcomx.org/Given"
            part.value = json["nickname"] as? String
            form.parts.append(part)
            nickname.nameForms.append(nickform)
            person.names.append(nickname)
        }
        
        if json["personal_photo"] != nil {
            let photo = json["personal_photo"] as! NSDictionary
            let photo_id = photo["id"] as? String
            let sr = SourceReference()
            let link = Link()
            link.rel = "image"
            link.href = photo_id
            sr.links.append(link)
            person.media.append(sr)
        }
        
        return person
    }
    
    func processEvents(json:NSDictionary, person:Person) {
        let facts = json["data"] as! NSArray
        for factj in facts {
            let eventType = factj["event_type"] as? String
            
            let fact = Fact()
            if eventType == nil || gedcomParser.factMap[eventType!] == nil {
                fact.type = "http://gedcomx.org/Other"
            } else {
                fact.type = gedcomParser.factMap[eventType!]
            }
            
            if factj["header"] != nil {
                fact.value = factj["header"] as? String
            }

            if factj["date"] != nil {
                let datej = factj["date"] as? NSDictionary
                let date = Date()
                date.formal = "+\(datej!["date"]!)"
                date.original = datej!["gedcom"] as? String
                fact.date = date
            }
            
            if factj["place"] != nil {
                let place = PlaceReference()
                place.original = factj["place"] as? String
                fact.place = place
            }
            
            person.facts.append(fact)
        }
    }
    
    func convertMedia(media:NSDictionary) -> SourceDescription {
        let sd = SourceDescription()
        sd.id = media["id"] as? String
        if media["is_personal_photo"] != nil {
            sd.sortKey = "1"
        }
        
        let link = Link()
        if media["type"] != nil && media["type"] as? String == "photo" {
            link.rel = "image"
        } else {
            link.rel = media["type"] as? String
        }
        link.href = media["url"] as? String
        sd.links.append(link)
        
        return sd
    }
    
    func convertFamily(json:NSDictionary) -> FamilyHolder {
        let family = FamilyHolder()
        family.id = json["id"] as? String
        if json["husband"] != nil {
            let link = Link()
            let husband = json["husband"] as! NSDictionary
            link.rel = "HUSB"
            link.href = husband["id"] as? String
            family.parents.append(link)
        }
        if json["wife"] != nil {
            let link = Link()
            let wife = json["wife"] as! NSDictionary
            link.rel = "WIFE"
            link.href = wife["id"] as? String
            family.parents.append(link)
        }
        if json["children"] != nil {
            let jchildren = json["children"] as! NSArray
            for child in jchildren {
                let link = Link()
                link.rel = "CHIL"
                link.href = child["id"] as? String
                family.children.append(link)
            }
        }
        return family
    }
}