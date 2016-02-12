import Foundation
import SpriteKit

class PGVService : RemoteService {	
	static var SUCCESS = "SUCCESS"
	private var baseUrl:String?
	var defaultPersonId:String?

    var sessionId: NSString?
	var sessionName: NSString?
    var personCache = [String: Person]()
	var gedcomParser:GedcomParser
    
    init(baseUrl:String, defaultPersonId:String) {
        self.baseUrl = baseUrl
		self.defaultPersonId = defaultPersonId
		gedcomParser = GedcomParser()
    }
	
	func getVersion(onCompletion: StringResponse) {
		
		var params = [String: String]()
		params["action"] = "version"

		let headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		
		makeHTTPPostRequest(self.baseUrl + "client.php", body: params, headers: headers, onCompletion: {data, err in
			let version = nil
			if data != nil {
				let parts = data.split("\\s+")
				if parts.count > 1 && parts[0] == SUCCESS {
					version = parts[1]
				}
			}
			onCompletion(version, err)
		})
    }
	
	func authenticate(username: String, password: String, onCompletion: StringResponse) {
		var params = [String: String]()
		params["action"] = "connect"
        params["username"] = username
        params["password"] = password
		
		sessionId = nil
		let headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		
		makeHTTPPostRequest(self.baseUrl + "client.php", body: params, headers: headers, onCompletion: {data, err in
			if data != nil {
				let parts = data.split("\\s+")
				if parts.count > 2 && parts[0] == SUCCESS {
					self.sessionName = parts[1]
					self.sessionId = parts[2]
				}
			}
			onCompletion(data, err)
		})
	}
	
	func getGedcomRecord(recordId:String, onCompletion: StringResponse) {
		var params = [String: String]()
		params["action"] = "get"
        params["xref"] = recordId

		let headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		headers["Cookie"] = sessionName + "=" + sessionId + "; "
		
		makeHTTPPostRequest(self.baseUrl + "client.php", body: params, headers: headers, onCompletion: {data, err in
			if data != nil {
				let asRange = data.rangeOfString(SUCCESS)
				if let asRange = asRange where asRange.startIndex == data.startIndex {
					let zeroRange = data.rangeOfString("0")
					let record = data.substringFromIndex(zeroRange.startIndex)
					onCompletion(record, err)
					return
				}
			}
			onCompletion(nil, err)
		})
	}
	
