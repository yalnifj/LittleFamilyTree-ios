/* The following example shows how to use the FamilySearch service
   First edit FamilySearchService.swift and set the FS_APP_KEY property to your api key
*/


let remoteService = FamilySearchService.sharedInstance

remoteService.authenticate(username!, password: password!, onCompletion: { sessionId, err in
	print("sessionid=\(remoteService.sessionId)")
	if remoteService.sessionId != nil {
		print("Successfully logged into FamilySearch")
		remoteService.getPerson("LLL-1234", onCompletion: { json, err in 
			print(json)
		})
	} else {
		print("Unable to login to FamilySearch \(err)")
	}
})