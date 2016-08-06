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
    
    func getCurrentUser() {
        class CurrentUserDelegate : NSObject, FGRequestDelegate {
            @objc func request(request: FGRequest!, didLoad result: AnyObject!) {
                
            }
            
            @objc func request(request: FGRequest!, didFailWithError error: NSError!) {
                
            }
            
            @objc func request(request: FGRequest!, didLoadRawResponse data: NSData!) {
            
            }
            
            @objc func request(request: FGRequest!, didReceiveResponse response: NSURLResponse!) {
            }
            
            @objc func requestLoading(request: FGRequest!) {
            }
        }
        
        familyGraph.requestWithGraphPath("me", andDelegate: CurrentUserDelegate())
    }
    
    func getCurrentPerson(onCompletion: PersonResponse) {
        
    }
    
    func getPerson(personId: NSString, ignoreCache: Bool, onCompletion: PersonResponse) {
        
    }
    
    func getLastChangeForPerson(personId: NSString, onCompletion: LongResponse) {
        
    }
    
    func getPersonPortrait(personId: NSString, onCompletion: LinkResponse) {
        
    }
    
    func getCloseRelatives(personId: NSString, onCompletion: RelationshipsResponse) {
        
    }
    
    func getParents(personId: NSString, onCompletion: RelationshipsResponse) {
        
    }
    
    func getChildren(personId: NSString, onCompletion: RelationshipsResponse) {
        
    }
    
    func getSpouses(personId: NSString, onCompletion: RelationshipsResponse) {
        
    }
    
    func getPersonMemories(personId: NSString, onCompletion: SourceDescriptionsResponse) {
        
    }
    
    func downloadImage(uri: NSString, folderName: NSString, fileName: NSString, onCompletion: StringResponse) {
        
    }
    
    func getPersonUrl(personId: NSString) -> NSString {
        return ""
    }
    
    func makeHTTPGetRequest(path: String, headers: [String: String], onCompletion: ServiceResponse) {
        self.makeHTTPGetRequest(path, headers: headers, count: 1, onCompletion: onCompletion)
    }
    
    var lastRequestTime:NSDate = NSDate()
    var requestDelay:NSTimeInterval = -0.3
    func makeHTTPGetRequest(path: String, headers: [String: String], count: Int, onCompletion: ServiceResponse) {
        let timeSinceLastRequest = lastRequestTime.timeIntervalSinceNow
        if timeSinceLastRequest > requestDelay {
            self.throttled(0 - requestDelay, closure: {
                self.makeHTTPGetRequest(path, headers: headers, count: 1, onCompletion: onCompletion)
            })
            return
        }
        lastRequestTime = NSDate()
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        let myDelegate = RedirectSessionDelegate(headers: headers)
        // too many requests coming where are they coming from?
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: myDelegate, delegateQueue: nil)
        session.configuration.HTTPMaximumConnectionsPerHost = 2
        
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
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
                print(response)
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
                    onCompletion(nil, error)
                }
                return
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

    func throttled(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
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