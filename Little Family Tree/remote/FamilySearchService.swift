import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class FamilySearchService: RemoteService {
	static let FS_PLATFORM_PATH = "https://sandbox.familysearch.org/platform/";
	//static let FS_PLATFORM_PATH = "https://familysearch.org/platform/";
	
	static let FS_OAUTH2_PATH = "https://sandbox.familysearch.org/cis-web/oauth2/v3/token";
	//static let FS_OAUTH2_PATH = "https://ident.familysearch.org/cis-web/oauth2/v3/token";
	
	private static let FS_APP_KEY = "a02j0000009AXffAAG";

	var sessionId: NSString?
	
	static let sharedInstance = FamilySearchService()
	
	
	func authenticate(username: NSString, password: NSString) {
		var params = [String: String]()
		params["grant_type"]= "password";
        params["client_id"]= FS_APP_KEY;
        params["username"]= username;
        params["password"]= password;
		
		sessionId = nil;
		
		makeHTTPPostRequest(FS_OAUTH2_PATH, params, onCompletion: {json, err in
			sessionId = json["access_token"]
		})
	}
	
	func getCurrentPerson() {
	}
	
	func getPerson(personId: NSString) {
	}
	
	func getLastChangeForPerson(personId: NSString) {
	}
	
	func getPersonPortrait(personId: NSString) {
	}
	
	func getCloseRelatives(personId: NSString) {
	}
	
	func getParents(personId: NSString) {
	}
	
	func getChildren(personId: NSString) {
	}
	
	func getSpouses(personId: NSString) {
	}
	
	func getPersonMemories(personId: NSString) {
	}
	
	func downloadImage(uri: NSString, folderName: NSString, fileName: NSString) {
	}
	
	func getPersonUrl(personId: NSString) {
	}
	
	func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
 
        let session = NSURLSession.sharedSession()
 
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data)
            onCompletion(json, error)
        })
        task.resume()
    }
	
	func makeHTTPPostJSONRequest(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
		var err: NSError?
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
	 
		// Set the POST body for the request
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
		let session = NSURLSession.sharedSession()
	 
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			let json:JSON = JSON(data: data)
			onCompletion(json, err)
		})
		task.resume()
	}
	
	func makeHTTPPostRequest(path: String, body: [String: String], onCompletion: ServiceResponse) {
		var err: NSError?
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
	 
		// Set the POST body for the request
		var postString = ""
		for(param, value) in body {
			postString += "\(param)=\(value)&";
		}

		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
	 
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			let json:JSON = JSON(data: data)
			onCompletion(json, err)
		})
		task.resume()
	}
}