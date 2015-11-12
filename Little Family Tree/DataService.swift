import Foundation

typealias LittlePersonResponse = (LittlePerson?, NSError?) -> Void
typealias PeopleResponse = ([LittlePerson]?, NSError?) -> Void

class DataService {
	static let SERVICE_TYPE = "service_type"
    static let SERVICE_TYPE_PHPGEDVIEW = "PGVService"
    static let SERVICE_TYPE_FAMILYSEARCH = "FamilySearchService"
    static let SERVICE_TOKEN = "Token"
    static let SERVICE_BASEURL = "BaseUrl"
    static let SERVICE_DEFAULTPERSONID = "DefaultPersonId"
    static let SERVICE_USERNAME = "Username"
    static let ROOT_PERSON_ID = "Root_Person_id"

	var remoteService:RemoteService?
	var serviceType:NSString?
	var dbHelper:DBHelper
	var authenticating:Bool = false

	private static var instance:DataService?
	
	static func getInstance() -> DataService {
		if DataService.instance == nil {
			DataService.instance = DataService()
		}
		return DataService.instance!
	}
	
	private init() {
		dbHelper = DBHelper.getInstance()
		self.serviceType = dbHelper.getProperty(DataService.SERVICE_TYPE)
		if serviceType != nil {
			if serviceType == DataService.SERVICE_TYPE_FAMILYSEARCH {
				self.remoteService = FamilySearchService.sharedInstance
			}
			/*
			else if serviceType == DataService.SERVICE_TYPE_PHPGEDVIEW {
			}
			*/
			if remoteService?.sessionId == nil {
				autoLogin()
			}
		}
	}
	
	func setRemoteService(type:NSString, service:RemoteService) {
		self.serviceType = type
		self.remoteService = service
	}
	
	func autoLogin() {
		let username = getEncryptedProperty(DataService.SERVICE_USERNAME)
		let token = getEncryptedProperty(serviceType as! String + DataService.SERVICE_TOKEN)
		if token != nil {
			if remoteService?.sessionId == nil && !authenticating {
				authenticating = true
				remoteService?.authenticate(username! as String, password: token! as String, onCompletion: { json, err in
					self.authenticating = false
					
				})
			}
		}
	}
	
	func addToSyncQ(person:LittlePerson) {
		let todayDate = NSDate()
		let lastHour = NSDate(timeInterval: -60, sinceDate: todayDate)
		if (person.hasParents == nil 
			|| person.lastSync==nil || person.lastSync!.compare(lastHour) == NSComparisonResult.OrderedAscending
			|| person.treeLevel==nil 
			|| (person.treeLevel <= 1 && person.hasChildren == nil)) {
			
		}
	}
	
	func addFamilyToSyncQ(people:[LittlePerson]) {
		for person in people {
			addToSyncQ(person)
		}
	}
	
	func getDefaultPerson(ignoreLocal:Bool, onCompletion:LittlePersonResponse) {
		var person:LittlePerson?
		if !ignoreLocal {
			let idStr = dbHelper.getProperty(DataService.ROOT_PERSON_ID)
			if idStr != nil {
				let id = Int64(idStr! as String)
				person = dbHelper.getPersonById(id!)
			} else {
				person = dbHelper.getFirstPerson()
				if person != nil {
					dbHelper.saveProperty(DataService.ROOT_PERSON_ID, value: String(person!.id!))
				}
			}
		}
		
		if person == nil {
			remoteService?.getCurrentPerson( { fsperson, err in
                if fsperson != nil {
                    self.buildLittlePerson(fsperson!, onCompletion: { (person2, err2) -> Void in
                        onCompletion(person2, err2)
                    })
                }
			})
        } else {
            onCompletion(person, nil)
        }
	}
	
	func getPersonById(id:Int64) -> LittlePerson? {
		let person = dbHelper.getPersonById(id)
		if person != nil {
			addToSyncQ(person!)
		}
		return person
	}
	
	func getPersonByRemoteId(fsid:NSString, onCompletion:LittlePersonResponse) {
		let person = dbHelper.getPersonByFamilySearchId(fsid as String)
		if (person != nil) {
			addToSyncQ(person!)
			onCompletion(person, nil)
		} else {
			remoteService?.getPerson(fsid, onCompletion: { fsPerson, err in
				if fsPerson != nil {
					self.buildLittlePerson(fsPerson!, onCompletion: { per, err2 in
						if per != nil {
                            do {
                                try self.dbHelper.persistLittlePerson(per!)
                                onCompletion(per, nil)
                            } catch {
                                onCompletion(nil, NSError(domain: "LittleFamily", code: 404, userInfo: ["message":"Unable to persist little person"]))
                            }
						} else {
							onCompletion(nil, err2)
						}
					})
				} else {
					onCompletion(nil, err)
				}
			})
		}
	}
	
