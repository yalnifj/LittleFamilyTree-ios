import Foundation

class DataService {
	static let SERVICE_TYPE = "service_type"
    static let SERVICE_TYPE_PHPGEDVIEW = "PGVService"
    static let SERVICE_TYPE_FAMILYSEARCH = "FamilySearchService"
    static let SERVICE_TOKEN = "Token"
    static let SERVICE_BASEURL = "BaseUrl"
    static let SERVICE_DEFAULTPERSONID = "DefaultPersonId"
    static let SERVICE_USERNAME= "Username"
    static let ROOT_PERSON_ID = "Root_Person_id"

	var remoteService:RemoteService?
	var serviceType:NSString?
	var dbHelper:DBHelper?
	var authenticating:Bool = false

	private static let instance:DataService?
	
	static func getInstance() -> DataService {
		if instance == nil {
			instance = DataService()
		}
		return instance
	}
	
	private func init() {
		dbHelper = DBHelper.getInstance()
		self.serviceType = dbHelper.getProperty(SERVICE_TYPE)
		if serviceType != nil {
			if serviceType == SERVICE_TYPE_FAMILYSEARCH {
				self.remoteService = FamilySearchService.sharedInstance
			}
			/*
			else if serviceType == SERVICE_TYPE_FAMILYSEARCH {
			}
			*/
			if remoteService.sessionId == nil {
				autoLogin()
			}
		}
	}
	
	func setRemoteService(type:NSString, service:RemoteService) {
		self.serviceType = type
		self.remoteService = service
	}
	
	func autoLogin() {
		let username = getProperty("username")
		let token = getEncryptedProperty(serviceType + SERVICE_TOKEN)
		if token != nil {
			if remoteService.sessionId == nil && !authenticating {
				authenticating = true
				remoteService.authenticate(username, token, onCompletion: { json, err in 
					authenticating = false
					
				})
			}
		}
	}
	
	func getEncryptedProperty(property:NSString) -> NSString? {
		return dbHelper.getProperty(property)
	}
	
	func saveEncryptedProperty(property:NSString, value:NSString) {
		dbHelper.saveProperty(property, value)
	}
}