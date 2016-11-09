//
//  MyHeritageService.swift
//  Little Family Tree
//
//  Created by Melissa on 7/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class MyHeritageService: RemoteService {

    var sessionId: String?
    
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
    
    internal func authenticate(_ username: String, password: String, onCompletion: @escaping StringResponse) {
        sessionId = familyGraph.accessToken as String?
        onCompletion(sessionId, nil)
    }
    
    func authWithDialog() {
        let perms:[AnyObject] = ["offline_access" as AnyObject]
        familyGraph.authorize(perms)
    }
    
    func getCurrentUser(_ onCompletion: @escaping (NSDictionary?, NSError?) -> Void) {
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
    
    func getCurrentPerson(_ onCompletion: @escaping PersonResponse) {
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
    
    func getPerson(_ personId: String, ignoreCache: Bool, onCompletion: @escaping PersonResponse) {
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
    
    internal func getLastChangeForPerson(_ personId: String, onCompletion: @escaping LongResponse) {
        if sessionId != nil {
            // TODO
            onCompletion(nil, nil)
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPersonPortrait(_ personId: String, onCompletion: @escaping LinkResponse) {
        if sessionId != nil {
            var portrait:Link? = nil
            var err:NSError? = nil
            
            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            group.enter()
            self.getPerson(personId, ignoreCache: false, onCompletion: {person, err1 in
                err = err1
                if person != nil {
                    let media = person?.media
                    if media != nil {
                        for sr in media! {
                            for link1 in sr.links {
                                let objeId = link1.href
                                if objeId != nil {
                                    group.enter()
                                    self.getData(objeId!, onCompletion: {data, err2 in
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
                                        group.leave()
                                    })
                                }
                            }
                        }
                    }
                }
                group.leave()
            })
            
            group.notify(queue: queue) {
                onCompletion(portrait, err)
            }
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getCloseRelatives(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/immediate_family", onCompletion: { data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let peopleArray = json["data"] as? NSArray
                    if peopleArray != nil {
                        for rel in peopleArray! {
                            let relDict = rel as! NSDictionary
                            let type = relDict["relationship_type"] as! String
                            if type == "wife" || type == "husband" {
                                let relationship = Relationship()
                                relationship.type = "http://gedcomx.org/Couple"
                                let rr = ResourceReference()
                                let indi = relDict["individual"] as! NSDictionary
                                rr.resourceId = indi["id"] as? String
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
                                let indi = relDict["individual"] as! NSDictionary
                                rr.resourceId = indi["id"] as? String
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
                                let indi = relDict["individual"] as! NSDictionary
                                rr.resourceId = personId
                                relationship.person1 = rr
                                let rr2 = ResourceReference()
                                rr2.resourceId = indi["id"] as? String
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
    
    func getParents(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/child_in_families_connection", onCompletion: {data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let fams = json["data"] as? NSArray
                    let queue = DispatchQueue.global()
                    let group = DispatchGroup()
                    
                    if fams != nil {
                        for fam in fams! {
                            group.enter()
                            let famDict = fam as! NSDictionary
                            let famjson = famDict["family"] as! NSDictionary
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
                                group.leave()
                            })
                        }
                    }
                    
                    group.notify(queue: queue) {
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
    
    func getChildren(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/spouse_in_families_connection", onCompletion: {data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let fams = json["data"] as? NSArray
                    let queue = DispatchQueue.global()
                    let group = DispatchGroup()
                    
                    if fams != nil {
                        for fam in fams! {
                            let famDict = fam as! NSDictionary
                            group.enter()
                            let famjson = famDict["family"] as! NSDictionary
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
                                group.leave()
                            })
                        }
                    }
                    
                    group.notify(queue: queue) {
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
    
    func getSpouses(_ personId: String, onCompletion: @escaping RelationshipsResponse) {
        if sessionId != nil {
            getData("\(personId)/spouse_in_families_connection", onCompletion: {data, err in
                if data != nil {
                    var family = [Relationship]()
                    let json = data as! NSDictionary
                    let fams = json["data"] as? NSArray
                    let queue = DispatchQueue.global()
                    let group = DispatchGroup()
                    
                    if fams != nil {
                        for fam in fams! {
                            group.enter()
                            let famDict = fam as! NSDictionary
                            let famjson = famDict["family"] as! NSDictionary
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
                                group.leave()
                            })
                        }
                    }
                    group.notify(queue: queue) {
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
    
    func getPagedMemories(_ path: String, onCompletion: @escaping SourceDescriptionsResponse) {
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
                                media.append(contentsOf: page!)
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
    
    func getPersonMemories(_ personId: String, onCompletion: @escaping SourceDescriptionsResponse) {
        if sessionId != nil {
            var media = [SourceDescription]()
            
            let path = "\(personId)/media"
            getPagedMemories(path, onCompletion: {mediaList, err in
                if mediaList != nil {
                    media.append(contentsOf: mediaList!)
                }
                onCompletion(media, nil)
            })
            
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func downloadImage(_ uri: String, folderName: String, fileName: String, onCompletion: @escaping StringResponse) {
        if sessionId != nil {
            let request = NSMutableURLRequest(url: URL(string: uri as String)!)
            
            let session = URLSession.shared
            var headers = [String: String]()
            headers["Authorization"] = "Bearer \(familyGraph!.accessToken!)"
            
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
    
    func getPersonUrl(_ personId: String) -> String {
        let url = "https://www.myheritage.com/\(personId)"
        return url
    }
    
    func getData(_ path:String, onCompletion:@escaping (AnyObject?, NSError?) -> Void) {
        
        familyGraph.request(withGraphPath: path, andDelegate: GetDataDelegate(onCompletion: onCompletion))
    }
    
}

class GetDataDelegate : NSObject, FGRequestDelegate {
    var handler:(AnyObject?, NSError?) -> Void
    init(onCompletion:@escaping (AnyObject?, NSError?) -> Void) {
        self.handler = onCompletion
    }
    
    @objc func request(_ request: FGRequest!, didLoad result: Any!) {
        handler(result as AnyObject?, nil)
    }
    
    @objc func request(_ request: FGRequest!, didFailWithError error: Error!) {
        print(error)
        handler(nil, error as NSError?)
    }
    
    @objc func request(_ request: FGRequest!, didLoadRawResponse data: Data!) {
        
    }
    
    @objc func request(_ request: FGRequest!, didReceive response: URLResponse!) {
    }
    
    @objc func requestLoading(_ request: FGRequest!) {
    }
}

class SessionDelegate : NSObject, FGSessionDelegate {
    func fgDidLogin() {
        print("User logged into MyHeritage")
    }
    
    func fgDidNotLogin(_ cancelled:Bool) {
        print("User did not finish logging into MyHeritage")
    }
    
    func fgSessionInvalidated() {
        print("FG Sessions invalidated")
    }
}
