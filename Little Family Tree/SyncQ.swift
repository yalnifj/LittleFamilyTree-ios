import Foundation

class SyncQ : NSObject {
	var syncQ:[LittlePerson]
	var dataService:DataService
	var dbHelper:DBHelper
	var timer:NSTimer?
    var started = false
	lazy var queue:NSOperationQueue = {
		var queue = NSOperationQueue()
		queue.name = "Sync queue"
		queue.maxConcurrentOperationCount = 1
		return queue
    }()
	
	static var instance:SyncQ?
	
	static func getInstance() -> SyncQ {
		if instance == nil {
			instance = SyncQ()
		}
		return instance!
	}
	
	private override init() {
		syncQ = [LittlePerson]()
		dataService = DataService.getInstance()
		dbHelper = DBHelper.getInstance()
        super.init()
	}
	
	func addToSyncQ(person:LittlePerson) {
        if !started {
            start()
        }
		let diff = person.lastSync!.timeIntervalSinceNow
		if diff < -3600 || person.hasParents == nil || person.treeLevel == nil || (person.treeLevel! <= 1 && person.hasChildren == nil) {
			if !syncQ.contains(person) {
				dbHelper.addToSyncQ(person.id!)
				syncQ.append(person)
			}
		}
	}
    
    func start() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "processNextInQ", userInfo: nil, repeats: true)
        started = true
    }
	
	func processNextInQ() {
		if dataService.remoteService != nil && dataService.remoteService!.sessionId != nil && syncQ.count > 0 {
			let person = syncQ.removeFirst()
			let operation = SyncOperation(person: person, syncQ: self)
			queue.addOperation(operation)
		}
        let date = NSDate()
		print("\(date) Sync Q has \(syncQ.count) people in it.");
	}
	
	func syncPerson(person:LittlePerson, onCompletion: LittlePersonResponse) {
        self.dataService.remoteService!.getPerson(person.familySearchId!, ignoreCache: true, onCompletion: { fsPerson, err in
            if (fsPerson == nil && err == nil) { //|| fsPerson.transientProperty["deleted"] != nil {
                try! self.dbHelper.deletePersonById(person.id!)
                onCompletion(nil, nil)
            } else if fsPerson != nil {
                self.dataService.buildLittlePerson(fsPerson!, onCompletion: { (updated, err2) -> Void in
                    if updated != nil {
                            updated!.id = person.id
                            person.lastSync = updated!.lastSync
                            person.photoPath = updated!.photoPath
                            person.age = updated!.age
                            person.birthDate = updated!.birthDate
                            person.birthPlace = updated!.birthPlace
                            person.alive = updated!.alive
                            person.familySearchId = updated!.familySearchId
                            person.gender = updated!.gender
                            person.givenName = updated!.givenName
                            person.name = updated!.name
                            person.nationality = updated!.nationality
                            person.updateAge()
                            
                            //-- sync close relatives
							self.dataService.remoteService!.getCloseRelatives(person.familySearchId!, onCompletion: { closeRelatives, err in 
								if (closeRelatives != nil) {
									let oldRelations = self.dbHelper.getRelationshipsForPerson(person.id!)
									var newRelations = [LocalRelationship]()
									for r in closeRelatives! {
										var type = RelationshipType.PARENTCHILD
										if r.type == "http://gedcomx.org/Couple" {
											type = RelationshipType.SPOUSE
										}
										self.syncRelationship(r.person1!.resourceId as! String, fsid2: r.person2!.resourceId as! String, type: type, onCompletion: { rels, err in
											if (rels != nil && rels!.count > 0) {
                                                for rel in rels! {
                                                    newRelations.append(rel)
                                                }
											}
										})
									}
									// TODO use a dispatch group
									//for rel in oldRelations! {
									//	if !newRelations.contains(rel) {
									//		self.dataService.dbHelper.deleteRelationshipById(rel.id);
									//	}
									//}
								} else {
									//-- person no longer has relationships so deleted them all
									let oldRelations = self.dataService.dbHelper.getRelationshipsForPerson(person.id!)
									if (oldRelations != nil) {
										for rel in oldRelations! {
											self.dataService.dbHelper.deleteRelationshipById(rel.id)
										}
									}
									person.hasChildren = false
									person.hasSpouses = false
									person.hasParents = false
                                    do {
                                        try self.dbHelper.persistLittlePerson(person)
                                    } catch {
                                        onCompletion(nil, NSError(domain: "LittleFamily", code: 404, userInfo: ["message":"Unable to persist little person"]))
                                    }
								}
							})
							
                            //-- sync memories
                            
							// TODO use a dispatch group
                            onCompletion(updated, err2)
                        
                    }
                })
            }
        })
    }
	
	func syncRelationship(fsid1:String, fsid2:String, type:RelationshipType, onCompletion: LocalRelationshipResponse) {
		dataService.getPersonByRemoteId(fsid1, onCompletion: { person, err in 
			self.dataService.getPersonByRemoteId(fsid2, onCompletion: { relative, err in 
				if (person != nil && relative != nil) {
					var personChanged = false;
					var relativeChanged = false;
					var rel = self.dbHelper.getRelationship(person!.id!, id2: relative!.id!, type: type)
					if (rel == nil) {
						rel = LocalRelationship()
						rel!.id1 = person!.id
						rel!.id2 = relative!.id
						rel!.type = type
						self.dbHelper.persistRelationship(rel!);
					}

					if (rel!.type == RelationshipType.SPOUSE) {
						if (person!.hasSpouses == nil || person!.hasSpouses == false) {
							person!.hasSpouses = true
							personChanged = true
						}
						if (relative!.hasSpouses == nil || relative!.hasSpouses == false) {
							relative!.hasSpouses = true
							relativeChanged = true;
						}
						if (person!.treeLevel == nil && relative!.treeLevel != nil) {
							person!.treeLevel = relative!.treeLevel
							personChanged = true
						}
						if (relative!.treeLevel == nil && person!.treeLevel != nil) {
							relative!.treeLevel = person!.treeLevel
							relativeChanged = true;
						}
						if (person!.age == nil && relative!.age != nil) {
							person!.age = relative!.age
							personChanged = true
						}
						if (relative!.age == nil && person!.age != nil) {
							relative!.age = person!.age
							relativeChanged = true
						}
					} else {
						if (person!.hasChildren == nil || person!.hasChildren == false) {
							person!.hasChildren = true
							personChanged = true
						}
						if (person!.treeLevel == nil && relative!.treeLevel != nil) {
							person!.treeLevel = relative!.treeLevel! + 1
							personChanged = true
						}
						if (relative!.age == nil && person!.age != nil) {
							relative!.age = person!.age! - 25
							relativeChanged = true
						}


						if (relative!.hasParents == nil || relative!.hasParents == false) {
							relative!.hasParents = true
							relativeChanged = true
						}
						if (relative!.treeLevel == nil && person!.treeLevel != nil) {
							relative!.treeLevel = person!.treeLevel! - 1
							relativeChanged = true
						}
						if (person!.age == nil && relative!.age != nil) {
							person!.age = relative!.age! + 25
							personChanged = true
						}
					}

					if (personChanged) {
                        do {
                            try self.dbHelper.persistLittlePerson(person!)
                        } catch {
                        }
					}
					if (relativeChanged) {
                        do {
                            try self.dbHelper.persistLittlePerson(relative!)
                        } catch { }
					}
                    
                    onCompletion([rel!], nil)
					//return rel;
				}
			})
		})
	}
	
}