    func getCurrentPerson(onCompletion: PersonResponse) {
		if (sessionId != nil) {
			getPerson(defaultPersonId, true, onCompletion: { person, err in
				onCompletion(person, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
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
            
			getGedcomRecord(personId as String, onCompletion: { gedcom, err in 
				let person = self.gedcomParser.parsePerson(gedcom)
				if person != nil {
					self.personCache[personId as String] = person
				}
				onCompletion(person, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in 
				if person != nil {
					let date = person.transientProperties["CHAN"]
					if (date != nil) {
						onCompletion(date.timeIntervalSince1970, err)
						return
					}
				}
				onCompletion(nil, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "PGVService", code: 401, userInfo: ["message":"Not authenticated with PhpGedView"]))
		}
	}
	
	func getPersonPortrait(personId: NSString, onCompletion: LinkResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in 
				var portrait:Link? = nil
				if person != nil {
					let media = person.media
					if media.count > 0 {
						let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
						let group = dispatch_group_create()
						for sr in media {
							if sr.links.count > 0 {
								for link in sr.links {
									if link.href != nil && link.href.hasPrefix("@") {
										let objeid = link.href.replaceAll("@", "")
										dispatch_group_enter(group)
										self.getGedcomRecord(objeid, onCompletion: {gedcom, err in 
											if gedcom != nil {
												let sd = self.gedcomParser.parseObje(gedcom, self.baseUrl)
												if sd != nil {
													for link2 in sd.links {
														if link2.rel == "image" {
															if portrait == nil || sd?.sortKey? == "1" {
																portrait = link2
															}
														}
													}
												}
											}
											dispatch_group_leave(group)
										})
									} else {
										portrait = link
									}
								}
							}
						}
						dispatch_group_notify(group, queue) {
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
	
	func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in  
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person.links
					if fams != nil {
						for fam in fams {
							let famid = fam.href.replaceAll("@", "")
							dispatch_group_enter(group)
							self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
								if gedcom != nil {
									let fh = gedcomParser.parseFamily(gedcom)
									if fam.rel == "FAMC" {
										for p in fh.parents {
											let relid = p.href.replaceAll("@" , "")
											if relid != personId {
												var rel = Relationship()
												rel.type = "http://gedcomx.org/ParentChild"
												var rr = ResourceReference()
												rr.resourceId = relid
												rel.person1 = rr
												var rr2 = ResourceReference()
												rr2.resourceId = personId
												rel.person2 = rr2
												family.append(rel)
											}
										}
									}
									if fam.rel == "FAMS" {
										for p in fh.parents {
											let relid = p.href.replaceAll("@" , "")
											if relid != personId {
												var rel = Relationship()
												rel.type = "http://gedcomx.org/Couple"
												var rr = ResourceReference()
												rr.resourceId = relid
												rel.person1 = rr
												var rr2 = ResourceReference()
												rr2.resourceId = personId
												rel.person2 = rr2
												family.append(rel)
											}
										}
										for p in fh.children {
											let relid = p.href.replaceAll("@" , "")
											if relid != personId {
												var rel = Relationship()
												rel.type = "http://gedcomx.org/ParentChild"
												var rr = ResourceReference()
												rr.resourceId = personId
												rel.person1 = rr
												var rr2 = ResourceReference()
												rr2.resourceId = relid
												rel.person2 = rr2
												family.append(rel)
											}
										}
									}
								}
								dispatch_group_leave(group)
							})
						}
					}
					dispatch_group_notify(group, queue) {
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
	
	func getParents(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in  
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person.links
					if fams != nil {
						for fam in fams {
							if fam.rel == "FAMC" {
								let famid = fam.href.replaceAll("@", "")
								dispatch_group_enter(group)
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = gedcomParser.parseFamily(gedcom)
										for p in fh.parents {
											let relid = p.href.replaceAll("@" , "")
											if relid != personId {
												var rel = Relationship()
												rel.type = "http://gedcomx.org/ParentChild"
												var rr = ResourceReference()
												rr.resourceId = relid
												rel.person1 = rr
												var rr2 = ResourceReference()
												rr2.resourceId = personId
												rel.person2 = rr2
												family.append(rel)
											}
										}
									}
									dispatch_group_leave(group)
								})
							}
						}
					}
					dispatch_group_notify(group, queue) {
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
	
	func getChildren(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in  
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person.links
					if fams != nil {
						for fam in fams {
							if fam.rel == "FAMS" {
								let famid = fam.href.replaceAll("@", "")
								dispatch_group_enter(group)
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = gedcomParser.parseFamily(gedcom)
										for p in fh.children {
											let relid = p.href.replaceAll("@" , "")
											if relid != personId {
												var rel = Relationship()
												rel.type = "http://gedcomx.org/ParentChild"
												var rr = ResourceReference()
												rr.resourceId = personId
												rel.person1 = rr
												var rr2 = ResourceReference()
												rr2.resourceId = relid
												rel.person2 = rr2
												family.append(rel)
											}
										}
									}
									dispatch_group_leave(group)
								})
							}
						}
					}
					dispatch_group_notify(group, queue) {
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
	
	func getSpouses(personId: NSString, onCompletion: RelationshipsResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in  
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person.links
					if fams != nil {
						for fam in fams {
							if fam.rel == "FAMS" {
								let famid = fam.href.replaceAll("@", "")
								dispatch_group_enter(group)
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = gedcomParser.parseFamily(gedcom)
										for p in fh.parents {
											let relid = p.href.replaceAll("@" , "")
											if relid != personId {
												var rel = Relationship()
												rel.type = "http://gedcomx.org/Couple"
												var rr = ResourceReference()
												rr.resourceId = relid
												rel.person1 = rr
												var rr2 = ResourceReference()
												rr2.resourceId = personId
												rel.person2 = rr2
												family.append(rel)
											}
										}
									}
									dispatch_group_leave(group)
								})
							}
						}
					}
					dispatch_group_notify(group, queue) {
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
	
	func getPersonMemories(personId: NSString, onCompletion: SourceDescriptionsResponse) {
		if (sessionId != nil) {
			getPerson(personId, onCompletion: { person, err in  
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var sdlist = [SourceDescription]()
					for sr in person.media {
						for link in sr.links {
							if link.href != nil && link.href.hasPrefix("@") {
								let objeid = link.href.replaceAll("@", "")
								dispatch_group_enter(group)
								self.getGedcomRecord(objeid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let sd = self.gedcomParser.parseObje(gedcom, self.baseUrl)
										if sd != nil {
											if sd.links.count > 0 {
												sdlist.append(sd)
											}
										}
									}
									dispatch_group_leave(group)
								})
							}
						}
					}
					
					dispatch_group_notify(group, queue) {
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
	
	func downloadImage(uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: uri as String)!)
 
        let session = NSURLSession.sharedSession()
		var headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		headers["Cookie"] = sessionName + "=" + sessionId + "; "
		
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
                    if data!.writeToURL(imagePath, atomically: true) {
                        let returnPath = "\(folderName)/\(fileName)"
                        onCompletion(returnPath, error)
                    } else {
                        onCompletion(nil, error)
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
	
	func getPersonUrl(personId: NSString) -> NSString {
		return baseUrl + "individual.php?pid=" + personId
	}
	
    func makeHTTPGetRequest(path: String, headers: [String: String], onCompletion: StringResponse) {
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
                let stringData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if httpResponse.statusCode != 200 {
                    print(stringData)
                }
                onCompletion(stringData, error)
            }
            else {
                onCompletion(nil, error)
            }
        })
        task.resume()
    }
	
    func makeHTTPPostRequest(path: String, body: [String: String], headers: [String: String], onCompletion: StringResponse) {
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
                return
            }
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
            }
            if data != nil {
				let stringData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if httpResponse.statusCode != 200 {
                    print(stringData)
                }
                onCompletion(stringData, error)
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