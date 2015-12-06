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
			let operation = SyncOperation(person: person, dataService: self.dataService)
			queue.addOperation(operation)
		}
        let date = NSDate()
		print("\(date) Sync Q has \(syncQ.count) people in it.");
	}
	
}

class SyncOperation : NSOperation {
    var person:LittlePerson
    var dataService:DataService
    
    init(person:LittlePerson, dataService:DataService) {
        self.person = person
        self.dataService = dataService
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
                self.syncPerson(self.person, onCompletion: {updatedPerson, err in
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
    
    func syncPerson(person:LittlePerson, onCompletion: LittlePersonResponse) {
        dataService.remoteService!.getPerson(person.familySearchId!, ignoreCache: true, onCompletion: { fsPerson, err in
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
                            //-- sync memories
                            
                            onCompletion(updated, err2)
                        } catch {
                            onCompletion(nil, NSError(domain: "LittleFamily", code: 404, userInfo: ["message":"Unable to persist little person"]))
                        }
                    }
                })
            }
        })
    }
	
}