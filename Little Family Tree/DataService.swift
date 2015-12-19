import Foundation

typealias LittlePersonResponse = (LittlePerson?, NSError?) -> Void
typealias PeopleResponse = ([LittlePerson]?, NSError?) -> Void
typealias LocalRelationshipResponse = ([LocalRelationship]?, NSError?) -> Void
typealias MediaResponse = ([Media], NSError?) -> Void

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
    var listeners = [StatusListener]()

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
		SyncQ.getInstance().addToSyncQ(person)
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
                        if person2 != nil {
                            do {
                                person2?.treeLevel = 0
                                try self.dbHelper.persistLittlePerson(person2!)
                                onCompletion(person2, err2)
                            } catch {
                                onCompletion(nil, NSError(domain: "LittleFamily", code: 404, userInfo: ["message":"Unable to persist little person"]))
                            }
                        }
                    })
                } else {
                    onCompletion(nil, err)
                }
			})
        } else {
            if person!.treeLevel == nil {
                person!.treeLevel = 0
                do {
                    try self.dbHelper.persistLittlePerson(person!)
                } catch {
                    print("Error persisting little person")
                }
            }
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
			remoteService?.getPerson(fsid, ignoreCache: false, onCompletion: { fsPerson, err in
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
        let family = [LittlePerson]()
        fireStatusUpdate("Loading close family members of \(person.name!)")
        remoteService!.getCloseRelatives(person.familySearchId!, onCompletion: { closeRelatives, err in
            if closeRelatives != nil {
                self.processRelatives(closeRelatives!, person: person, onCompletion: { people, err in
                    for r in closeRelatives! {
                        if r.type == "http://gedcomx.org/Couple" {
                            person.hasSpouses = true
                            if loadSpouse {
                                var spouse:LittlePerson?
                                if r.person1?.resourceId == person.familySearchId {
                                    spouse = self.dbHelper.getPersonByFamilySearchId(r.person2?.resourceId as! String)
                                } else {
                                    spouse = self.dbHelper.getPersonByFamilySearchId(r.person1?.resourceId as! String)
                                }
                                if spouse != nil {
                                    self.getParents(spouse!, onCompletion: { sp, err in
                                        print(sp)
                                    })
                                }
                            }
                        }
                        else {
                            if r.person1?.resourceId == person.familySearchId {
                                person.hasChildren = true
                            } else {
                                person.hasParents = true
                            }
                        }
                    }
                    do {
                        try self.dbHelper.persistLittlePerson(person)
                    } catch let e as NSError {
                        print(e)
                    }
                    onCompletion(people, err)
                })
            } else {
                onCompletion(family, err)
            }
        })
    }
    
    func getParentsFromRemoteService(person:LittlePerson, onCompletion: PeopleResponse) {
        let family = [LittlePerson]()
        fireStatusUpdate("Loading parents of \(person.name!)")
        remoteService?.getParents(person.familySearchId!, onCompletion: { closeRelatives, err in
            if closeRelatives != nil {
                self.processRelatives(closeRelatives!, person: person, onCompletion: { people, err2 in
                    onCompletion(people, err2)
                })
            } else {
                onCompletion(family, err)
            }
        })
    }
    
    func getChildrenFromRemoteService(person:LittlePerson, onCompletion: PeopleResponse) {
        let family = [LittlePerson]()
        fireStatusUpdate("Loading children of \(person.name!)")
        remoteService?.getChildren(person.familySearchId!, onCompletion: { closeRelatives, err in
            if closeRelatives != nil {
                self.processRelatives(closeRelatives!, person: person, onCompletion: { people, err2 in
                    onCompletion(people, err2)
                })
            } else {
                onCompletion(family, err)
            }
        })
    }
    
    func getSpousesFromRemoteService(person:LittlePerson, onCompletion: PeopleResponse) {
        let family = [LittlePerson]()
        fireStatusUpdate("Loading spouses of \(person.name!)")
        remoteService?.getSpouses(person.familySearchId!, onCompletion: { closeRelatives, err in
            if closeRelatives != nil {
                self.processRelatives(closeRelatives!, person: person, onCompletion: { people, err2 in
                    onCompletion(people, err2)
                })
            } else {
                onCompletion(family, err)
            }
        })
    }
    
    func getParents(person:LittlePerson, onCompletion: PeopleResponse) {
        let parents = dbHelper.getParentsForPerson(person.id!)
        if parents == nil || parents!.count == 0 {
            getParentsFromRemoteService(person, onCompletion: { people, err in
                if person.hasParents == nil || person.hasParents == false {
                    person.hasParents = true
                    do {
                        try self.dbHelper.persistLittlePerson(person)
                    } catch let e as NSError {
                        print(e)
                    }
                }
                onCompletion(people, err)
            })
        } else {
            if person.hasParents == nil || person.hasParents == false {
                person.hasParents = true
                do {
                    try self.dbHelper.persistLittlePerson(person)
                } catch let e as NSError {
                    print(e)
                }
            }
            for p in parents! {
                addToSyncQ(p)
            }
            onCompletion(parents, nil)
        }
    }
    
    func getSpouses(person:LittlePerson, onCompletion: PeopleResponse) {
        let spouses = dbHelper.getSpousesForPerson(person.id!)
        if spouses == nil || spouses!.count == 0 {
            getSpousesFromRemoteService(person, onCompletion: { people, err in
                if person.hasSpouses == nil || person.hasSpouses == false {
                    person.hasSpouses = true
                    do {
                        try self.dbHelper.persistLittlePerson(person)
                    } catch let e as NSError {
                        print(e)
                    }
                }
                onCompletion(people, err)
            })
        } else {
            if person.hasSpouses == nil || person.hasSpouses == false {
                person.hasSpouses = true
                do {
                    try self.dbHelper.persistLittlePerson(person)
                } catch let e as NSError {
                    print(e)
                }
            }
            for p in spouses! {
                addToSyncQ(p)
            }
            onCompletion(spouses, nil)
        }
    }
    
    func getChildren(person:LittlePerson, onCompletion: PeopleResponse) {
        let children = dbHelper.getSpousesForPerson(person.id!)
        if children == nil || children!.count == 0 {
            getChildrenFromRemoteService(person, onCompletion: { people, err in
                if person.hasChildren == nil || person.hasChildren == false {
                    person.hasChildren = true
                    do {
                        try self.dbHelper.persistLittlePerson(person)
                    } catch let e as NSError {
                        print(e)
                    }
                }
                onCompletion(people, err)
            })
        } else {
            if person.hasChildren == nil || person.hasChildren == false {
                person.hasChildren = true
                do {
                    try self.dbHelper.persistLittlePerson(person)
                } catch let e as NSError {
                    print(e)
                }
            }
            for p in children! {
                addToSyncQ(p)
            }
            onCompletion(children, nil)
        }
    }
    
    func processRelatives(closeRelatives:[Relationship], person:LittlePerson, onCompletion:PeopleResponse) {
        var family = [LittlePerson]()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        for r in closeRelatives {
            dispatch_group_enter(group)
            getPersonByRemoteId(r.person1!.resourceId!, onCompletion: { person1, err in
                if person1 != nil {
                    self.getPersonByRemoteId(r.person2!.resourceId!, onCompletion: { person2, err in
                        if person2 != nil {
                            let lr = LocalRelationship()
                            lr.id1 = person1?.id
                            lr.id2 = person2?.id
                            var person1changed = false
                            var person2changed = false
                            if r.type == "http://gedcomx.org/Couple" {
                                lr.type = RelationshipType.SPOUSE
                                if person2?.treeLevel == nil && person1?.treeLevel != nil {
                                    person2?.treeLevel = person1?.treeLevel
                                    person2changed = true
                                }
                                if person2?.age == nil && person1?.age != nil  {
                                    person2?.age = (person1?.age)!
                                    person2changed = true
                                }
                                if person1?.treeLevel == nil && person2?.treeLevel != nil {
                                    person1?.treeLevel = person2?.treeLevel
                                    person1changed = true
                                }
                                if person1?.age == nil && person2?.age != nil  {
                                    person1?.age = (person2?.age)!
                                    person1changed = true
                                }

                            } else {
                                lr.type = RelationshipType.PARENTCHILD
                                if person2?.treeLevel == nil && person1?.treeLevel != nil {
                                    person2?.treeLevel = (person1?.treeLevel)! - 1
                                    person2changed = true
                                }
                                if person2?.age == nil && person1?.age != nil  {
                                    person2?.age = (person1?.age)! - 25
                                    person2changed = true
                                }
                                if person1?.treeLevel == nil && person2?.treeLevel != nil {
                                    person1?.treeLevel = (person2?.treeLevel)! + 1
                                    person1changed = true
                                }
                                if person1?.age == nil && person2?.age != nil  {
                                    person1?.age = (person2?.age)! + 25
                                    person1changed = true
                                }
                            }
                            self.dbHelper.persistRelationship(lr)
                            
                            if person1changed {
                                do {
                                    try self.dbHelper.persistLittlePerson(person1!)
                                } catch let e as NSError {
                                    print(e)
                                }
                            }
                            if person2changed {
                                do {
                                    try self.dbHelper.persistLittlePerson(person2!)
                                } catch let e as NSError {
                                    print(e)
                                }
                            }
                            
                            if person != person1 && !family.contains(person1!) {
                                family.append(person1!)
                            }
                            if person != person2 && !family.contains(person2!) {
                                family.append(person2!)
                            }
                        }
                        dispatch_group_leave(group)
                    })
                } else {
                    dispatch_group_leave(group)
                }
            })
        }
        
        dispatch_group_notify(group, queue) {
            onCompletion(family, nil)
        }
    }
    
    func getMediaForPerson(person:LittlePerson, onCompletion:MediaResponse) {
        var media = [Media]()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        
        var mediaFound = false;
        if (person.hasMedia == nil) {
            dispatch_group_enter(group)
            self.remoteService!.getPersonMemories(person.familySearchId!, onCompletion: { sds, err in
                if sds != nil {
                    for sd in sds! {
                        var med = self.dbHelper.getMediaByFamilySearchId(sd.id as! String)
                        if med == nil {
                            let links = sd.links
                            if links.count > 0 {
                                for link in links {
                                    if (link.rel != nil && link.rel == "image") {
                                        med = Media()
                                        med?.type = "photo"
                                        med?.familySearchId = sd.id
                                        
                                        dispatch_group_enter(group)
                                        let oname = self.lastPath(link.href! as String)
                                        let fileName = "\(sd.id!)-\(oname)"
                                        self.remoteService!.downloadImage(link.href!, folderName: person.familySearchId!, fileName: fileName, onCompletion: { localPath, err2 in
                                            print("downloaded image to \(localPath)")
                                            if localPath != nil {
                                                med?.localPath = localPath
                                                mediaFound = true
                                                self.dbHelper.persistMedia(med!)
                                                media.append(med!)
                                                let tag = Tag()
                                                tag.mediaId = med!.id
                                                tag.personId = person.id!
                                                do {
                                                    try self.dbHelper.persistTag(tag)
                                                } catch {
                                                    print("Error saving tag")
                                                }
                                            }
                                            dispatch_group_leave(group)
                                        })
                                    }
                                }
                            }
                        } else {
                            media.append(med!)
                        }
                    }
                }
                dispatch_group_leave(group)
            })

        } else {
            media = dbHelper.getMediaForPerson(person.id!)
        }
        
        dispatch_group_notify(group, queue) {
            if person.hasMedia == nil {
                if (mediaFound) {
                    person.hasMedia = true
                } else {
                    person.hasMedia = false
                }
                do {
                    try self.dbHelper.persistLittlePerson(person)
                } catch {
                    print("Error saving person from media")
                }
            }
            
            onCompletion(media, nil)
        }
    }
    
	
	func getEncryptedProperty(property:NSString) -> NSString? {
		return dbHelper.getProperty(property as String)
	}
	
	func saveEncryptedProperty(property:NSString, value:NSString) {
		dbHelper.saveProperty(property as String, value: value as String)
	}
    
    func addStatusListener(listener:StatusListener) {
        var found = false
        for l in listeners {
            if (l as! AnyObject) === (listener as! AnyObject) {
                found = true
                break
            }
        }
        if !found {
            listeners.append(listener)
        }
    }
    
    func removeStatusListener(listener:StatusListener) {
        var index = -1
        var i = -1
        for l in listeners {
            i++
            if (l as! AnyObject) === (listener as! AnyObject) {
                index = i
                break
            }
        }
        
        if index >= 0 {
            listeners.removeAtIndex(index)
        }
    }
    
    func fireStatusUpdate(message:String) {
        for l in listeners {
            l.statusChanged(message)
        }
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
				if birthDateStr == nil || birthDateStr == "null" {
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
                            let df3 = NSDateFormatter()
                            df3.dateFormat = "yyyy"
                            person.birthDate = df3.dateFromString(yearStr)
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
                return NSString(string: filePath);
            }
			i--
        } while i >= 0
        return href;
    }
}