import Foundation

class GedcomParser {
	var factMap = [String: String]()
	
	init() {
		factMap["ADOP"] = "http://gedcomx.org/Adoption"
		factMap["ANUL"] = "http://gedcomx.org/Annulment"
		factMap["BAPM"] = "http://gedcomx.org/Baptism"
		factMap["BARM"] = "http://gedcomx.org/BarMitzvah"
		factMap["BASM"] = "http://gedcomx.org/BatMitzvah"
		factMap["BIRT"] = "http://gedcomx.org/Birth"
		factMap["BLES"] = "http://gedcomx.org/Blessing"
		factMap["BURI"] = "http://gedcomx.org/Burial"
		factMap["CAST"] = "http://gedcomx.org/Caste"
		factMap["CENS"] = "http://gedcomx.org/Census"
		factMap["CHR"] = "http://gedcomx.org/Christening"
		factMap["CHRA"] = "http://gedcomx.org/AdultChristening"
		factMap["CONF"] = "http://gedcomx.org/Confirmation"
		factMap["CREM"] = "http://gedcomx.org/Cremation"
		factMap["DEAT"] = "http://gedcomx.org/Death"
		factMap["DIV"] = "http://gedcomx.org/Divorce"
		factMap["DIVF"] = "http://gedcomx.org/DivorceFiling"
		factMap["EDUC"] = "http://gedcomx.org/Education"
		factMap["EMIG"] = "http://gedcomx.org/Emigration"
		factMap["ENGA"] = "http://gedcomx.org/Engagement"
		factMap["NATI"] = "http://gedcomx.org/Ethnicity"
		factMap["FCOM"] = "http://gedcomx.org/FirstCommunion"
		factMap["IMMI"] = "http://gedcomx.org/Immigration"
		factMap["MARR"] = "http://gedcomx.org/Marriage"
		factMap["MARB"] = "http://gedcomx.org/MarriageBanns"
		factMap["MARC"] = "http://gedcomx.org/MarriageContract"
		factMap["MARL"] = "http://gedcomx.org/MarriageLicense"
		factMap["NATI"] = "http://gedcomx.org/Nationality"
		factMap["IDNO"] = "http://gedcomx.org/NationalId"
		factMap["NATU"] = "http://gedcomx.org/Naturalization"
		factMap["OCCU"] = "http://gedcomx.org/Occupation"
		factMap["ORDI"] = "http://gedcomx.org/Ordination"
		factMap["DSCR"] = "http://gedcomx.org/PhysicalDescription"
		factMap["RELI"] = "http://gedcomx.org/Religion"
		factMap["PROB"] = "http://gedcomx.org/Probate"
		factMap["PROP"] = "http://gedcomx.org/Property"
		factMap["WILL"] = "http://gedcomx.org/Will"
		factMap["RETI"] = "http://gedcomx.org/Retirement"
		factMap["RESI"] = "http://gedcomx.org/Residence"
	}
	
	func parsePerson(_ gedcom:String) -> Person? {
		var person:Person? = nil
		
		let lines = gedcom.split("(\r?\n)+")
		if lines[0].range(of: "0 @\\w+@ INDI", options: .regularExpression) == nil {
			return person
		}
		
		person = Person()
		let xparts = lines[0].split("@")
		let xref = xparts[1]
		person!.id = xref
		
		var level2s = [[String]]()
		var assertion = [String]()
		for s in 1..<lines.count {
			let line = lines[s]
			if line.hasPrefix("1 ") {
				if assertion.count > 0 {
					level2s.append(assertion)
				}
				assertion = [String]()
			}
			assertion.append(line)
		}
		if assertion.count > 0 {
			level2s.append(assertion)
		}
		
		var hasdeath = false
		 //-- parse each fact
        for a in level2s {
			let line2 = a[0]
			let parts = line2.split(" ")
			if parts[1] == "NAME" {
				let name = parseName(a)
				if person!.names.count == 0 {
					name.preferred = true
				}
				person!.names.append(name)
			} else if parts[1] == "SEX" {
				if parts[2].hasPrefix("M") {
					person!.gender = GenderType.male
				} else if parts[2].hasPrefix("F") {
					person!.gender = GenderType.female
				} else {
					person!.gender = GenderType.unknown
				}
			} else if parts[1] == "SOUR" {
                // TODO
            }
            else if parts[1] == "NOTE" {
                // TODO
            }
			else if parts[1] == "OBJE" {
				let sd = parseMedia(a)
                person!.media.append(sd)
			}
			else if parts[1] == "FAMS" {
				person!.addLink("FAMS", href: parts[2])
			}
			else if parts[1] == "FAMC" {
				person!.addLink("FAMC", href: parts[2])
			}
			else if parts[1] == "CHAN" {
				let date = parseDateTime(a)
				if date != nil {
					person!.lastChange = date!
				}
			}
			else if self.factMap[parts[1]] != nil {
				let fact = parseFact(a)
				person!.facts.append(fact)
				if parts[1] == "DEAT" || parts[1] == "BURI" || parts[1] == "CREM" {
					hasdeath = true
				}
			}
		}
		if hasdeath {
			person!.living = false
		}
		
		return person
	}
	
