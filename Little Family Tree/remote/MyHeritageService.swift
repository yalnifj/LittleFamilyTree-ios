//
//  MyHeritageService.swift
//  Little Family Tree
//
//  Created by Melissa on 7/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import UIKit

class MyHeritageService: RemoteService {

    var sessionId: String?
    
    var clientId = "0d9d29c39d0ded7bd6a9e334e5f673a7"
    var clientSecret = "9021b2dcdb4834bd12a491349f61cb27"
    var jsonConverter:FamilyGraphJsonConverter!
    var baseUrl = "https://familygraph.myheritage.com/"
    
    var sessionListener:MyHeritageSessionListener?
	
	var userId:String?
	
	var personCache = [String: Person]()
    
    init() {
        jsonConverter = FamilyGraphJsonConverter()
    }
    
    internal func authenticate(_ username: String, password: String, onCompletion: @escaping StringResponse) {
        sessionId = password
        onCompletion(sessionId, nil)
    }
    
    func getCurrentUser(_ onCompletion: @escaping (JSON?, NSError?) -> Void) {
        getData("me", onCompletion: { data, err in
			if data != nil {
                let json = data as! JSON
				self.userId = json["id"].string
                onCompletion(json, err)
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
					let indi = userData!["default_individual"]
					let indiId = indi["id"].string
					self.getPerson(indiId!, ignoreCache: false, onCompletion: onCompletion)
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
                if personCache[personId] != nil {
                    onCompletion(personCache[personId], nil)
                    return
                }
            }
			
            getData(personId, onCompletion: {data, err in
                if data != nil {
                    let person = self.jsonConverter.createJsonPerson(data as! JSON)
                    
                    self.getData("\(personId)/events", onCompletion: {eventData, err in
                        if eventData != nil {
                            self.jsonConverter.processEvents(eventData as! JSON, person: person)
                        }
                        
                        self.personCache[personId] = person
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
                                        if data != JSON.null {
                                            let sd = self.jsonConverter.convertMedia(data as! JSON)
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
                    let json = data as! JSON
                    let peopleArray = json["data"].array
                    if peopleArray != nil {
                        for rel in peopleArray! {
                            let relDict = rel
                            let type = relDict["relationship_type"].string
                            if type == "wife" || type == "husband" {
                                let relationship = Relationship()
                                relationship.type = "http://gedcomx.org/Couple"
                                let rr = ResourceReference()
                                let indi = relDict["individual"]
                                rr.resourceId = indi["id"].string
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
                                let indi = relDict["individual"]
                                rr.resourceId = indi["id"].string
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
                                let indi = relDict["individual"]
                                rr.resourceId = personId
                                relationship.person1 = rr
                                let rr2 = ResourceReference()
                                rr2.resourceId = indi["id"].string
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
                    let json = data as! JSON
                    let fams = json["data"].array
                    let queue = DispatchQueue.global()
                    let group = DispatchGroup()
                    
                    if fams != nil {
                        for fam in fams! {
                            group.enter()
                            var famjson = fam
                            if fam["family"] != JSON.null {
                                famjson = fam["family"]
                            }
                            let famid = famjson["id"].string
                            self.getData(famid!, onCompletion: {famData, err in
                                if famData != JSON.null {
                                    let famj = famData
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
                    let json = data as! JSON
                    let fams = json["data"].array
                    let queue = DispatchQueue.global()
                    let group = DispatchGroup()
                    
                    if fams != nil {
                        for fam in fams! {
                            group.enter()
                            var famjson = fam
                            if fam["family"] != JSON.null {
                                famjson = fam["family"]
                            }
                            let famid = famjson["id"].string
                            self.getData(famid!, onCompletion: {famData, err in
                                if famData != nil {
                                    let famj = famData
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
                    let json = data as! JSON
                    let fams = json["data"].array
                    let queue = DispatchQueue.global()
                    let group = DispatchGroup()
                    
                    if fams != nil {
                        for fam in fams! {
                            group.enter()
                            var famjson = fam
                            if fam["family"] != JSON.null {
                                famjson = fam["family"]
                            }
                            let famid = famjson["id"].string
                            self.getData(famid!, onCompletion: {famData, err in
                                if famData != nil {
                                    let famj = famData
                                    let fh = self.jsonConverter.convertFamily(famj)
                                    for link in fh.parents {
                                        let relId = link.href
                                        if relId != personId {
                                            let relationship = Relationship()
                                            relationship.type = "http://gedcomx.org/Couple"
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
                let json = data as! JSON
                let allMed = json["data"].array
                if allMed != nil {
                    for med in allMed! {
                        let sd = self.jsonConverter.convertMedia(med)
                        media.append(sd)
                    }
                }
                
                let paging = json["paging"]
                if paging != nil {
                    let next = paging["next"].string
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
            headers["Authorization"] = "Bearer \(sessionId!)"
            
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
    
    func getData(_ path:String, onCompletion:@escaping (JSON, NSError?) -> Void) {
        
        //familyGraph.request(withGraphPath: path, andDelegate: GetDataDelegate(onCompletion: onCompletion))
        var headers = [String: String]()
        headers["Authorization"] = "Bearer \(sessionId!)"
        var url = "\(baseUrl)\(path)"
        makeHTTPGetRequest(url, headers: headers, onCompletion: onCompletion)
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
                    SyncQ.getInstance().pauseForTime(60)
                    print("Connection throttled... delaying 20 seconds")
                    self.throttled(20, closure: {
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

protocol MyHeritageSessionListener {
    func userLoggedIn();
    func userDidNotLogIn();
}
