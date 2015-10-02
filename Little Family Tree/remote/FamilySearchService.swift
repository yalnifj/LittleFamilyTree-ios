import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class FamilySearchService : RemoteService {
	let FS_PLATFORM_PATH = "https://sandbox.familysearch.org/platform/";
	//static let FS_PLATFORM_PATH = "https://familysearch.org/platform/";
	
	let FS_OAUTH2_PATH = "https://sandbox.familysearch.org/cis-web/oauth2/v3/token";
	//static let FS_OAUTH2_PATH = "https://ident.familysearch.org/cis-web/oauth2/v3/token";
	
	private let FS_APP_KEY = "a02j0000009AXffAAG";

    var sessionId: NSString?
	
	static let sharedInstance = FamilySearchService()
	
	
	func authenticate(username: String, password: String) {
		var params = [String: String]()
		params["grant_type"] = "password";
        params["client_id"] = FS_APP_KEY;
        params["username"] = username;
        params["password"] = password;
		
		sessionId = nil;
		let headers = [String: String]()
		
		makeHTTPPostRequest(FS_OAUTH2_PATH, body: params, headers: headers, onCompletion: {json, err in
			self.sessionId = json["access_token"].description
		})
	}
	
    func getCurrentPerson(onCompletion: ServiceResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer " + (sessionId?.description)!
			headers["Accept"] = "application/x-gedcomx-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/current-person", headers: headers, onCompletion: {json, err in
				onCompletion(json, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
	}
	
	func getPerson(personId: NSString, onCompletion: ServiceResponse) {
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
	
    func makeHTTPGetRequest(path: String, headers: [String: String], onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
 
        let session = NSURLSession.sharedSession()
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
 
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
	
    func makeHTTPPostJSONRequest(path: String, body: [String: AnyObject], headers: [String: String], onCompletion: ServiceResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
        
        do {
	 
            // Set the POST body for the request
            let options = NSJSONWritingOptions()
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: options)
            let session = NSURLSession.sharedSession()
	 
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            })
            task.resume()
        } catch let aError as NSError {
            print(aError)
        }
	}
	
    func makeHTTPPostRequest(path: String, body: [String: String], headers: [String: String], onCompletion: ServiceResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
		}
	 
		// Set the POST body for the request
		var postString = ""
		for(param, value) in body {
			postString += "\(param)=\(value)&";
		}

		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
	 
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
			let json:JSON = JSON(data: data!)
			onCompletion(json, error)
		})
		task.resume()
	}
}