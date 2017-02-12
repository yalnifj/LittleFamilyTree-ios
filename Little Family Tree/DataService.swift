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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


typealias LittlePersonResponse = (LittlePerson?, NSError?) -> Void
typealias PeopleResponse = ([LittlePerson]?, NSError?) -> Void
typealias LocalRelationshipResponse = ([LocalRelationship]?, NSError?) -> Void
typealias MediaResponse = ([Media], NSError?) -> Void

class DataService {
	static let SERVICE_TYPE = "service_type"
    static let SERVICE_TYPE_PHPGEDVIEW = "PGVService"
    static let SERVICE_TYPE_FAMILYSEARCH = "FamilySearchService"
    static let SERVICE_TYPE_MYHERITAGE = "MyHeritageService"
    static let SERVICE_TOKEN = "Token"
    static let SERVICE_BASEURL = "BaseUrl"
    static let SERVICE_DEFAULTPERSONID = "DefaultPersonId"
    static let SERVICE_USERNAME = "Username"
    static let ROOT_PERSON_ID = "Root_Person_id"
    static let PROPERTY_SYNC_BACKGROUND = "syncBackground"
    static let PROPERTY_SYNC_CELL = "syncCell"
    static let PROPERTY_SYNC_DELAY = "syncDelay"
    static let PROPERTY_SHOW_PARENTS_GUIDE = "showParentsGuide"
	static let PROPERTY_SHOW_STEP_CHILDREN = "showStepChildren"
	static let PROPERTY_REMEMBER_ME = "rememberMe"
    static let PROPERTY_SKIN_TONE = "skin_tone"

	var remoteService:RemoteService? = nil
	var serviceType:String? = nil
	var dbHelper:DBHelper
	var authenticating:Bool = false
    var listeners = [StatusListener]()

	fileprivate static var instance:DataService?
	
	static func getInstance() -> DataService {
		if DataService.instance == nil {
			DataService.instance = DataService()
		}
		return DataService.instance!
	}
	
	fileprivate init() {
		dbHelper = DBHelper.getInstance()
		self.serviceType = dbHelper.getProperty(DataService.SERVICE_TYPE) as String?
		if serviceType != nil {
			if serviceType == DataService.SERVICE_TYPE_FAMILYSEARCH {
				self.remoteService = FamilySearchService.sharedInstance
			}
			else if serviceType == DataService.SERVICE_TYPE_PHPGEDVIEW {
                let url = dbHelper.getProperty(DataService.SERVICE_BASEURL)
                if url != nil {
                    let defaultId = self.dbHelper.getProperty(DataService.SERVICE_DEFAULTPERSONID)
                    if defaultId != nil {
                        self.remoteService = PGVService(base: url!, defaultPersonId: defaultId!)
                    }
                }
            } else if serviceType == DataService.SERVICE_TYPE_MYHERITAGE {
                self.remoteService = MyHeritageService()
            }
			if remoteService != nil && remoteService?.sessionId == nil {
				autoLogin()
			}
		}
	}
	
	func setRemoteService(_ type:String, service:RemoteService) {
		self.serviceType = type
		self.remoteService = service
	}
	
	func autoLogin() {
		let username = getEncryptedProperty(DataService.SERVICE_USERNAME)
		let token = getEncryptedProperty(serviceType! + DataService.SERVICE_TOKEN)
		if username != nil && token != nil {
			if remoteService?.sessionId == nil && !authenticating {
				authenticating = true
				remoteService?.authenticate(username! as String, password: token! as String, onCompletion: { data, err in
					self.authenticating = false
					
				})
			}
		}
	}
	
	func addToSyncQ(_ person:LittlePerson) {
		SyncQ.getInstance().addToSyncQ(person)
	}
	
	func addFamilyToSyncQ(_ people:[LittlePerson]) {
		for person in people {
			addToSyncQ(person)
		}
	}
	