	func getFamilyMembers(person:LittlePerson, loadSpouse: Bool, onCompletion: PeopleResponse) {
		let family = dbHelper.getRelativesForPerson(person.id!, followSpouse: loadSpouse)
		if family == nil || person.hasSpouses == nil || person.hasParents == nil || person.hasChildren == nil {
			getFamilyMembersFromRemoteService(person, loadSpouse: loadSpouse, onCompletion: { people, err in 
				self.addFamilyToSyncQ(people!)
				onCompletion(people, err)
			})
		} else {
			addFamilyToSyncQ(family!)
			onCompletion(family, nil)
		}
	}
	
	func getFamilyMembersFromRemoteService(person:LittlePerson, loadSpouse:Bool, onCompletion: PeopleResponse) {
		
	}
	
	func getEncryptedProperty(property:NSString) -> NSString? {
		return dbHelper.getProperty(property as String)
	}
	
	func saveEncryptedProperty(property:NSString, value:NSString) {
		dbHelper.saveProperty(property as String, value: value as String)
	}
	
	func buildLittlePerson(fsPerson:Person, onCompletion: LittlePersonResponse ) {
		let person = LittlePerson()
		person.name = fsPerson.getFullName()
		person.familySearchId = fsPerson.id
		person.gender = fsPerson.gender
		var name:Name? = nil
		for n in fsPerson.names {
            if name == nil || (n.preferred != nil && n.preferred == true) {
                name = n
            }
        }
		
		if name != nil {
			let forms = name!.nameForms
			
            let parts = forms[0].parts
            for p in parts {
                if p.type == "http://gedcomx.org/Given" {
                    person.givenName = p.value
                    let gparts = (person.givenName as! String).characters.split{$0 == " "}.map(String.init)
                    if gparts.count > 1 {
                        person.givenName = gparts[0]
                    }
                    break
                }
            }
		}
		
		if person.givenName == nil && person.name != nil {
			let parts = (person.givenName as! String).characters.split{$0 == " "}.map(String.init)
			person.givenName = parts[0]
		}
		
		let facts = fsPerson.facts
		var birth:Fact? = nil
		for b in facts {
			if b.type == "http://gedcomx.org/Birth" {
				if birth==nil {
					birth = b
				} else if b.primary != nil && b.primary == true {
					birth = b
				} else if b.date != nil && birth!.date == nil {
					birth = b
				}
			}
			if b.type == "http://gedcomx.org/Nationality" {
				person.nationality = b.value
			}
		}
		
		if birth != nil {
			if birth!.place != nil {
				if birth!.place!.normalized.count > 0 {
					person.birthPlace = birth!.place!.normalized[0].value
					if (PlaceHelper.countPlaceLevels(person.birthPlace! as String) < PlaceHelper.countPlaceLevels(birth!.place!.original! as String)) {
						person.birthPlace = birth!.place!.original
					}
				} else {
					person.birthPlace = birth!.place!.original
				}
			}
			if birth!.date != nil {
				var birthDateStr = birth!.date!.formal
				if birthDateStr == nil {
					birthDateStr = birth!.date!.original
				}
				if birthDateStr != nil {
					let dateFormatter = NSDateFormatter()
					dateFormatter.dateFormat = "dd MMM yyyy"
					person.birthDate = dateFormatter.dateFromString(birthDateStr as! String)
					if person.birthDate == nil {
						let df2 = NSDateFormatter()
						df2.dateFormat = "+yyyy-MM-dd"
						person.birthDate = df2.dateFromString(birthDateStr as! String)
						if person.birthDate == nil {
							let regex = try? NSRegularExpression(pattern: "[0-9]{4}", options: [])
							let results = regex!.firstMatchInString(birthDateStr as! String, options:[], range: NSMakeRange(0, birthDateStr!.length))
							let yearStr = birthDateStr!.substringWithRange(results!.range)
							let year = Int(yearStr)
							let todayDate = NSDate()
							let currYear = NSCalendar.currentCalendar().component(.Year, fromDate: todayDate)
							person.age = currYear - year!
						} else {
							person.updateAge()
						}
					} else {
						person.updateAge()
					}
				}
			}
		}
		
		if fsPerson.living == nil && person.age > 105 {
			person.alive = false
			fsPerson.living = false
		}
		if fsPerson.living == nil || fsPerson.living == true {
			person.alive = true
		} else {
			person.alive = false
		}
		
		person.active = true
		
		person.lastSync = NSDate()
		
		remoteService!.getPersonPortrait(person.familySearchId!, onCompletion: {link, err1 in
			if link != nil {
				self.remoteService!.downloadImage(link!.href!, folderName: person.familySearchId!, fileName: self.lastPath(link!.href! as String), onCompletion: { path, err2 in
					person.photoPath = path
					onCompletion( person, err2)
				})
			} else {
				onCompletion( person, err1)
			}
		})
	}
	
	func lastPath(href:String) -> NSString {
		let parts = href.characters.split{$0 == "/"}.map(String.init)
		var i = parts.count - 1
		repeat {
            let part = NSString(string: parts[i])
            if part.length > 0 {
                var filePath = parts[i]
				if let idx = filePath.characters.indexOf("?") {
                    filePath = filePath.substringToIndex(idx);
                }
                return filePath;
            }
			i--
        } while i >= 0
        return href;
    }
}