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
		if diff < -60 || person.hasParents == nil || person.treeLevel == nil || (person.treeLevel! <= 1 && person.hasChildren == nil) {
			if !syncQ.contains(person) {
				dbHelper.addToSyncQ(person.id!)
				syncQ.append(person)
			}
		}
	}
    
    func start() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "processNextInQ", userInfo: nil, repeats: true)
    }
	
	func processNextInQ() {
		if dataService.remoteService != nil && dataService.remoteService!.sessionId != nil && syncQ.count > 0 {
			let person = syncQ.removeFirst()
			let operation = SyncOperation(person: person)
			queue.addOperation(operation)
		}
		print("Sync Q has \(syncQ.count) people in it.");
	}
	
	func syncPerson(person:LittlePerson, onCompletion: LittlePersonRespons) {
		dataService.remoteService.getPerson(person.familySearchId, { fsPerson, err in
			if (fsPerson == nil && err == nil) || fsPerson.transientProperty["deleted"] != nil {
				dbHelper.deletePersonById(person.id)
				onCompletion(nil, nil)
			} else {
				dataService.buildLittlePerson(fsPerson!, onCompletion: { (updated, err2) -> Void in
					if updated != nil {
						do {
							updated.id = person.id
							person.lastSync = updated.lastSync
							person.photoPath = updated.photoPath
							person.age = updated.age
							person.birthDate = updated.birthDate
							person.birthPlace = updated.birthPlace
							person.alive = updated.alive
							person.familySearchId = updated.familySearchId
							person.gender = updated.gender
							person.givenName = updated.givenName
							person.name = updated.name
							person.nationality = updated.nationality
							person.updateAge()
							dbHelper.persistLittlePerson(person)
							
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

	class SyncOperation : NSOperation {
		var person:LittlePerson
		
		init(person:LittlePerson) {
			self.person = person
		}
		
		override func main() {
			if self.cancelled {
				return
			}
			
			let dbHelper = DBHelper.getInstance()
			dbHelper.removeFromSyncQ(person.id!)
			
			print("Synchronizing person \(person.id!) \(person.familySearchId!) \(person.name!)")
			
			dataService.remoteService.getLastChangeForPerson(person.familySearchId!, { timestamp, err in 
				if timestamp != nil {
					print("Local date=\(person.lastSync) remote date=\(timestamp)")
				}
				if timestamp == nil || person.lastSync == nil || timestamp > person.lastSync?.timeIntervalSince1970 {
					syncPerson(person, {updatedPerson, err in 
						//-- update person's lastsync date
						updatedPerson.lastSync = NSDate()
						do {
							try dbHelper.persistLittlePerson(updatedPerson)
						} catch {
							print("Unable to persist person \(updatedPerson.id!)")
						}
					})
				}
			})
		}
	}
}