import Foundation

class Person : Subject {
  var isPrivate:Bool?
  var living:Bool?
  var principal:Bool?
  var gender:GenderType?
  var names = [Name]()
  var facts = [Fact]()
  var display:DisplayProperties?
  var lastChange:Foundation.Date?
  var relationships = [Relationship]()
  
  func getFullName() -> String? {
    if (display != nil && display!.name != nil) {
      return display!.name!
    }
    if (names.count > 0 && names[0].nameForms.count > 0) {
      return names[0].nameForms[0].fulltext!;
    }
    return nil;
  }
  
  static func convertJsonToPersons(_ json:JSON) -> [Person] {
		var persons = [Person]()
    
    if json["persons"].array == nil {
        return persons
    }
		
		for pson in json["persons"].array! {
			let person = Person()
			person.id = pson["id"].description
			person.addLinksFromJson(pson)
			person.addAttributionFromJson(pson)
			person.addIdentifiersFromJson(pson)
			
			person.living = pson["living"].bool
			
			if pson["gender"] != JSON.null {
				if pson["gender"]["type"] == "http://gedcomx.org/Male" {
					person.gender = GenderType.male
				}
				else if pson["gender"]["type"] == "http://gedcomx.org/Female" {
					person.gender = GenderType.female
				}
				else if pson["gender"]["type"] == "http://gedcomx.org/Other" {
					person.gender = GenderType.other
				}
				else {
					person.gender = GenderType.unknown
				}
			}
			
			if pson["names"] != JSON.null {
				for name in pson["names"].array! {
					person.names.append(Name.convertJsonToName(name))
				}
			}
			
			if pson["facts"] != JSON.null {
				for fact in pson["facts"].array! {
					person.facts.append(Fact.convertJsonToFact(fact))
				}
			}
			
			if pson["display"] != JSON.null {
				person.display = DisplayProperties.convertJsonToDisplayProperties(pson["display"])
			}
            
            person.relationships = Relationship.convertJsonToRelationships(pson["relationships"])
			
			persons.append(person)
		}
		
		return persons
	}
}
