//
//  MyHeritageService.swift
//  Little Family Tree
//
//  Created by Melissa on 7/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class MyHeritageService: NSObject, RemoteService, FGSessionDelegate {
    var sessionId: NSString?
    
    var familyGraph:FamilyGraph?
    var clientId = ""
    
    func authenticate(username: String, password: String, onCompletion: StringResponse) {
        familyGraph = FamilyGraph(clientId: self.clientId, andDelegate: self)
        let perms:[AnyObject] = []
        familyGraph?.authorize(perms)
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