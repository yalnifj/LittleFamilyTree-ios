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
    
    func createJsonPerson(_ json:JSON) -> Person {
        let person = Person()
        
        person.id = json["id"].string
        
        let gen = json["gender"].string
        
        var gender = GenderType.unknown
        if gen != nil {
            if "M" == gen {
                gender = GenderType.male
            } else if "F" == gen {
                gender = GenderType.female
            }
        }
        person.gender = gender
        
        let isAlive = json["is_alive"].bool
        person.living = isAlive
        
        let link = Link()
        link.href = json["link"].string
        link.rel = "link"
        
        let name = Name()
        let form = NameForm()
        let ft = json["name"].string
        form.fulltext = ft?.replaceAll(" \\([\\w\\s]*\\)", replace: "")
        
        if json["first_name"] != JSON.null {
            let part = NamePart()
            part.type = "http://gedcomx.org/Given"
            part.value = json["first_name"].string
            form.parts.append(part)
        }
        if json["last_name"] != JSON.null {
            let part = NamePart()
            part.type = "http://gedcomx.org/Surname"
            part.value = json["last_name"].string
            form.parts.append(part)
        }
        if json["name_prefix"] != JSON.null {
            let part = NamePart()
            part.type = "http://gedcomx.org/Prefix"
            part.value = json["name_prefix"].string
            form.parts.append(part)
        }
        if json["name_suffix"] != JSON.null {
            let part = NamePart()
            part.type = "http://gedcomx.org/Suffix"
            part.value = json["name_suffix"].string
            form.parts.append(part)
        }
        
        name.nameForms.append(form)
        person.names.append(name)
        
        if json["nickname"] != JSON.null {
            let nickname = Name()
            let nickform = NameForm()
            let part = NamePart()
            part.type = "http://gedcomx.org/Given"
            part.value = json["nickname"].string
            form.parts.append(part)
            nickname.nameForms.append(nickform)
            person.names.append(nickname)
        }
        
        if json["personal_photo"] != JSON.null {
            let photo = json["personal_photo"]
            let photo_id = photo["id"].string
            let sr = SourceReference()
            let link = Link()
            link.rel = "image"
            link.href = photo_id
            sr.links.append(link)
            person.media.append(sr)
        }
        
        return person
    }
    
    func processEvents(_ json:JSON, person:Person) {
        let facts = json["data"].array
        if facts != nil {
            for factjson in facts! {
                let factj = factjson
                let eventType = factj["event_type"].string
                
                let fact = Fact()
                if eventType == nil || gedcomParser.factMap[eventType!] == nil {
                    fact.type = "http://gedcomx.org/Other"
                } else {
                    fact.type = gedcomParser.factMap[eventType!]
                }
                
                if factj["header"] != JSON.null {
                    fact.value = factj["header"].string
                }

                if factj["date"] != JSON.null {
                    let datej = factj["date"]
                    let date = GedcomDate()
                    date.formal = "+\(datej["date"])"
                    date.original = datej["gedcom"].string
                    fact.date = date
                }
                
                if factj["place"] != JSON.null {
                    let place = PlaceReference()
                    place.original = factj["place"].string
                    fact.place = place
                }
                
                person.facts.append(fact)
            }
        }
    }
    
    func convertMedia(_ media:JSON) -> SourceDescription {
        let sd = SourceDescription()
        sd.id = media["id"].string
        if media["is_personal_photo"] != JSON.null {
            sd.sortKey = "1"
        }
        
        let link = Link()
        if media["type"] != JSON.null && media["type"].string == "photo" {
            link.rel = "image"
        } else {
            link.rel = media["type"].string
        }
        link.href = media["url"].string
        sd.links.append(link)
        
        return sd
    }
    
    func convertFamily(_ json:JSON) -> FamilyHolder {
        let family = FamilyHolder()
        family.id = json["id"].string
        if json["husband"] != nil {
            let link = Link()
            let husband = json["husband"]
            link.rel = "HUSB"
            link.href = husband["id"].string
            family.parents.append(link)
        }
        if json["wife"] != nil {
            let link = Link()
            let wife = json["wife"]
            link.rel = "WIFE"
            link.href = wife["id"].string
            family.parents.append(link)
        }
        if json["children"] != nil {
            let jchildren = json["children"].array
            for childj in jchildren! {
                let child = childj
                let link = Link()
                link.rel = "CHIL"
                link.href = child["id"].string
                family.children.append(link)
            }
        }
        return family
    }
}
