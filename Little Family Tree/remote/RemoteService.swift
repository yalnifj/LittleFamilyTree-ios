import Foundation

protocol RemoteService {
	//var sessionId: NSString { get set}
	func authenticate(username: String, password: String)
	func getCurrentPerson()
	func getPerson(personId: NSString)
	func getLastChangeForPerson(personId: NSString)
	func getPersonPortrait(personId: NSString)
	func getCloseRelatives(personId: NSString)
	func getParents(personId: NSString)
	func getChildren(personId: NSString)
	func getSpouses(personId: NSString)
	func getPersonMemories(personId: NSString)
	func downloadImage(uri: NSString, folderName: NSString, fileName: NSString)
	func getPersonUrl(personId: NSString)

}