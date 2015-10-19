import Foundation

class DataService {
	var remoteService:RemoteService?
	var serviceType:NSString?

	static let instance = DataService()
	
	static func getInstance() -> DataService {
		return instance
	}
	
	
}