	func parseFamily(_ gedcom:String) -> FamilyHolder? {
		var family:FamilyHolder? = nil
		
		let lines = gedcom.split("(\r?\n)+")
		if lines[0].range(of: "0 @\\w+@ FAM", options: .regularExpression) == nil {
			return family
		}
		
		family = FamilyHolder()
		let xparts = lines[0].split("@")
		let xref = xparts[1]
		family!.id = xref
		
		var level2s = [[String]]()
		var assertion = [String]()
		for s in 1..<lines.count {
			let line = lines[s]
			if line.hasPrefix("1 ") {
				if assertion.count > 0 {
					level2s.append(assertion)
				}
				assertion = [String]()
			}
			assertion.append(line)
		}
		if assertion.count > 0 {
			level2s.append(assertion)
		}
		
		 //-- parse each fact
        for a in level2s {
			let line2 = a[0]
			let parts = line2.split(" ")
			if parts[1] == "SOUR" {
                // TODO
            }
            else if parts[1] == "NOTE" {
                // TODO
            }
			else if parts[1] == "OBJE" {
				let sd = parseMedia(a)
                family!.media.append(sd)
			}
			else if parts[1] == "HUSB" || parts[1] == "WIFE"{
				let link = Link()
				link.rel = parts[1]
				link.href = parts[2]
				family!.parents.append(link)
			}
			else if parts[1] == "CHIL" {
				let link = Link()
				link.rel = parts[1]
				link.href = parts[2]
				family!.children.append(link)
			}
			else if self.factMap[parts[1]] != nil {
				let fact = parseFact(a)
				family!.facts.append(fact)
			}
		}
		
		return family
	}
	
	func parseObje(_ gedcom:String, baseUrl:String) -> SourceDescription? {
		var sd:SourceDescription? = nil
		
		let lines = gedcom.split("(\r?\n)+")
		if lines[0].range(of: "0 @\\w+@ OBJE", options: .regularExpression) == nil {
			return sd
		}
		
		sd = SourceDescription()
		let xparts = lines[0].split("@")
		let xref = xparts[1]
		sd!.id = xref
		
		for s in 1..<lines.count {
			let line = lines[s]
			let ps = line.split(" ")
			if ps[0] == "1" && ps[1] == "FILE" {
				let link = Link()
				var mediaPath = ps[2]
				for p in 3..<ps.count {
					mediaPath = mediaPath + "%20" + ps[p]
				}
				let paths = mediaPath.split("\\.")
				let ext = paths[paths.count - 1].lowercased()
				if (ext == "jpg" || ext == "jpeg" || ext == "gif" || ext == "png") {
					link.rel = "image"
				} else if ext == "pdf" {
					link.rel = "pdf"
				} else {
					link.rel = "other"
				}
				if mediaPath.hasPrefix("http") == false && mediaPath.hasPrefix("ftp:") == false {
					mediaPath = baseUrl + mediaPath
				}
				link.href = mediaPath
				sd!.links.append(link)
			}
			if ps[1] == "_PRIM" && ps[2] != "N" {
				sd!.sortKey = "1"
			}
		}
        
        return sd
	}
	
