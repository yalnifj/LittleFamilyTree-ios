import Foundation
import SpriteKit

class FamilySearchService : RemoteService {
	let FS_PLATFORM_PATH = "https://sandbox.familysearch.org/platform/";
	//static let FS_PLATFORM_PATH = "https://familysearch.org/platform/";
	
	let FS_OAUTH2_PATH = "https://sandbox.familysearch.org/cis-web/oauth2/v3/token";
	//static let FS_OAUTH2_PATH = "https://ident.familysearch.org/cis-web/oauth2/v3/token";
	
	private let FS_APP_KEY = "a02j0000009AXffAAG";

    var sessionId: NSString?
	
	static let sharedInstance = FamilySearchService()
	
	
	func authenticate(username: NSString, password: NSString, onCompletion: ServiceResponse) {
		var params = [String: String]()
		params["grant_type"] = "password";
        params["client_id"] = FS_APP_KEY;
        params["username"] = username as String;
        params["password"] = password as String;
		
		sessionId = nil;
		let headers = [String: String]()
		
		makeHTTPPostRequest(FS_OAUTH2_PATH, body: params, headers: headers, onCompletion: {json, err in
			self.sessionId = json["access_token"].description
			onCompletion(json, err)
		})
	}
	
    func getCurrentPerson(onCompletion: PersonResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-gedcomx-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/current-person", headers: headers, onCompletion: {json, err in
				let persons = Person.convertJsonToPersons(json)
				if persons.count > 0 {
                    let person = persons[0]
					onCompletion(person, err)
				} else {
					onCompletion(nil, NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find current person"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getPerson(personId: NSString, onCompletion: PersonResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-gedcomx-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)", headers: headers, onCompletion: {json, err in
				var persons = Person.convertJsonToPersons(json)
				if persons.count > 0 {
					let person = persons[0]
					onCompletion(person, err)
				} else {
					onCompletion(nil, NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find person with id " + personId.description]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-gedcomx-atom+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/changes", headers: headers, onCompletion: {json, err in
				if json["entries"] != nil {
					let ae = json["entries"].array!
					if ae.count > 0 {
						let entry = ae[0]
						let timestamp = entry["updated"]
						onCompletion(timestamp.intValue, err)
					}
				}
				onCompletion(nil, NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find portraits for person with id \(personId)"]))
            })
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getPersonPortrait(personId: NSString, onCompletion: LinkResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-gedcomx-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/portraits", headers: headers, onCompletion: {json, err in
				let sds = SourceDescription.convertJsonToSourceDescriptions(json)
				if sds.count > 0 {
					for sd in sds {
						if sd.links.count > 0 {
							for link in sd.links {
								if link.rel != nil && link.rel == "image-thumbnail" {
									onCompletion(link, err)
                                    return
                                }
							}
						}
					}
					onCompletion(nil, NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find portraits for person with id \(personId)"]))
				} else {
					onCompletion(nil, NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons-with-relationships?person=\(personId)", headers: headers, onCompletion: {json, err in
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getParents(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/parent-relationships", headers: headers, onCompletion: {json, err in
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getChildren(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/child-relationships", headers: headers, onCompletion: {json, err in
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getSpouses(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/spouse-relationships", headers: headers, onCompletion: {json, err in
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getPersonMemories(personId: NSString, onCompletion: SourceDescriptionsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/memories", headers: headers, onCompletion: {json, err in
				let sds = SourceDescription.convertJsonToSourceDescriptions(json)
				onCompletion(sds, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func downloadImage(uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: uri as String)!)
 
        let session = NSURLSession.sharedSession()
		var headers = [String: String]()
		headers["Authorization"] = "Bearer " + (sessionId?.description)!
		headers["Accept"] = "application/x-fs-v1+json"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
 
        let task = session.dataTaskWithRequest(request, completionHandler: {(data: NSData?,  response: NSURLResponse?, error: NSError?) -> Void in
			let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
			if UIImage(data: data!) != nil {
                do {
                    let folderPath = paths.stringByAppendingString("/\(folderName)" )
                    if !fileManager.fileExistsAtPath(folderPath) {
                        try fileManager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
                    }
				
                    let imagePath = paths.stringByAppendingString("/\(folderName)/\(fileName)" )
                    try data!.writeToFile(imagePath, options: NSDataWritingOptions.AtomicWrite)
                    onCompletion(imagePath, error);
                } catch {
                    onCompletion(nil, NSError(domain: "FamilySearchService", code: 500, userInfo: ["message":"Unable to download and save image"]))
                }
			}
        })
        task.resume()
	}
	
	func getPersonUrl(personId: NSString) -> NSString {
		return "https://familysearch.org/tree/#view=ancestor&person=\(personId)";
	}
	
    func makeHTTPGetRequest(path: String, headers: [String: String], onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
 
        let session = NSURLSession.sharedSession()
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
 
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
	
    func makeHTTPPostJSONRequest(path: String, body: [String: AnyObject], headers: [String: String], onCompletion: ServiceResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
        
        do {
	 
            // Set the POST body for the request
            let options = NSJSONWritingOptions()
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: options)
            let session = NSURLSession.sharedSession()
	 
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            })
            task.resume()
        } catch let aError as NSError {
            print(aError)
        }
	}
	
    func makeHTTPPostRequest(path: String, body: [String: String], headers: [String: String], onCompletion: ServiceResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
	 
		// Set the POST body for the request
		var postString = ""
		for(param, value) in body {
			postString += "\(param)=\(value)&";
		}

		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
	 
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			let json:JSON = JSON(data: data!)
			onCompletion(json, error)
		})
		task.resume()
	}
}