import Foundation
import SpriteKit

class FamilySearchService : RemoteService {
	let FS_PLATFORM_PATH = "https://sandbox.familysearch.org/platform/"
    //let FS_PLATFORM_PATH = "https://beta.familysearch.org/platform/"
	//let FS_PLATFORM_PATH = "https://familysearch.org/platform/"
	
	let FS_OAUTH2_PATH = "https://sandbox.familysearch.org/cis-web/oauth2/v3/token"
    //let FS_OAUTH2_PATH = "https://identbeta.familysearch.org/cis-web/oauth2/v3/token"
	//let FS_OAUTH2_PATH = "https://ident.familysearch.org/cis-web/oauth2/v3/token"
	
	private let FS_APP_KEY = "a02j0000009AXffAAG"
    //private let FS_APP_KEY = "a0T3000000BM5hcEAD"

    var sessionId: NSString?
    var personCache = [String: Person]()
	
	static let sharedInstance = FamilySearchService()
	
	
	func authenticate(username: String, password: String, onCompletion: ServiceResponse) {
		var params = [String: String]()
		params["grant_type"] = "password";
        params["client_id"] = FS_APP_KEY;
        params["username"] = username;
        params["password"] = password;
		
		sessionId = nil;
		let headers = [String: String]()
		
		makeHTTPPostRequest(FS_OAUTH2_PATH, body: params, headers: headers, onCompletion: {json, err in
			self.sessionId = json["access_token"].description
            if self.sessionId!.length == 0 || self.sessionId! == "null" {
                self.sessionId = nil
            }
			onCompletion(json, err)
		})
	}
	
    func getCurrentPerson(onCompletion: PersonResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
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
	
	func getPerson(personId: NSString, ignoreCache: Bool, onCompletion: PersonResponse) {
		if (sessionId != nil) {
            
            if !ignoreCache {
                if personCache[personId as String] != nil {
                    onCompletion(personCache[personId as String], nil)
                    return
                }
            }
            
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-gedcomx-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)", headers: headers, onCompletion: {json, err in
				var persons = Person.convertJsonToPersons(json)
				if persons.count > 0 {
					let person = persons[0]
                    self.personCache[personId as String] = person
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
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-gedcomx-atom+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/changes", headers: headers, onCompletion: {json, err in
				if json["entries"] != nil {
					let ae = json["entries"].array!
					if ae.count > 0 {
						let entry = ae[0]
						let timestamp = entry["updated"]
						onCompletion(timestamp.int64Value, err)
                        return
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
			headers["Authorization"] = "Bearer \(sessionId!)"
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
			headers["Authorization"] = "Bearer \(sessionId!)"
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
			headers["Authorization"] = "Bearer \(sessionId!)"
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
			headers["Authorization"] = "Bearer \(sessionId!)"
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
			headers["Authorization"] = "Bearer \(sessionId!)"
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
			headers["Authorization"] = "Bearer \(sessionId!)"
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
		headers["Authorization"] = "Bearer \(sessionId!)"
		headers["Accept"] = "application/x-fs-v1+json"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
 
        let task = session.dataTaskWithRequest(request, completionHandler: {(data: NSData?,  response: NSURLResponse?, error: NSError?) -> Void in
			let fileManager = NSFileManager.defaultManager()
            let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
			if data != nil && UIImage(data: data!) != nil {
                do {
                    let folderUrl = url.URLByAppendingPathComponent(folderName as String)
                    if !fileManager.fileExistsAtPath(folderUrl.path!) {
                        try fileManager.createDirectoryAtURL(folderUrl, withIntermediateDirectories: true, attributes: nil)
                    }
				
                    let imagePath = folderUrl.URLByAppendingPathComponent(fileName as String)
                    try data!.writeToURL(imagePath, atomically: true)
                    onCompletion("\(folderName)/\(fileName)", error)
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
        let myDelegate = RedirectSessionDelegate(headers: headers)
        //let session = NSURLSession.sharedSession()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: myDelegate, delegateQueue: nil)
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
            //print("Header \(field):\(value)")
		}
 
        print("makeHTTPGetRequest: \(request)")
        print(request.valueForHTTPHeaderField("Authorization"))
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error!.description)
            }
            if response == nil {
                onCompletion(nil, error)
                return
            }
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if data != nil {
                if httpResponse.statusCode != 200 {
                    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                }
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            }
            else {
                onCompletion(nil, error)
            }
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
            //print("Header \(field):\(value)")
		}
        
        do {
	 
            // Set the POST body for the request
            let options = NSJSONWritingOptions()
            print("makeHTTPPostJSONRequest: \(request)")
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: options)
            let session = NSURLSession.sharedSession()
	 
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if error != nil {
                    print(error!.description)
                }
                if response == nil {
                    onCompletion(nil, error)
                }
                let httpResponse = response as! NSHTTPURLResponse
                if httpResponse.statusCode != 200 {
                    print(response)
                }
                if data != nil {
                    if httpResponse.statusCode != 200 {
                        print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    }
                    let json:JSON = JSON(data: data!)
                    onCompletion(json, error)
                }
                else {
                    onCompletion(nil, error)
                }
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
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
            //print("Header \(field):\(value)")
		}
	 
		// Set the POST body for the request
		var postString = ""
        var p = 0
		for(param, value) in body {
            if p > 0 {
                postString += "&"
            }
			postString += "\(param)=\(value)";
            p++
		}

        //print(postString)
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
	 
        print("makeHTTPPostRequest: \(request)")
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error!.description)
            }
            if response == nil {
                onCompletion(nil, error)
            }
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if data != nil {
                if httpResponse.statusCode != 200 {
                    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                }
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            }
            else {
                onCompletion(nil, error)
            }
		})
		task.resume()
	}
    
    class RedirectSessionDelegate : NSObject, NSURLSessionDelegate {
        var headers:[String: String]
        
        init(headers:[String: String]) {
            self.headers = headers
            super.init()
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void)
        {
            let newRequest = NSMutableURLRequest(URL: request.URL!)
            // Set the headers
            for(field, value) in headers {
                newRequest.setValue(value, forHTTPHeaderField: field)
            }
            completionHandler(newRequest)
        }
    }
}