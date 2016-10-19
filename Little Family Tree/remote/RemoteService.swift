import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void
typealias PersonResponse = (Person?, NSError?) -> Void
typealias LinkResponse = (Link?, NSError?) -> Void
typealias RelationshipsResponse = ([Relationship]?, NSError?) -> Void
typealias SourceDescriptionsResponse = ([SourceDescription]?, NSError?) -> Void
typealias StringResponse = (NSString?, NSError?) -> Void
typealias LongResponse = (Int64?, NSError?) -> Void

protocol RemoteService {
	var sessionId: NSString? { get set }
	func authenticate(_ username: String, password: String, onCompletion: @escaping StringResponse)
	func getCurrentPerson(_ onCompletion: PersonResponse)
    func getPerson(_ personId: NSString, ignoreCache: Bool, onCompletion: PersonResponse)
	func getLastChangeForPerson(_ personId: NSString, onCompletion: LongResponse)
	func getPersonPortrait(_ personId: NSString, onCompletion: LinkResponse)
	func getCloseRelatives(_ personId: NSString, onCompletion: RelationshipsResponse)
	func getParents(_ personId: NSString, onCompletion: RelationshipsResponse)
	func getChildren(_ personId: NSString, onCompletion: RelationshipsResponse)
	func getSpouses(_ personId: NSString, onCompletion: RelationshipsResponse)
	func getPersonMemories(_ personId: NSString, onCompletion: SourceDescriptionsResponse)
	func downloadImage(_ uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse)
	func getPersonUrl(_ personId: NSString) -> NSString
}

protocol LoginCompleteListener {
    func LoginComplete()
    func LoginCanceled()
}
