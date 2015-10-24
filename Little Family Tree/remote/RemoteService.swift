import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void
typealias PersonResponse = (Person?, NSError?) -> Void
typealias LinkResponse = (Link?, NSError?) -> Void
typealias RelationshipsResponse = ([Relationship]?, NSError?) -> Void
typealias SourceDescriptionsResponse = ([SourceDescription]?, NSError?) -> Void
typealias StringResponse = (NSString?, NSError?) -> Void
typealias LongResponse = (Int?, NSError?) -> Void

protocol RemoteService {
	//var sessionId: NSString { get set}
	func authenticate(username: String, password: String, onCompletion: ServiceResponse)
	func getCurrentPerson(onCompletion: PersonResponse)
	func getPerson(personId: NSString, onCompletion: PersonResponse)
	func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse)
	func getPersonPortrait(personId: NSString, onCompletion: LinkResponse)
	func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse)
	func getParents(personId: NSString, onCompletion: RelationshipsResponse)
	func getChildren(personId: NSString, onCompletion: RelationshipsResponse)
	func getSpouses(personId: NSString, onCompletion: RelationshipsResponse)
	func getPersonMemories(personId: NSString, onCompletion: SourceDescriptionsResponse)
	func downloadImage(uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse)
	func getPersonUrl(personId: NSString) -> NSString
}