import Foundation
import SpriteKit

class PGVService : RemoteService {	
	static var SUCCESS = "SUCCESS"
	fileprivate var baseUrl:String?
	var defaultPersonId:String?

    var sessionId: NSString?
	var sessionName: NSString?
    var personCache = [String: Person]()
	var gedcomParser:GedcomParser
    
    init(base:String, defaultPersonId:String) {
        self.baseUrl = base
        if baseUrl!.hasSuffix("client.php") {
            baseUrl = baseUrl!.substring(to: baseUrl!.characters.index(baseUrl!.startIndex, offsetBy: baseUrl!.characters.count-10))
        }
        if baseUrl!.hasSuffix("/") == false {
            baseUrl = baseUrl! + "/"
        }
		self.defaultPersonId = defaultPersonId
		gedcomParser = GedcomParser()
    }
	
	func getVersion(_ onCompletion: @escaping StringResponse) {
		
		var params = [String: String]()
		params["action"] = "version"

		var headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		
		makeHTTPPostRequest(self.baseUrl! + "client.php", body: params, headers: headers, onCompletion: {data, err in
            var version:String? = nil
			if data != nil {
                let dataStr:String = (data as! String)
				let parts = dataStr.split("\\s+")
				if parts.count > 1 && parts[0] == PGVService.SUCCESS {
					version = parts[1]
				}
			}
			onCompletion(version as NSString?, err)
		})
    }
	
	func authenticate(_ username: String, password: String, onCompletion: @escaping StringResponse) {
		var params = [String: String]()
		params["action"] = "connect"
        params["username"] = username
        params["password"] = password
		
		sessionId = nil
		var headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		
		makeHTTPPostRequest(self.baseUrl! + "client.php", body: params, headers: headers, onCompletion: {data, err in
			if data != nil {
                let dataStr:String = (data as! String)
                let parts = dataStr.split("\\s+")
				if parts.count > 2 && parts[0] == PGVService.SUCCESS {
					self.sessionName = parts[1] as NSString?
					self.sessionId = parts[2] as NSString?
				}
			}
			onCompletion(self.sessionId, err)
		})
	}
	
	func getGedcomRecord(_ recordId:String, onCompletion: @escaping StringResponse) {
		var params = [String: String]()
		params["action"] = "get"
        params["xref"] = recordId

		var headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		headers["Cookie"] = "\(sessionName!)=\(sessionId!)"
		
		makeHTTPPostRequest(self.baseUrl! + "client.php", body: params, headers: headers, onCompletion: {data, err in
			if data != nil {
				if data!.hasPrefix(PGVService.SUCCESS) {
					let zeroRange = data!.range(of: "0")
					let record = data!.substring(from: zeroRange.toRange()!.lowerBound)
					onCompletion(record as NSString?, err)
					return
                } else if err == nil{
                    onCompletion(nil, NSError(domain: "PGVService", code: 500, userInfo: ["message":data!]))
                    return
                }
            } else if err != nil && err!.code == -1005 {
                print("Sleeping for 10 seconds after \(err)")
                sleep(10)
                self.getGedcomRecord(recordId, onCompletion: {gedcom, err in
                    if err != nil && err!.code == -1005 {
                        print("Sleeping for 10 more seconds after \(err)")
                        sleep(10)
                        self.getGedcomRecord(recordId, onCompletion: {gedcom, err in
                            onCompletion(gedcom, err)
                        })
                    } else {
                        onCompletion(gedcom, err)
                    }
                })
                return
            }
			onCompletion(nil, err)
		})
	}
	
