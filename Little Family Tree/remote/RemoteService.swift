import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void
typealias PersonResponse = (Person, NSError?) -> Void
typealias LinkResponse = (Link, NSError?) -> Void
typealias RelationshipsResponse = ([Relationship], NSError?) -> Void
typealias SourceDescriptionsResponse = ([SourceDescription], NSError?) -> Void
typealias StringResponse = (NSString, NSError?) -> Void

protocol RemoteService {
	//var sessionId: NSString { get set}
	func authenticate(username: String, password: String)
	func getCurrentPerson(onCompletion: ServiceResponse)
	func getPerson(personId: NSString, onCompletion: PersonResponse)
	func getLastChangeForPerson(personId: NSString)
	func getPersonPortrait(personId: NSString, onCompletion: LinkResponse)
	func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse)
	func getParents(personId: NSString, onCompletion: RelationshipsResponse)
	func getChildren(personId: NSString, onCompletion: RelationshipsResponse)
	func getSpouses(personId: NSString, onCompletion: RelationshipsResponse)
	func getPersonMemories(personId: NSString)
	func downloadImage(uri: NSString, folderName: NSString, fileName: NSString)
	func getPersonUrl(personId: NSString) -> NSString

}