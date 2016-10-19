//
//  MyHeritageService.swift
//  Little Family Tree
//
//  Created by Melissa on 7/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class MyHeritageService: RemoteService {
    
    var sessionId: NSString?
    
    var familyGraph:FamilyGraph!
    var clientId = "0d9d29c39d0ded7bd6a9e334e5f673a7"
    var clientSecret = "9021b2dcdb4834bd12a491349f61cb27"
    var sessionDelegate:SessionDelegate!
    var jsonConverter:FamilyGraphJsonConverter!
	
	var userId:String?
	
	var personCache = [String: Person]()
    
    init() {
        sessionDelegate = SessionDelegate()
        familyGraph = FamilyGraph(clientId: self.clientId, andDelegate: sessionDelegate)
        jsonConverter = FamilyGraphJsonConverter()
    }
    
    func authenticate(username: String, password: String, onCompletion: StringResponse) {
        sessionId = familyGraph.accessToken
        onCompletion(sessionId, nil)
    }
    
    func authWithDialog() {
        let perms:[AnyObject] = ["offline_access"]
        familyGraph.authorize(perms)
    }
    
    func getCurrentUser(onCompletion: (NSDictionary?, NSError?) -> Void) {
        getData("me", onCompletion: { data, err in
			if data != nil {
				let userData = data as! NSDictionary
				self.userId = userData["id"] as! String?
                onCompletion(userData, err)
			}
            else {
                onCompletion(nil, err)
            }
		})
    }
    
    func getCurrentPerson(onCompletion: PersonResponse) {
        if sessionId != nil {
			getCurrentUser({ userData, err in
				if userData != nil {
					let indi = userData!["default_individual"] as! NSDictionary
					let indiId = indi["id"] as! String
					self.getPerson(indiId, ignoreCache: false, onCompletion: onCompletion)
				} else {
					onCompletion(nil, err)
				}
			})
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPerson(personId: NSString, ignoreCache: Bool, onCompletion: PersonResponse) {
        if sessionId != nil {
			if !ignoreCache {
                if personCache[personId as String] != nil {
                    onCompletion(personCache[personId as String], nil)
                    return
                }
            }
			
            getData(personId as String, onCompletion: {data, err in
                if data != nil {
                    let person = self.jsonConverter.createJsonPerson(data as! NSDictionary)
                    
                    self.getData("\(personId)/events", onCompletion: {eventData, err in
                        if eventData != nil {
                            self.jsonConverter.processEvents(eventData as! NSDictionary, person: person)
                        }
                        
                        self.personCache[personId as String] = person
                        onCompletion(person, err)
                    })
                }
                else {
                    onCompletion(nil, err)
                }
            })
            
			
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse) {
        if sessionId != nil {
            // TODO
            onCompletion(nil, nil)
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPersonPortrait(personId: NSString, onCompletion: LinkResponse) {
        if sessionId != nil {
            var portrait:Link? = nil
            var err:NSError? = nil
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let group = dispatch_group_create()
            dispatch_group_enter(group)
            self.getPerson(personId, ignoreCache: false, onCompletion: {person, err1 in
                err = err1
                if person != nil {
                    let media = person?.media
                    if media != nil {
                        for sr in media! {
                            for link1 in sr.links {
                                let objeId = link1.href
                                if objeId != nil {
                                    dispatch_group_enter(group)
                                    self.getData(objeId as! String, onCompletion: {data, err2 in
                                        err = err2
                                        if data != nil {
                                            let sd = self.jsonConverter.convertMedia(data as! NSDictionary)
                                            for link2 in sd.links {
                                                if link2.rel != nil && link2.rel! == "image" {
                                                    if portrait == nil || (sd.sortKey != nil && sd.sortKey! == "1") {
                                                        portrait = link2
                                                    }
                                                }
                                            }
                                        }
                                        dispatch_group_leave(group)
                                    })
                                }
                            }
                        }
                    }
                }
                dispatch_group_leave(group)
            })
            
            dispatch_group_notify(group, queue) {
                onCompletion(portrait, err)
            }
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/immediate_family", onCompletion: { data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let peopleArray = json["data"] as? NSArray
                    if peopleArray != nil {
                        for rel in peopleArray! {
                            let type = rel["relationship_type"] as! String
                            if type == "wife" || type == "husband" {
                                let relationship = Relationship()
                                relationship.type = "http://gedcomx.org/Couple"
                                let rr = ResourceReference()
                                let indi = rel["individual"] as! NSDictionary
                                rr.resourceId = indi["id"] as! String
                                relationship.person1 = rr
                                let rr2 = ResourceReference()
                                rr2.resourceId = personId
                                relationship.person2 = rr2
                                family.append(relationship)
                            }
                            
                            if type == "mother" || type == "father" {
                                let relationship = Relationship()
                                relationship.type = "http://gedcomx.org/ParentChild"
                                let rr = ResourceReference()
                                let indi = rel["individual"] as! NSDictionary
                                rr.resourceId = indi["id"] as! String
                                relationship.person1 = rr
                                let rr2 = ResourceReference()
                                rr2.resourceId = personId
                                relationship.person2 = rr2
                                family.append(relationship)
                            }
                            
                            if type == "daughter" || type == "son" {
                                let relationship = Relationship()
                                relationship.type = "http://gedcomx.org/ParentChild"
                                let rr = ResourceReference()
                                let indi = rel["individual"] as! NSDictionary
                                rr.resourceId = personId
                                relationship.person1 = rr
                                let rr2 = ResourceReference()
                                rr2.resourceId = indi["id"] as! String
                                relationship.person2 = rr2
                                family.append(relationship)
                            }
                        }
                    }
                    
                    onCompletion(family, err)
                } else {
                    onCompletion(nil, err)
                }
            })
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getParents(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/child_in_families_connection", onCompletion: {data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let fams = json["data"] as? NSArray
                    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    let group = dispatch_group_create()
                    
                    if fams != nil {
                        for fam in fams! {
                            dispatch_group_enter(group)
                            let famjson = fam["family"] as! NSDictionary
                            let famid = famjson["id"] as! String
                            self.getData(famid, onCompletion: {famData, err in
                                if famData != nil {
                                    let famj = famData as! NSDictionary
                                    let fh = self.jsonConverter.convertFamily(famj)
                                    for link in fh.parents {
                                        let relId = link.href
                                        if relId != personId {
                                            let relationship = Relationship()
                                            relationship.type = "http://gedcomx.org/ParentChild"
                                            let rr = ResourceReference()
                                            rr.resourceId = relId
                                            relationship.person1 = rr
                                            let rr2 = ResourceReference()
                                            rr2.resourceId = personId
                                            relationship.person2 = rr2
                                            family.append(relationship)
                                        }
                                    }
                                }
                                dispatch_group_leave(group)
                            })
                        }
                    }
                    
                    dispatch_group_notify(group, queue) {
                        onCompletion(family, err)
                    }
                } else {
                    onCompletion(nil, err)
                }
            })
            
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getChildren(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/spouse_in_families_connection", onCompletion: {data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let fams = json["data"] as? NSArray
                    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    let group = dispatch_group_create()
                    
                    if fams != nil {
                        for fam in fams! {
                            dispatch_group_enter(group)
                            let famjson = fam["family"] as! NSDictionary
                            let famid = famjson["id"] as! String
                            self.getData(famid, onCompletion: {famData, err in
                                if famData != nil {
                                    let famj = famData as! NSDictionary
                                    let fh = self.jsonConverter.convertFamily(famj)
                                    for link in fh.children {
                                        let relId = link.href
                                        if relId != personId {
                                            let relationship = Relationship()
                                            relationship.type = "http://gedcomx.org/ParentChild"
                                            let rr = ResourceReference()
                                            rr.resourceId = personId
                                            relationship.person1 = rr
                                            let rr2 = ResourceReference()
                                            rr2.resourceId = relId
                                            relationship.person2 = rr2
                                            family.append(relationship)
                                        }
                                    }
                                }
                                dispatch_group_leave(group)
                            })
                        }
                    }
                    
                    dispatch_group_notify(group, queue) {
                        onCompletion(family, err)
                    }
                } else {
                    onCompletion(nil, err)
                }
            })
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getSpouses(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/spouse_in_families_connection", onCompletion: {data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let fams = json["data"] as? NSArray
                    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    let group = dispatch_group_create()
                    
                    if fams != nil {
                        for fam in fams! {
                            dispatch_group_enter(group)
                            let famjson = fam["family"] as! NSDictionary
                            let famid = famjson["id"] as! String
                            self.getData(famid, onCompletion: {famData, err in
                                if famData != nil {
                                    let famj = famData as! NSDictionary
                                    let fh = self.jsonConverter.convertFamily(famj)
                                    for link in fh.parents {
                                        let relId = link.href
                                        if relId != personId {
                                            let relationship = Relationship()
                                            relationship.type = "http://gedcomx.org/ParentChild"
                                            let rr = ResourceReference()
                                            rr.resourceId = relId
                                            relationship.person1 = rr
                                            let rr2 = ResourceReference()
                                            rr2.resourceId = personId
                                            relationship.person2 = rr2
                                            family.append(relationship)
                                        }
                                    }
                                }
                                dispatch_group_leave(group)
                            })
                        }
                    }
                    dispatch_group_notify(group, queue) {
                        onCompletion(family, err)
                    }
                } else {
                    onCompletion(nil, err)
                }
            })

		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPagedMemories(path: String, onCompletion: SourceDescriptionsResponse) {
        var media = [SourceDescription]()
        getData(path, onCompletion: {data, err in
            if data != nil {
                let json = data as! NSDictionary
                let allMed = json["data"] as? NSArray
                if allMed != nil {
                    for med in allMed! {
                        let sd = self.jsonConverter.convertMedia(med as! NSDictionary)
                        media.append(sd)
                    }
                }
                
                let paging = json["paging"] as? NSDictionary
                if paging != nil {
                    let next = paging!["next"] as? String
                    if next != nil {
                        self.getPagedMemories(next!, onCompletion: {page, err2 in
                            if page != nil {
                                media.appendContentsOf(page!)
                            }
                            onCompletion(media, err2)
                        })
                    } else {
                        onCompletion(media, err)
                    }
                } else {
                    onCompletion(media, err)
                }
            } else {
                onCompletion(media, err)
            }

        })

    }
    
    func getPersonMemories(personId: NSString, onCompletion: SourceDescriptionsResponse) {
        if sessionId != nil {
            var media = [SourceDescription]()
            
            let path = "\(personId)/media"
            getPagedMemories(path, onCompletion: {mediaList, err in
                if mediaList != nil {
                    media.appendContentsOf(mediaList!)
                }
                onCompletion(media, nil)
            })
            
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func downloadImage(uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse) {
        if sessionId != nil {
            let request = NSMutableURLRequest(URL: NSURL(string: uri as String)!)
            
            let session = NSURLSession.sharedSession()
            var headers = [String: String]()
            headers["Authorization"] = "Bearer \(familyGraph!.accessToken!)"
            
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
                        if !fileManager.fileExistsAtPath(folderUrl!.path!) {
                            try fileManager.createDirectoryAtURL(folderUrl!, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        let imagePath = folderUrl!.URLByAppendingPathComponent(fileName as String)
                        if data!.writeToURL(imagePath!, atomically: true) {
                            let returnPath = "\(folderName)/\(fileName)"
                            onCompletion(returnPath, error)
                        } else {
                            onCompletion(nil, error)
                        }
                        return;
                    } catch {
                        onCompletion(nil, NSError(domain: "MyHeritageService", code: 500, userInfo: ["message":"Unable to download and save image"]))
                        return;
                    }
                } else {
                    onCompletion(nil, NSError(domain: "MyHeritageService", code: 500, userInfo: ["message":"Unable to download and save image"]))
                }
            })
            task.resume()

		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPersonUrl(personId: NSString) -> NSString {
        let url = "http://www.myheritage.com/\(personId)"
        return url
    }
    
    func getData(path:String, onCompletion:(AnyObject?, NSError?) -> Void) {
        
        familyGraph.requestWithGraphPath(path, andDelegate: GetDataDelegate(onCompletion: onCompletion))
    }
    
}

class GetDataDelegate : NSObject, FGRequestDelegate {
    var handler:(AnyObject?, NSError?) -> Void
    init(onCompletion:(AnyObject?, NSError?) -> Void) {
        self.handler = onCompletion
    }
    
    @objc func request(request: FGRequest!, didLoad result: AnyObject!) {
        handler(result, nil)
    }
    
    @objc func request(request: FGRequest!, didFailWithError error: NSError!) {
        print(error)
        handler(nil, error)
    }
    
    @objc func request(request: FGRequest!, didLoadRawResponse data: NSData!) {
        
    }
    
    @objc func request(request: FGRequest!, didReceiveResponse response: NSURLResponse!) {
    }
    
    @objc func requestLoading(request: FGRequest!) {
    }
}

class SessionDelegate : NSObject, FGSessionDelegate {
    func fgDidLogin() {
        print("User logged into MyHeritage")
    }
    
    func fgDidNotLogin(cancelled:Bool) {
        print("User did not finish logging into MyHeritage")
    }
    
    func fgSessionInvalidated() {
        print("FG Sessions invalidated")
    }
}
