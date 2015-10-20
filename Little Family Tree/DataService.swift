import Foundation

class DataService {
	var remoteService:RemoteService?
	var serviceType:NSString?
	var dbHelper:DBHelper?

	private static let instance:DataService?
	
	static func getInstance() -> DataService {
		if instance == nil {
			instance = DataService()
		}
		return instance
	}
	
	func init() {
		dbHelper = DBHelper.getInstance()
	}
}