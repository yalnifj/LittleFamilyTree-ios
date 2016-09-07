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
	
	var userId:String?
	
	var personCache = [String: Person]()
    
    init() {
        sessionDelegate = SessionDelegate()
        familyGraph = FamilyGraph(clientId: self.clientId, andDelegate: sessionDelegate)
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
			
			
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPersonPortrait(personId: NSString, onCompletion: LinkResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getParents(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getChildren(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getSpouses(personId: NSString, onCompletion: RelationshipsResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPersonMemories(personId: NSString, onCompletion: SourceDescriptionsResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func downloadImage(uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse) {
        if sessionId != nil {
		} else {
			onCompletion(nil, NSError(domain: "MyHeritageService", code: 401, userInfo: ["message":"Not authenticated"]))
		}
    }
    
    func getPersonUrl(personId: NSString) -> NSString {
        return ""
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