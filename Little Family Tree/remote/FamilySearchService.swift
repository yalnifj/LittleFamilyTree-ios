import Foundation
import SpriteKit

class FamilySearchService : RemoteService {

	let FS_PLATFORM_PATH_SAND = "https://sandbox.familysearch.org/platform/"
    let FS_PLATFORM_PATH_BETA = "https://beta.familysearch.org/platform/"
	let FS_PLATFORM_PATH_PROD = "https://familysearch.org/platform/"
    var FS_PLATFORM_PATH:String
	
	let FS_OAUTH2_PATH_SAND = "https://sandbox.familysearch.org/cis-web/oauth2/v3/token"
    let FS_OAUTH2_PATH_BETA = "https://identbeta.familysearch.org/cis-web/oauth2/v3/token"
	let FS_OAUTH2_PATH_PROD = "https://ident.familysearch.org/cis-web/oauth2/v3/token"
    var FS_OAUTH2_PATH:String
	
	fileprivate let FS_APP_KEY = "a02j0000009AXffAAG"

    var sessionId: String?
    var personCache = [String: Person]()
    
    fileprivate init() {
        FS_PLATFORM_PATH = FS_PLATFORM_PATH_PROD
        FS_OAUTH2_PATH = FS_OAUTH2_PATH_PROD
    }
	
	static let sharedInstance = FamilySearchService()
    
    func setEnvironment(_ env:String) {
        if (env=="sandbox") {
            FS_PLATFORM_PATH = FS_PLATFORM_PATH_SAND
            FS_OAUTH2_PATH = FS_OAUTH2_PATH_SAND
        }
        else if (env=="beta") {
            FS_PLATFORM_PATH = FS_PLATFORM_PATH_BETA
            FS_OAUTH2_PATH = FS_OAUTH2_PATH_BETA
        }
        else if (env=="prod") {
            FS_PLATFORM_PATH = FS_PLATFORM_PATH_PROD
            FS_OAUTH2_PATH = FS_OAUTH2_PATH_PROD
        }
    }
	
    internal func authenticate(_ username: String, password: String, onCompletion: @escaping StringResponse) {
		var params = [String: String]()
		params["grant_type"] = "password"
        params["client_id"] = FS_APP_KEY
        params["username"] = username
        params["password"] = password
        
        if username=="tum000205905" || username=="tum000142047" {
            setEnvironment("sandbox")
        }
		
		sessionId = nil;
		let headers = [String: String]()
		
		makeHTTPPostRequest(FS_OAUTH2_PATH, body: params, headers: headers, onCompletion: {json, err in
			self.sessionId = json["access_token"].description
            if self.sessionId!.isEmpty || self.sessionId! == "null" {
                self.sessionId = nil
                if err == nil {
                    let jerror = json["error_description"]
                    if jerror != JSON.null {
                        let error = NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":jerror.description])
                        onCompletion(self.sessionId, error)
                        return
                    }
                }
            }
			onCompletion(self.sessionId, err)
		})
	}
	