	func parseName(_ lines:[String]) -> Name {
        let name = Name()
        let wholeName = lines[0].substring(from: lines[0].characters.index(lines[0].startIndex, offsetBy: 7))
		let form = NameForm()
        form.fulltext = wholeName.replaceAll("/", replace: "")
        for s in 1..<lines.count {
            let line = lines[s]
            let parts = line.split(" ");
            if "GIVN" == parts[1] {
                let part = NamePart()
                part.type = "http://gedcomx.org/Given"
                part.value = line.substring(from: line.characters.index(line.startIndex, offsetBy: 7))
                form.parts.append(part)
            }
            if "SURN" == parts[1] {
                let part = NamePart()
                part.type = "http://gedcomx.org/Surname"
                part.value = line.substring(from: line.characters.index(line.startIndex, offsetBy: 7))
                form.parts.append(part)
            }
            if "NPFX" == parts[1] {
                let part = NamePart()
                part.type = "http://gedcomx.org/Prefix"
                part.value = line.substring(from: line.characters.index(line.startIndex, offsetBy: 7))
                form.parts.append(part)
            }
            if "NSFX" == parts[1] {
                let part = NamePart()
                part.type = "http://gedcomx.org/Suffix"
                part.value = line.substring(from: line.characters.index(line.startIndex, offsetBy: 7))
                form.parts.append(part)
            }
            //-- TODO parse SOUR, NOTE, etc.
        }

        if form.parts.count == 0 {
			let parts = wholeName.split("/")
			if parts.count > 0 {
                let chars = CharacterSet(charactersIn: " ")
				let givn = parts[0].trimmingCharacters(in: chars)
				let part = NamePart()
				part.type = "http://gedcomx.org/Given"
				part.value = givn
				form.parts.append(part)
			}
			
			if parts.count > 1 {
                let chars = CharacterSet(charactersIn: " ")
				let surn = parts[1].trimmingCharacters(in: chars)
				let part = NamePart()
				part.type = "http://gedcomx.org/Surname"
				part.value = surn
				form.parts.append(part)
			}
			
			if parts.count > 2 {
                let chars = CharacterSet(charactersIn: " ")
				let sufx = parts[2].trimmingCharacters(in: chars)
				let part = NamePart()
				part.type = "http://gedcomx.org/Suffix"
				part.value = sufx
				form.parts.append(part)
			}
        }
		name.nameForms.append(form)
        return name
    }
	
	func parseMedia(_ lines:[String]) -> SourceReference {
		let sd = SourceReference()
		let parts = lines[0].split(" ")
		if (parts.count > 2) {
			let link = Link()
			link.rel = "image"
			link.href = parts[2]
			sd.links.append(link)
		}
		for line in lines {
            let ps = line.split(" ")
            if "FILE" == ps[1] {
                let link = Link()
                link.rel = "image"
                link.href = ps[2]
                sd.links.append(link)
            }
        }
		return sd
	}
	
	func parseFact(_ lines:[String]) -> Fact {
        let fact = Fact()
        let parts = lines[0].split(" ")
        var type = factMap[parts[1]]
        if (type == nil) {
            type = "Other"
        }
        fact.type = type
        if (parts.count > 2) {
            fact.value = parts[2]
        }
        for s in 1..<lines.count {
            let line = lines[s]
            let ps = line.split(" ")
            if ps[0] == "2" {
                if ps[1] == "DATE" && fact.date == nil {
                    let date = GedcomDate()
                    date.original = ps[2]
                    fact.date = date
                }
                if ps[1] == "PLAC" && fact.place == nil {
                    let place = PlaceReference()
                    place.original = ps[2]
                    fact.place = place
                }
                if ps[1] == "TYPE" && fact.type == nil {
                    fact.type = ps[2]
                }
            }
        }
        return fact
    }
	
	func parseDateTime(_ lines:[String]) -> Foundation.Date? {
        var hasDate = false
		var hasTime = false
		var dateString = ""
        for line in lines {
            let ps = line.split(" ");
            if ps[0] == "2" {
                if ps[1] == "DATE" {
                    hasDate = true
                    dateString = ps[2]
                }
                if ps[1] == "TIME" {
					hasTime = true
					dateString = dateString + " " + ps[2]
                }
            }
        }
        if hasDate {
			let dateFormatter = DateFormatter()
			if hasTime {
				dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
			} else {
				dateFormatter.dateFormat = "dd MMM yyyy"
			}
			let date = dateFormatter.date(from: dateString)
			return date
        }
        return nil
    }
}
