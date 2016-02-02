import Foundation

class Person : Subject {
  var isPrivate:Bool?
  var living:Bool?
  var principal:Bool?
  var gender:GenderType?
  var names = [Name]()
  var facts = [Fact]()
  var display:DisplayProperties?
  
  func getFullName() -> NSString? {
    if (display != nil && display!.name != nil) {
      return display!.name!
    }
    if (names.count > 0 && names[0].nameForms.count > 0) {
      return names[0].nameForms[0].fulltext!;
    }
    return nil;
  }
  
  static func convertJsonToPersons(json:JSON) -> [Person] {
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
			
			if pson["gender"] != nil {
				if pson["gender"]["type"] == "http://gedcomx.org/Male" {
					person.gender = GenderType.MALE
				}
				else if pson["gender"]["type"] == "http://gedcomx.org/Female" {
					person.gender = GenderType.FEMALE
				}
				else if pson["gender"]["type"] == "http://gedcomx.org/Other" {
					person.gender = GenderType.OTHER
				}
				else {
					person.gender = GenderType.UNKNOWN
				}
			}
			
			if pson["names"] != nil {
				for name in pson["names"].array! {
					person.names.append(Name.convertJsonToName(name))
				}
			}
			
			if pson["facts"] != nil {
				for fact in pson["facts"].array! {
					person.facts.append(Fact.convertJsonToFact(fact))
				}
			}
			
			if pson["display"] != nil {
				person.display = DisplayProperties.convertJsonToDisplayProperties(pson["display"])
			}
			
			persons.append(person)
		}
		
		return persons
	}
}