    internal func getCurrentPerson(_ onCompletion: @escaping PersonResponse) {
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
	
	func getPerson(_ personId: String, ignoreCache: Bool, onCompletion: @escaping PersonResponse) {
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
                    self.personCache[personId] = person
					onCompletion(person, err)
				} else {
					onCompletion(nil, NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find person with id " + personId.description]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
    
    func getMultiplePersons(_ personIds: String, onCompletion: @escaping ([Person], NSError?) -> Void) {
        if (sessionId != nil) {
            
            var headers = [String: String]()
            headers["Authorization"] = "Bearer \(sessionId!)"
            headers["Accept"] = "application/x-gedcomx-v1+json"
            makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personIds)", headers: headers, onCompletion: {json, err in
                let persons = Person.convertJsonToPersons(json)
                if persons.count > 0 {
                    var people = [Person]()
                    for person in persons {
                        self.personCache[person.id!] = person
                        people.append(person)
                    }
                    onCompletion(people, err)
                } else {
                    onCompletion([Person](), NSError(domain: "FamilySearchService", code: 404, userInfo: ["message":"Unable to find person with id " + personIds]))
                }
            })
        } else {
            onCompletion([Person](), NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
        }
    }
	
	func getLastChangeForPerson(_ personId: String, onCompletion: @escaping LongResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-gedcomx-atom+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/changes", headers: headers, onCompletion: {json, err in
				if json["entries"] != JSON.null {
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
	
	func getPersonPortrait(_ personId: String, onCompletion: @escaping LinkResponse) {
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
	
	func getCloseRelatives(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/families", headers: headers, onCompletion: {json, err in
                var pids = ""
                var count = 0;
                if json["persons"] != JSON.null {
                    for pson in json["persons"].array! {
                        let pid = pson["id"].description
                        if count > 0 {
                            pids = pids + ","
                        }
                        pids = pids + pid
                        count += 1
                    }
                }
                if count > 0 {
                    self.getMultiplePersons(pids, onCompletion: {people, err in })
                }
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getParents(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/parents", headers: headers, onCompletion: {json, err in
                let persons = Person.convertJsonToPersons(json)
                if persons.count > 0 {
                    for person in persons {
                        self.personCache[personId] = person
                    }
                }
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getChildren(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/children", headers: headers, onCompletion: {json, err in
                let persons = Person.convertJsonToPersons(json)
                if persons.count > 0 {
                    for person in persons {
                        self.personCache[personId] = person
                    }
                }
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getSpouses(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-fs-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)/spouses", headers: headers, onCompletion: {json, err in
                let persons = Person.convertJsonToPersons(json)
                if persons.count > 0 {
                    for person in persons {
                        self.personCache[personId] = person
                    }
                }
				let relationships = Relationship.convertJsonToRelationships(json)
				onCompletion(relationships, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getPersonMemories(_ personId: String, onCompletion: @escaping SourceDescriptionsResponse) {
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
	
	func downloadImage(_ uri: String, folderName: String, fileName: String, onCompletion: @escaping StringResponse) {
		let request = NSMutableURLRequest(url: URL(string: uri as String)!)
 
        let session = URLSession.shared
		var headers = [String: String]()
		headers["Authorization"] = "Bearer \(sessionId!)"
		headers["Accept"] = "application/x-fs-v1+json"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
 
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data: Data?,  response: URLResponse?, error: Error?) -> Void in
			let fileManager = FileManager.default
            let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
			if data != nil && UIImage(data: data!) != nil {
                do {
                    let folderUrl = url.appendingPathComponent(folderName as String)
                    if !fileManager.fileExists(atPath: folderUrl.path) {
                        try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
                    }
				
                    let imagePath = folderUrl.appendingPathComponent(fileName as String)
                    if (try? data!.write(to: imagePath, options: [.atomic])) != nil {
                        let returnPath = "\(folderName)/\(fileName)"
                        onCompletion(returnPath, error as NSError?)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                    return;
                } catch {
                    onCompletion(nil, NSError(domain: "FamilySearchService", code: 500, userInfo: ["message":"Unable to download and save image"]))
                    return;
                }
            } else {
                onCompletion(nil, NSError(domain: "FamilySearchService", code: 500, userInfo: ["message":"Unable to download and save image"]))
            }
        })
        task.resume()
	}
	
	func getPersonUrl(_ personId: String) -> String {
		return "https://familysearch.org/tree/#view=ancestor&person=\(personId)"
	}
    
    func makeHTTPGetRequest(_ path: String, headers: [String: String], onCompletion: @escaping ServiceResponse) {
        self.makeHTTPGetRequest(path, headers: headers, count: 1, onCompletion: onCompletion)
    }
	
    var lastRequestTime:Foundation.Date = Foundation.Date()
    var requestDelay:TimeInterval = -0.3
    func makeHTTPGetRequest(_ path: String, headers: [String: String], count: Int, onCompletion: @escaping ServiceResponse) {
        let timeSinceLastRequest = lastRequestTime.timeIntervalSinceNow
        if timeSinceLastRequest > requestDelay {
            self.throttled(0 - requestDelay, closure: {
                self.makeHTTPGetRequest(path, headers: headers, count: 1, onCompletion: onCompletion)
            })
            return
        }
        lastRequestTime = Foundation.Date()
        let request = NSMutableURLRequest(url: URL(string: path)!)
        let myDelegate = RedirectSessionDelegate(headers: headers)
        // too many requests coming where are they coming from?
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: myDelegate, delegateQueue: nil)
        session.configuration.httpMaximumConnectionsPerHost = 2
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
            //print("Header \(field):\(value)")
		}
 
        print("makeHTTPGetRequest: \(request)")
        print(request.value(forHTTPHeaderField: "Authorization"))
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error!)
            }
            if response == nil {
                onCompletion(JSON.null, error as NSError?)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
                print(response!)
            }
            if httpResponse.statusCode == 429 {
                //-- connection was throttled, try again after 10 seconds
                if count < 4 {
                    SyncQ.getInstance().pauseForTime(20.0 * Double(count))
                    print("Connection throttled... delaying 30 seconds")
                    self.throttled(20.0 * Double(count), closure: {
                        self.makeHTTPGetRequest(path, headers: headers, count: count+1, onCompletion: onCompletion)
                    })
                } else {
                    let error = NSError(domain: "FamilySearchService", code: 204, userInfo: ["message":"Connection throttled"])
                    print("Failed connection throttled 3 times... giving up")
                    onCompletion(JSON.null, error)
                }
                return
            }
            if data != nil {
                if httpResponse.statusCode != 200 {
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                }
                let json:JSON = JSON(data: data!)
                onCompletion(json, error as NSError?)
            }
            else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()
    }
	
    func makeHTTPPostJSONRequest(_ path: String, body: [String: AnyObject], headers: [String: String], onCompletion: @escaping ServiceResponse) {
		let request = NSMutableURLRequest(url: URL(string: path)!)
	 
		// Set the method to POST
		request.httpMethod = "POST"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
            //print("Header \(field):\(value)")
		}
	 
        // Set the POST body for the request
        let options = JSONSerialization.WritingOptions()
        print("makeHTTPPostJSONRequest: \(request)")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: options)
        let session = URLSession.shared
        session.configuration.httpMaximumConnectionsPerHost = 5
 
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error)
            }
            if response == nil {
                onCompletion(JSON.null, error as NSError?)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if httpResponse.statusCode == 204 {
                //-- connection was throttled, try again after 10 seconds
                SyncQ.getInstance().pauseForTime(60)
                self.throttled(20, closure: {
                    self.makeHTTPPostJSONRequest(path, body: body, headers: headers, onCompletion: onCompletion)
                })
                return
            }
            if data != nil {
                if httpResponse.statusCode != 200 {
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                }
                let json:JSON = JSON(data: data!)
                onCompletion(json, error as NSError?)
            }
            else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()

	}
	
