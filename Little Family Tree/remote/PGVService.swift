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
    
    init(base:String, defaultPersonId:String) {
        self.baseUrl = base
        if baseUrl!.hasSuffix("client.php") {
            baseUrl = baseUrl!.substringToIndex(baseUrl!.startIndex.advancedBy(baseUrl!.characters.count-10))
        }
        if baseUrl!.hasSuffix("/") == false {
            baseUrl = baseUrl! + "/"
        }
		self.defaultPersonId = defaultPersonId
		gedcomParser = GedcomParser()
    }
	
	func getVersion(onCompletion: StringResponse) {
		
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
			onCompletion(version, err)
		})
    }
	
	func authenticate(username: String, password: String, onCompletion: StringResponse) {
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
					self.sessionName = parts[1]
					self.sessionId = parts[2]
				}
			}
			onCompletion(self.sessionId, err)
		})
	}
	
	func getGedcomRecord(recordId:String, onCompletion: StringResponse) {
		var params = [String: String]()
		params["action"] = "get"
        params["xref"] = recordId

		var headers = [String: String]()
		headers["User-Agent"] = "PGVAgent"
		headers["Cookie"] = "\(sessionName!)=\(sessionId!)"
		
		makeHTTPPostRequest(self.baseUrl! + "client.php", body: params, headers: headers, onCompletion: {data, err in
			if data != nil {
				if data!.hasPrefix(PGVService.SUCCESS) {
					let zeroRange = data!.rangeOfString("0")
					let record = data!.substringFromIndex(zeroRange.toRange()!.startIndex)
					onCompletion(record, err)
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
	
    func getCurrentPerson(onCompletion: PersonResponse) {
		if (sessionId != nil) {
			getPerson(defaultPersonId!, ignoreCache: true, onCompletion: { person, err in
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
	
	func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse) {
		if (sessionId != nil) {
            getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
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
	
	func getPersonPortrait(personId: NSString, onCompletion: LinkResponse) {
		if (sessionId != nil) {
			getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
				var portrait:Link? = nil
				if person != nil {
					let media = person!.media
					if media.count > 0 {
						let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
						let group = dispatch_group_create()
						for sr in media {
							if sr.links.count > 0 {
								for link in sr.links {
									if link.href != nil && link.href!.hasPrefix("@") {
										let objeid = (link.href! as String).replaceAll("@", replace: "")
										dispatch_group_enter(group)
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
            getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0 {
						for fam in fams {
                            let href = fam.href as! String
							let famid = href.replaceAll("@", replace: "")
							dispatch_group_enter(group)
							self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
								if gedcom != nil {
									let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                    if fh != nil {
                                        if fam.rel == "FAMC" {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid
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
                                                if relid != personId {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/Couple"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid
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
                                                if relid != personId {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = personId
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = relid
                                                    rel.person2 = rr2
                                                    family.append(rel)
                                                }
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
            getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0 {
						for fam in fams {
							if fam.rel == "FAMC" {
                                let href = fam.href as! String
								let famid = href.replaceAll("@", replace: "")
								dispatch_group_enter(group)
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                        if fh != nil {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = personId
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
			getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0 {
						for fam in fams {
							if fam.rel == "FAMS" {
                                let href = fam.href as! String
								let famid = href.replaceAll("@", replace: "")
								dispatch_group_enter(group)
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                        if fh != nil {
                                            for p in fh!.children {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/ParentChild"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = personId
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
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
			getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var family = [Relationship]()
					let fams = person!.links
					if fams.count > 0  {
						for fam in fams {
							if fam.rel == "FAMS" {
                                let href = fam.href as! String
								let famid = href.replaceAll("@", replace: "")
								dispatch_group_enter(group)
								self.getGedcomRecord(famid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let fh = self.gedcomParser.parseFamily(gedcom! as String)
                                        if fh != nil {
                                            for p in fh!.parents {
                                                let href = p.href as! String
                                                let relid = href.replaceAll("@" , replace: "")
                                                if relid != personId {
                                                    let rel = Relationship()
                                                    rel.type = "http://gedcomx.org/Couple"
                                                    let rr = ResourceReference()
                                                    rr.resourceId = relid
                                                    rel.person1 = rr
                                                    let rr2 = ResourceReference()
                                                    rr2.resourceId = personId
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
			getPerson(personId as String, ignoreCache: false, onCompletion: { person, err in
				if person != nil {
					let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
					let group = dispatch_group_create()
					
					var sdlist = [SourceDescription]()
					for sr in person!.media {
						for link in sr.links {
                            let href = link.href as! String
							if link.href != nil && href.hasPrefix("@") {
								let objeid = href.replaceAll("@", replace: "")
								dispatch_group_enter(group)
								self.getGedcomRecord(objeid, onCompletion: { gedcom, err in 
									if gedcom != nil {
										let sd = self.gedcomParser.parseObje(gedcom! as String, baseUrl: self.baseUrl!)
										if sd != nil {
											if sd!.links.count > 0 {
												sdlist.append(sd!)
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
		headers["Cookie"] = "\(sessionName!)=\(sessionId!)"
		
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
		return baseUrl! + "individual.php?pid=" + (personId as String)
	}
	
    func makeHTTPGetRequest(path: String, headers: [String: String], onCompletion: StringResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        let myDelegate = RedirectSessionDelegate(headers: headers)
        //let session = NSURLSession.sharedSession()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: myDelegate, delegateQueue: nil)
        session.configuration.HTTPMaximumConnectionsPerHost = 5
		
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
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
        session.configuration.HTTPMaximumConnectionsPerHost = 5
	 
        print("makeHTTPPostRequest: \(request)?\(postString)")
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