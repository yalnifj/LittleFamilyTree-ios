import Foundation

class SyncQ {
	var syncQ:[LittlePerson]
	var dataService:DataService
	var dbHelper:DBHelper
	var timer:NSTimer
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
		return instance
	}
	
	private init() {
		syncQ = [LittlePerson]()
		dataService = DataService.getInstance()
		dbHelper = DBHelper.getInstance()
		timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "processNextInQ", userInfo: nil, repeats: true)
	}
	
	func addToSyncQ(person:LittlePerson) {
		let diff = person.lastSync!.timeIntervalSinceNow
		if diff < -60 || person.hasParents == nil || person.treeLevel == nil || (person.treeLevel! <= 1 && person.hasChildren == nil) {
			if !syncQ.contains(person) {
				dbHelper.addToSyncQ(person.id)
				syncQ.append(person)
			}
		}
	}
	
	func processNextInQ() {
		if dataService.remoteService != nil && dataService.remoteService!.sessionId != nil && syncQ.count > 0 {
			let person = syncQ.removeFirst()
			let operation = SyncOperation(person)
			queue.addOperation(operation)
		}
	}
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
		dbHelper.removeFromSyncQ(person.id)
		
		print("Synchronizing person \(person.id) \(person.familySearchId) \(person.name)")
		
	}
}