    func makeHTTPPostRequest(_ path: String, body: [String: String], headers: [String: String], onCompletion: @escaping ServiceResponse) {
		let request = NSMutableURLRequest(url: URL(string: path)!)
	 
		// Set the method to POST
		request.httpMethod = "POST"
        
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
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			postString += "\(param)=\(encodedValue)";
            p += 1
		}

        //print(postString)
		request.httpBody = postString.data(using: String.Encoding.utf8)
		let session = URLSession.shared
        session.configuration.httpMaximumConnectionsPerHost = 5
	 
        print("makeHTTPPostRequest: \(request)?\(postString)")
		let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error)
            }
            if response == nil {
                onCompletion(JSON.null, error as NSError?)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if data != nil {
                if httpResponse.statusCode != 200 {
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                }
                let json:JSON = JSON(data: data!)
                onCompletion(json, error as NSError?)
            }
            else {
                onCompletion(JSON.null, error as NSError?)
            }
		})
		task.resume()
	}
    
    func throttled(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    class RedirectSessionDelegate : NSObject, URLSessionDelegate {
        var headers:[String: String]
        
        init(headers:[String: String]) {
            self.headers = headers
            super.init()
        }
        
        func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest!) -> Void)
        {
            let newRequest = NSMutableURLRequest(url: request.url!)
            // Set the headers
            for(field, value) in headers {
                newRequest.setValue(value, forHTTPHeaderField: field)
            }
            completionHandler(newRequest as URLRequest!)
        }
    }
}