class SyncOperation : NSOperation {
    var person:LittlePerson
    var dataService:DataService
	var syncQ:SyncQ
    
    init(person:LittlePerson, syncQ:SyncQ) {
        self.person = person
		self.syncQ = syncQ
        self.dataService = syncQ.dataService
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        let dbHelper = DBHelper.getInstance()
        dbHelper.removeFromSyncQ(person.id!)
        
        print("Synchronizing person \(person.id!) \(person.familySearchId!) \(person.name!)")
        
        dataService.remoteService!.getLastChangeForPerson(person.familySearchId!, onCompletion: { timestamp, err in
            if timestamp != nil {
                print("Local date=\(self.person.lastSync) remote date=\(timestamp)")
            }
            if timestamp == nil || self.person.lastSync == nil
                    || timestamp!/1000 > Int64((self.person.lastSync?.timeIntervalSince1970)!) {
                self.syncQ.syncPerson(self.person, onCompletion: {updatedPerson, err in
                    //-- update person's lastsync date
                    if updatedPerson != nil {
                        updatedPerson!.lastSync = NSDate()
                        do {
                            try dbHelper.persistLittlePerson(updatedPerson!)
                        } catch {
                            print("Unable to persist person \(updatedPerson!.id!)")
                        }
                    }
                })
            }
        })
    }
}