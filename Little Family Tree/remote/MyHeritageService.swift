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
    
    func getData(path:String, onCompletion:(AnyObject?, NSError?) -> Void) {
        
        
        familyGraph.requestWithGraphPath("me", andDelegate: GetDataDelegate(onCompletion: onCompletion))
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