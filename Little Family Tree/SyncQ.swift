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
                try! self.dataService.dbHelper.deletePersonById(person.id!)
                onCompletion(nil, nil)
            } else {
                self.dataService.buildLittlePerson(fsPerson!, onCompletion: { (updated, err2) -> Void in
                    if updated != nil {
                        do {
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
							self.dataService.remoteService.getCloseRelatives(person.familySearchId!, onCompletion: { closeRelatives, err in 
								if (closeRelatives != nil) {
									let oldRelations = self.dataService.dbHelper().getRelationshipsForPerson(person.id!)
									var newRelations = [LocalRelationship]()
									for r in closeRelatives! {
										let type = RelationshipType.PARENTCHILD
										if r.type == "http://gedcomx.org/Couple" {
											type = RelationshipType.SPOUSE
										}
										self.syncRelationship(r.person1.resourceId, r.person2.resourceId, type, onCompletion: { rel, err in
											if (rel != nil) {
												newRelations.append(rel)
											}
										})
									}
									// TODO use a dispatch group
									for  rel : oldRelations {
										if !newRelations.contains(rel) {
											self.dataService.dbHelper.deleteRelationshipById(rel.id);
										}
									}
								} else {
									//-- person no longer has relationships so deleted them all
									let oldRelations = self.dataService.dbHelper.getRelationshipsForPerson(person.id)
									if (oldRelations != nil) {
										for rel in oldRelations {
											self.dataService.dbHelper.deleteRelationshipById(rel.id)
										}
									}
									person.hasChildren = false
									person.hasSpouses = false
									person.hasParents = false
									self.dataService.dbHelper.persistLittlePerson(person)
								}
							})
							
                            //-- sync memories
                            
							// TODO use a dispatch group
                            onCompletion(updated, err2)
                        } catch {
                            onCompletion(nil, NSError(domain: "LittleFamily", code: 404, userInfo: ["message":"Unable to persist little person"]))
                        }
                    }
                })
            }
        })
    }
	
	func syncRelationship(fsid1:String, fsid2:String, type:RelationshipType, onCompletion: LocalRelationshipResponse) {
		dataService.getPersonByRemoteId(fsid1, onCompletion: { person, err in 
			dataService.getPersonByRemoteId(fsid2, onCompletion: { relative, err in 
				if (person !=null && relative!=null) {
					boolean personChanged = false;
					boolean relativeChanged = false;
					com.yellowforktech.littlefamilytree.data.Relationship rel = getDBHelper().getRelationship(person.getId(), relative.getId(), type);
					if (rel==null) {
						rel = new com.yellowforktech.littlefamilytree.data.Relationship();
						rel.setId1(person.getId());
						rel.setId2(relative.getId());
						rel.setType(type);
						getDBHelper().persistRelationship(rel);
					}

					if (rel.getType() == com.yellowforktech.littlefamilytree.data.RelationshipType.SPOUSE) {
						if (person.isHasSpouses()==null || person.isHasSpouses()==false) {
							person.setHasSpouses(true);
							personChanged = true;
						}
						if (relative.isHasSpouses()==null || relative.isHasSpouses()==false) {
							relative.setHasSpouses(true);
							relativeChanged = true;
						}
						if (person.getTreeLevel()==null && relative.getTreeLevel()!=null) {
							person.setTreeLevel(relative.getTreeLevel());
							personChanged = true;
						}
						if (relative.getTreeLevel()==null && person.getTreeLevel()!=null) {
							relative.setTreeLevel(person.getTreeLevel());
							relativeChanged = true;
						}
						if (person.getAge() == null && relative.getAge() != null) {
							person.setAge(relative.getAge());
							personChanged = true;
						}
						if (relative.getAge() == null && person.getAge() != null) {
							relative.setAge(person.getAge());
							relativeChanged = true;
						}
					} else {
						if (person.isHasChildren()==null || person.isHasChildren()==false) {
							person.setHasChildren(true);
							personChanged = true;
						}
						if (person.getTreeLevel()==null && relative.getTreeLevel()!=null) {
							person.setTreeLevel(relative.getTreeLevel() + 1);
							personChanged = true;
						}
						if (relative.getAge() == null && person.getAge() != null) {
							relative.setAge(person.getAge() - 25);
							relativeChanged = true;
						}


						if (relative.isHasParents()==null || relative.isHasParents()==false) {
							relative.setHasParents(true);
							relativeChanged = true;
						}
						if (relative.getTreeLevel()==null && person.getTreeLevel()!=null) {
							relative.setTreeLevel(person.getTreeLevel()-1);
							relativeChanged = true;
						}
						if (person.getAge() == null && relative.getAge() != null) {
							person.setAge(relative.getAge() + 25);
							personChanged = true;
						}
					}

					if (personChanged) {
						getDBHelper().persistLittlePerson(person);
					}
					if (relativeChanged) {
						getDBHelper().persistLittlePerson(relative);
					}

					return rel;
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