	func getDefaultPerson(_ ignoreLocal:Bool, onCompletion:@escaping LittlePersonResponse) {
		var person:LittlePerson?
		if !ignoreLocal {
			let idStr = dbHelper.getProperty(DataService.ROOT_PERSON_ID)
			if idStr != nil {
				let id = Int64(idStr! as String)
                if id != nil {
                    person = dbHelper.getPersonById(id!)
                }
			}
            if person == nil {
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
                                self.dbHelper.saveProperty(DataService.ROOT_PERSON_ID, value: String(person2!.id!))
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
	
	func getPersonById(_ id:Int64) -> LittlePerson? {
		let person = dbHelper.getPersonById(id)
		if person != nil {
			addToSyncQ(person!)
		}
		return person
	}
	
	func getPersonByRemoteId(_ fsid:String, onCompletion:@escaping LittlePersonResponse) {
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
	
	func getFamilyMembers(_ person:LittlePerson, loadSpouse: Bool, onCompletion: @escaping PeopleResponse) {
		let queue = DispatchQueue.global()
		let group = DispatchGroup()
		
		var family = dbHelper.getRelativesForPerson(person.id!)
		if family == nil || person.hasSpouses == nil || person.hasParents == nil || person.hasChildren == nil {
			family = [LittlePerson]()
			group.enter()
			getFamilyMembersFromRemoteService(person, onCompletion: { people, err in
                if people != nil {
                    for p in people! {
                        family!.append(p)
                    }
                }
				group.leave()
			})
		}
		
		if loadSpouse {
			group.enter()
			self.getSpouses(person, onCompletion: { spouses, err in
                if spouses != nil {
                    for spouse in spouses! {
                        if !family!.contains(spouse) {
                            family!.append(spouse)
                        }
                        
                        if person.treeLevel != nil && person.treeLevel! < 2 {
                            group.enter()
                            self.getChildren(spouse, onCompletion: { stepChildren, err in
                                if stepChildren != nil {
                                    for sc in stepChildren! {
                                        if !family!.contains(sc) {
                                            family!.append(sc)
                                        }
                                    }
                                }
                                group.leave()
                            })
                        }
                    }
                }
				group.leave()
			})
		}
		
		group.notify(queue: queue) {
			self.addFamilyToSyncQ(family!)
			onCompletion(family, nil)
		}
	}
	
	func getFamilyMembersFromRemoteService(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let family = [LittlePerson]()
        if person.name != nil {
            fireStatusUpdate("Loading close family members of \(person.name!)")
        }
        remoteService!.getCloseRelatives(person.familySearchId!, onCompletion: { closeRelatives, err in
            if closeRelatives != nil {
                self.processRelatives(closeRelatives!, person: person, onCompletion: { people, err in
                    for r in closeRelatives! {
                        if r.type == "http://gedcomx.org/Couple" {
                            person.hasSpouses = true
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
    
    func getParentsFromRemoteService(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let family = [LittlePerson]()
        if person.name != nil {
            fireStatusUpdate("Loading parents of \(person.name!)")
        }
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
    
    func getChildrenFromRemoteService(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let family = [LittlePerson]()
        if person.name != nil {
            fireStatusUpdate("Loading children of \(person.name!)")
        }
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
    
    func getSpousesFromRemoteService(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let family = [LittlePerson]()
        if person.name != nil {
            fireStatusUpdate("Loading spouses of \(person.name!)")
        }
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
    
    func getParents(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let parents = dbHelper.getParentsForPerson(person.id!)
        if person.hasParents == nil && (parents == nil || parents!.count == 0) {
            getParentsFromRemoteService(person, onCompletion: { people, err in
                if people != nil && people?.count > 0 {
                    if person.hasParents == nil || person.hasParents == false {
                        person.hasParents = true
                        do {
                            try self.dbHelper.persistLittlePerson(person)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                } else if err == nil {
                    if person.hasParents == nil || person.hasParents == true {
                        person.hasParents = false
                        do {
                            try self.dbHelper.persistLittlePerson(person)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                }
                onCompletion(people, err)
            })
        } else {
            if parents != nil && parents!.count > 0 {
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
            }
            onCompletion(parents, nil)
        }
    }
    
    func getParentCouple(_ child:LittlePerson, inParent:LittlePerson?, onCompletion: @escaping PeopleResponse) {
        self.getParents(child, onCompletion: { parents, err in
            if parents != nil && parents!.count > 0 {
                var parent = inParent
                if inParent == nil {
                    parent = parents![0]
                }
                self.getSpouses(parent!, onCompletion: {spouses, err in
                    if spouses != nil && spouses!.count > 0 {
                        var couple = [LittlePerson]()
                        couple.append(parent!)
                        for parent2 in spouses! {
                            if parent2 != parent && parents!.contains(parent2) {
                                couple.append(parent2)
                                onCompletion(couple, err);
                                return
                            }
                        }
                    } else {
                        onCompletion(parents, err)
                    }
                })
            }
            else {
                onCompletion(parents, err)
            }
        })
    }
    
    func getSpouses(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let spouses = dbHelper.getSpousesForPerson(person.id!)
        if person.hasSpouses == nil && (spouses == nil || spouses!.count == 0) {
            getSpousesFromRemoteService(person, onCompletion: { people, err in
                if people != nil && people?.count > 0 {
                    if person.hasSpouses == nil || person.hasSpouses == false {
                        person.hasSpouses = true
                        do {
                            try self.dbHelper.persistLittlePerson(person)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                } else if err == nil {
                    if person.hasSpouses == nil || person.hasSpouses == true {
                        person.hasSpouses = false
                        do {
                            try self.dbHelper.persistLittlePerson(person)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                }
                onCompletion(people, err)
            })
        } else {
            if spouses != nil && spouses!.count > 0 {
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
            }
            onCompletion(spouses, nil)
        }
    }
    
    func getChildren(_ person:LittlePerson, onCompletion: @escaping PeopleResponse) {
        let children = dbHelper.getChildrenForPerson(person.id!)
        if person.hasChildren == nil && (children == nil || children!.count == 0) {
            getChildrenFromRemoteService(person, onCompletion: { people, err in
                if people != nil && people?.count > 0  {
                    if person.hasChildren == nil || person.hasChildren == false {
                        person.hasChildren = true
                        do {
                            try self.dbHelper.persistLittlePerson(person)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                } else if err == nil {
                    if person.hasChildren == nil || person.hasChildren == true {
                        person.hasChildren = false
                        do {
                            try self.dbHelper.persistLittlePerson(person)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                }
                onCompletion(people, err)
            })
        } else {
            if children != nil && children!.count > 0 {
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
            }
            onCompletion(children, nil)
        }
    }
    
    func getChildrenForCouple(_ person1:LittlePerson, person2:LittlePerson, onCompletion: @escaping PeopleResponse) {
        self.getChildren(person1, onCompletion: { children1, err in
            self.getChildren(person2, onCompletion: { children2, err in
                var children = [LittlePerson]()
                if children1 != nil && children2 != nil && children1!.count > 0 && children2!.count > 0 {
                    for child1 in children1! {
                        for child2 in children2! {
                            if child1 == child2 {
                                children.append(child1)
                                break
                            }
                        }
                    }
                }
                onCompletion(children, nil)
            })
        })
    }
    
    func processRelatives(_ closeRelatives:[Relationship], person:LittlePerson, onCompletion:@escaping PeopleResponse) {
        var family = [LittlePerson]()
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        for r in closeRelatives {
            if r.person1 != nil && r.person1?.resourceId != nil {
                group.enter()
                getPersonByRemoteId(r.person1!.resourceId!, onCompletion: { person1, err in
                    if person1 != nil && r.person2 != nil && r.person2!.resourceId != nil {
                        self.getPersonByRemoteId(r.person2!.resourceId!, onCompletion: { person2, err in
                            if person2 != nil {
                                let lr = LocalRelationship()
                                lr.id1 = person1?.id
                                lr.id2 = person2?.id
                                var person1changed = false
                                var person2changed = false
                                if r.type == "http://gedcomx.org/Couple" {
                                    lr.type = RelationshipType.spouse
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
                                    lr.type = RelationshipType.parentchild
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
                                        if person == person1! {
                                            person.age = person1!.age
                                            person.treeLevel = person1!.treeLevel
                                        }
                                    } catch let e as NSError {
                                        print(e)
                                    }
                                }
                                if person2changed {
                                    do {
                                        try self.dbHelper.persistLittlePerson(person2!)
                                        if person == person2! {
                                            person.age = person2!.age
                                            person.treeLevel = person2!.treeLevel
                                        }
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
                            group.leave()
                        })
                    } else {
                        group.leave()
                    }
                })
            }
        }
        
        group.notify(queue: queue) {
            onCompletion(family, nil)
        }
    }
    
    func getMediaForPerson(_ person:LittlePerson, onCompletion:@escaping MediaResponse) {
        var media = [Media]()
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let group = DispatchGroup()
        
        var mediaFound = false;
        if (person.hasMedia == nil) {
            group.enter()
            self.remoteService!.getPersonMemories(person.familySearchId!, onCompletion: { sds, err in
                if sds != nil {
                    for sd in sds! {
                        var med = self.dbHelper.getMediaByFamilySearchId(sd.id!)
                        if med == nil {
                            let links = sd.links
                            if links.count > 0 {
                                for link in links {
                                    if (link.rel != nil && link.rel == "image") {
                                        med = Media()
                                        med?.type = "photo"
                                        med?.familySearchId = sd.id
                                        
                                        group.enter()
                                        let oname = self.lastPath(link.href! as String)
                                        let fileName = "\(sd.id!)-\(oname)"
                                        self.remoteService!.downloadImage(link.href!, folderName: person.familySearchId!, fileName: fileName as String, onCompletion: { localPath, err2 in
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
                                            group.leave()
                                        })
                                    }
                                }
                            }
                        } else {
                            media.append(med!)
                        }
                    }
                }
                group.leave()
            })

        } else {
            media = dbHelper.getMediaForPerson(person.id!)
        }
        
        group.notify(queue: queue) {
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
    
	
	func getEncryptedProperty(_ property:String) -> String? {
		let base64 = dbHelper.getProperty(property as String)
        if base64 == nil {
            return nil
        }
        let value = AES128Decryption(base64!)
        return value
	}
	
	func saveEncryptedProperty(_ property:String, value:String) {
        let enc = AES128Encryption(value)
        dbHelper.saveProperty(property, value: enc!)
	}
    
    func addStatusListener(_ listener:StatusListener) {
        var found = false
        for l in listeners {
            if (l as AnyObject) === (listener as AnyObject) {
                found = true
                break
            }
        }
        if !found {
            listeners.append(listener)
        }
    }
    
    func removeStatusListener(_ listener:StatusListener) {
        var index = -1
        var i = -1
        for l in listeners {
            i += 1
            if (l as AnyObject) === (listener as AnyObject) {
                index = i
                break
            }
        }
        
        if index >= 0 {
            listeners.remove(at: index)
        }
    }
    
    func fireStatusUpdate(_ message:String) {
        for l in listeners {
            l.statusChanged(message)
        }
    }
	
	func buildLittlePerson(_ fsPerson:Person, onCompletion: @escaping LittlePersonResponse ) {
		let person = LittlePerson()
		person.name = fsPerson.getFullName()
		person.familySearchId = fsPerson.id
		person.gender = fsPerson.gender
		var name:Name? = nil
		var nickname:Name? = nil
		for n in fsPerson.names {
            if name == nil || (n.preferred != nil && n.preferred == true) {
                name = n
            }
			if nickname == nil && n.type == "http://gedcomx.org/Nickname" {
				nickname = n
			}
        }
		//-- get preferred given name
        if fsPerson.living != nil && fsPerson.living==true && nickname != nil {
            let forms = nickname!.nameForms
            if forms.count > 0 {
                let parts = forms[0].parts
                for p in parts {
					if p.type == "http://gedcomx.org/Given" {
						person.givenName = p.value
						break
					}
				}
            }
        }
		if person.givenName == nil && name != nil {
			let forms = name!.nameForms
			
            let parts = forms[0].parts
            for p in parts {
                if p.type == "http://gedcomx.org/Given" {
                    person.givenName = p.value
                    let gparts = (person.givenName!).characters.split{$0 == " "}.map(String.init)
                    if gparts.count > 1 {
                        person.givenName = gparts[0] as String?
                    }
                    break
                }
            }
		}
		
		if person.givenName == nil && person.name != nil {
			let parts = person.name!.characters.split{$0 == " "}.map(String.init)
			person.givenName = parts[0] as String?
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
			if b.type == "http://gedcomx.org/Occupation" {
				person.occupation = b.value
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
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "dd MMM yyyy"
					person.birthDate = dateFormatter.date(from: birthDateStr!)
					if person.birthDate == nil {
						let df2 = DateFormatter()
						df2.dateFormat = "+yyyy-MM-dd"
						person.birthDate = df2.date(from: birthDateStr!)
						if person.birthDate == nil {
                            do {
                                print("Look for year in \(birthDateStr)")
                                let regex = try NSRegularExpression(pattern: "[0-9]{4}", options: [])
                                let range = NSRangeFromString(birthDateStr!)
                                if range != nil {
                                    if range.location > 1000 {
                                        let year = range.location
                                        let todayDate = Foundation.Date()
                                        let currYear = (Calendar.current as NSCalendar).component(.year, from: todayDate)
                                        person.age = currYear - year
                                        let df3 = DateFormatter()
                                        df3.dateFormat = "yyyy"
                                        person.birthDate = df3.date(from: "\(year)")
                                    } else if range.location + range.length < birthDateStr?.characters.count {
                                        let results = regex.firstMatch(in: birthDateStr!, options:[], range: range)
                                        if results != nil {
                                            let nsB = birthDateStr! as NSString
                                            let yearStr = nsB.substring(with: results!.range)
                                            let year = Int(yearStr)
                                            let todayDate = Foundation.Date()
                                            let currYear = (Calendar.current as NSCalendar).component(.year, from: todayDate)
                                            person.age = currYear - year!
                                            let df3 = DateFormatter()
                                            df3.dateFormat = "yyyy"
                                            person.birthDate = df3.date(from: yearStr)
                                        }
                                    }
                                }
                            } catch let error as NSException {
                                print("Unable to create birthdate from \(birthDateStr) \(error)")
                            } catch {
                                print("Unable to create birthdate from \(birthDateStr)")
                            }
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
		
		person.lastSync = Foundation.Date()
		
		remoteService!.getPersonPortrait(person.familySearchId!, onCompletion: {link, err1 in
			if self.remoteService!.sessionId != nil && link != nil && link!.href != nil {
				self.remoteService!.downloadImage(link!.href!, folderName: person.familySearchId!, fileName: self.lastPath(link!.href! as String), onCompletion: { path, err2 in
					person.photoPath = path
					onCompletion( person, err2)
				})
			} else {
				onCompletion( person, err1)
			}
		})
	}
	
	func lastPath(_ href:String) -> String {
		let parts = href.characters.split{$0 == "/"}.map(String.init)
		var i = parts.count - 1
		repeat {
            let part = parts[i]
            if !parts.isEmpty {
                var filePath = parts[i]
				if let idx = filePath.characters.index(of: "?") {
                    filePath = filePath.substring(to: idx);
                }
                return filePath
            }
			i -= 1
        } while i >= 0
        return href as String;
    }
    
    func AES128Encryption(_ message:String) -> String?
    {
        let uuid = dbHelper.getProperty(DBHelper.UUID_PROPERTY)
        let keyString        = uuid?.substring(to: uuid!.characters.index(uuid!.startIndex, offsetBy: 32))
        let keyData: Data! = (keyString! as String).data(using: String.Encoding.utf8) as Data!
        
        var keyMemory = [UInt8](repeating:0, count:keyData!.count)
        keyData.copyBytes(to: &keyMemory, count: keyData!.count)
        
        let keyBytes         = UnsafeMutableRawPointer(mutating: keyMemory)
        print("keyLength   = \(keyData.count), keyData   = \(keyData)")
        
        let data: Data! = (message as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Data!
        let dataLength    = size_t(data.count)
        
        var dataMemory = [UInt8](repeating:0, count:data!.count)
        data.copyBytes(to: &dataMemory, count: data!.count)
        
        let dataBytes     = UnsafeMutableRawPointer(mutating: dataMemory)
        print("dataLength  = \(dataLength), data      = \(data)")
        
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = cryptData!.mutableBytes
        let cryptLength  = size_t(cryptData!.length)
        
        let keyLength              = size_t(kCCKeySizeAES256)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes, keyLength,
            nil,
            dataBytes, dataLength,
            cryptPointer, cryptLength,
            &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            //  let x: UInt = numBytesEncrypted
            cryptData!.length = Int(numBytesEncrypted)
            print("cryptLength = \(numBytesEncrypted), cryptData = \(cryptData)")
            
            // Not all data is a UTF-8 string so Base64 is used
            let base64cryptString = cryptData!.base64EncodedString(options: .lineLength64Characters)
            print("base64cryptString = \(base64cryptString)")
            
            return base64cryptString
        } else {
            print("Error: \(cryptStatus)")
        }
        return nil
    }
    
    func AES128Decryption(_ enc:String) -> String? //data = cryptData
    {
        let uuid = dbHelper.getProperty(DBHelper.UUID_PROPERTY)
        let keyString        = uuid?.substring(to: uuid!.characters.index(uuid!.startIndex, offsetBy: 32))
        let keyData: Data! = (keyString! as String).data(using: String.Encoding.utf8) as Data!
        
        var keyMemory = [UInt8](repeating:0, count:keyData!.count)
        keyData.copyBytes(to: &keyMemory, count: keyData!.count)
        let keyBytes         = UnsafeMutableRawPointer(mutating: keyMemory)
        print("keyLength   = \(keyData.count), keyData   = \(keyData)")
        
        let data: Data! = Data(base64Encoded: enc, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        //let data: NSData! = (enc as String).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let dataLength    = size_t(data.count)
        
        var dataMemory = [UInt8](repeating:0, count:data!.count)
        data.copyBytes(to: &dataMemory, count: data!.count)
        
        let dataBytes     = UnsafeMutableRawPointer(mutating: dataMemory)
        print("dataLength  = \(dataLength), data      = \(data)")
        
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
        let cryptPointer = cryptData!.mutableBytes
        let cryptLength  = size_t(cryptData!.length)
        
        let keyLength              = size_t(kCCKeySizeAES256)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes, keyLength,
            nil,
            dataBytes, dataLength,
            cryptPointer, cryptLength,
            &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            //  let x: UInt = numBytesEncrypted
            cryptData!.length = Int(numBytesEncrypted)
            print("DecryptcryptLength = \(numBytesEncrypted), Decrypt = \(cryptData)")
            
            // Not all data is a UTF-8 string so Base64 is used
            let base64cryptString = cryptData!.base64EncodedString(options: .lineLength64Characters)
            print("base64DecryptString = \(base64cryptString)")
            let value = String(data: cryptData! as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            //print( "utf8 actual string = \(value)");
            return value as String?
        } else {
            print("Error: \(cryptStatus)")
        }
        return nil
    }
}