    func getCurrentPerson(_ onCompletion: @escaping PersonResponse) {
		if (sessionId != nil) {
			getPerson(defaultPersonId! as NSString, ignoreCache: true, onCompletion: { person, err in
				onCompletion(person, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getPerson(_ personId: NSString, ignoreCache: Bool, onCompletion: @escaping PersonResponse) {
		if (sessionId != nil) {
            
            if !ignoreCache {
                if personCache[personId as String] != nil {
                    onCompletion(personCache[personId as String], nil)
                    return
                }
            }
            
			getGedcomRecord(personId as String, onCompletion: { gedcom, err in
                if gedcom != nil {
                    let person = self.gedcomParser.parsePerson(gedcom! as String)
                    if person != nil {
                        self.personCache[personId as String] = person
                    }
                    onCompletion(person, err)
                } else {
                    onCompletion(nil, err)
                }
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getLastChangeForPerson(_ personId: NSString, onCompletion: @escaping LongResponse) {
		if (sessionId != nil) {
            getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
                    let date = person!.lastChange
					if (date != nil) {
						onCompletion(Int64(date!.timeIntervalSince1970), err)
						return
					}
				}
				onCompletion(nil, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getPersonPortrait(_ personId: NSString, onCompletion: @escaping LinkResponse) {
		if (sessionId != nil) {
			getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				var portrait:Link? = nil
				if person != nil {
					let media = person!.media
					if media.count > 0 {
						let queue = DispatchQueue.global()
						let group = DispatchGroup()
						for sr in media {
							if sr.links.count > 0 {
								for link in sr.links {
									if link.href != nil && link.href!.hasPrefix("@") {
										let objeid = (link.href! as String).replaceAll("@", replace: "")
										group.enter()
										self.getGedcomRecord(objeid, onCompletion: {gedcom, err in 
											if gedcom != nil {
												let sd = self.gedcomParser.parseObje(gedcom! as String, baseUrl: self.baseUrl!)
												if sd != nil {
													for link2 in sd!.links {
														if link2.rel == "image" {
															if portrait == nil || (sd?.sortKey != nil && sd?.sortKey! == "1") {
																portrait = link2
															}
														}
													}
												}
											}
											group.leave()
										})
									} else {
										portrait = link
									}
								}
							}
						}
						group.notify(queue: queue) {
							onCompletion(portrait, nil)
						}
						return
					}
					onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find portraits for person with id \(personId)"]))
					return
				}
				onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getCloseRelatives(_ personId: NSString, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
            getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = DispatchQueue.global()
					let group = DispatchGroup()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0 {
						for fam in fams {
                            let href = fam.href as! String
							let famid = href.replaceAll("@", replace: "")
							group.enter()
							self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
								if gedcom != nil {
									let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                    if fh != nil {
                                        if fam.rel == "FAMC" {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId as String {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid as NSString?
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = personId
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
                                            }
                                        }
                                        if fam.rel == "FAMS" {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId as String {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/Couple"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid as NSString?
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = personId
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
                                            }
                                            for p in fh!.children {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId as String {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = personId
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = relid as NSString?
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
                                            }
                                        }
                                    }
								}
								group.leave()
							})
						}
					}
					group.notify(queue: queue) {
						onCompletion(family, nil)
					}
				} else {
					onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getParents(_ personId: NSString, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
            getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = DispatchQueue.global()
					let group = DispatchGroup()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0 {
						for fam in fams {
							if fam.rel == "FAMC" {
                                let href = fam.href as! String
								let famid = href.replaceAll("@", replace: "")
								group.enter()
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                        if fh != nil {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId as String {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid as NSString?
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = personId
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
                                            }
                                        }
									}
									group.leave()
								})
							}
						}
					}
					group.notify(queue: queue) {
						onCompletion(family, nil)
					}
				} else {
					onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getChildren(_ personId: NSString, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
			getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = DispatchQueue.global()
					let group = DispatchGroup()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0 {
						for fam in fams {
							if fam.rel == "FAMS" {
                                let href = fam.href as! String
								let famid = href.replaceAll("@", replace: "")
								group.enter()
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                        if fh != nil {
                                            for p in fh!.children {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId as String {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = personId
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = relid as NSString?
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
                                            }
                                        }
									}
									group.leave()
								})
							}
						}
					}
					group.notify(queue: queue) {
						onCompletion(family, nil)
					}
				} else {
					onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getSpouses(_ personId: NSString, onCompletion: @escaping RelationshipsResponse) {
		if (sessionId != nil) {
			getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = DispatchQueue.global()
					let group = DispatchGroup()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0  {
						for fam in fams {
							if fam.rel == "FAMS" {
                                let href = fam.href as! String
								let famid = href.replaceAll("@", replace: "")
								group.enter()
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                        if fh != nil {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId as String {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/Couple"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid as NSString?
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = personId
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
                                            }
                                        }
									}
									group.leave()
								})
							}
						}
					}
					group.notify(queue: queue) {
						onCompletion(family, nil)
					}
				} else {
					onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getPersonMemories(_ personId: NSString, onCompletion: @escaping SourceDescriptionsResponse) {
		if (sessionId != nil) {
			getPerson(personId as String as String as NSString, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = DispatchQueue.global()
					let group = DispatchGroup()
					
					var sdlist = [SourceDescription]()
					for sr in person!.media {
						for link in sr.links {
                            let href = link.href as! String
							if link.href != nil && href.hasPrefix("@") {
								let objeid = href.replaceAll("@", replace: "")
								group.enter()
								self.getGedcomRecord(objeid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let sd = self.gedcomParser.parseObje(gedcom! as String, baseUrl: self.baseUrl!)
										if sd != nil {
											if sd!.links.count > 0 {
												sdlist.append(sd!)
											}
										}
									}
									group.leave()
								})
							}
						}
					}
					
					group.notify(queue: queue) {
						onCompletion(sdlist, nil)
					}
				} else {
					onCompletion(nil, NSError(domain: "PGVService", code: 404, userInfo: ["message":"Unable to find person with id \(personId)"]))
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func downloadImage(_ uri: NSString, folderName: NSString, fileName: NSString, onCompletion: @escaping StringResponse) {
		let request = NSMutableURLRequest(url: URL(string: uri as String)!)
 
        let session = URLSession.shared
		var headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		headers["Cookie"] = "\(sessionName!)=\(sessionId!)"
		
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
                        onCompletion(returnPath as NSString?, error as NSError?)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                    return;
                } catch {
                    onCompletion(nil, NSError(domain: "PGVService", code: 500, userInfo: ["message":"Unable to download and save image"]))
                    return;
                }
            } else {
                onCompletion(nil, NSError(domain: "PGVService", code: 500, userInfo: ["message":"Unable to download and save image"]))
            }
        })
        task.resume()
	}
	
	func getPersonUrl(_ personId: NSString) -> NSString {
		return "\(baseUrl!)individual.php?pid=\(personId)" as NSString
	}
	
    var lastRequestTime:Foundation.Date = Foundation.Date()
    var requestDelay:TimeInterval = -4.0
    func makeHTTPGetRequest(_ path: String, headers: [String: String], onCompletion: @escaping StringResponse) {
        let timeSinceLastRequest = lastRequestTime.timeIntervalSinceNow
        if timeSinceLastRequest > requestDelay {
            self.throttled(0 - requestDelay, closure: {
                self.makeHTTPGetRequest(path, headers: headers, onCompletion: onCompletion)
            })
            return
        }

        let request = NSMutableURLRequest(url: URL(string: path)!)
        let myDelegate = RedirectSessionDelegate(headers: headers)
        //let session = NSURLSession.sharedSession()
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: myDelegate, delegateQueue: nil)
        session.configuration.httpMaximumConnectionsPerHost = 1
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
            //print("Header \(field):\(value)")
		}
 
        print("makeHTTPGetRequest: \(request)")
        print(request.value(forHTTPHeaderField: "Authorization"))
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error)
            }
            if response == nil {
                onCompletion(nil, error as NSError?)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if data != nil {
                let stringData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if httpResponse.statusCode != 200 {
                    print(stringData)
                }
                onCompletion(stringData, error as NSError?)
            }
            else {
                onCompletion(nil, error as NSError?)
            }
        })
        task.resume()
    }
	
    func makeHTTPPostRequest(_ path: String, body: [String: String], headers: [String: String], onCompletion: @escaping StringResponse) {
		let request = NSMutableURLRequest(url: URL(string: path)!)
	 
		// Set the method to POST
		request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
		
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
                onCompletion(nil, error as NSError?)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if data != nil {
				let stringData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if httpResponse.statusCode != 200 {
                    print(stringData)
                }
                onCompletion(stringData, error as NSError?)
            }
            else {
                onCompletion(nil, error as NSError?)
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
