import Foundation

typealias StringResponse = (NSString?, NSError?) -> Void
typealias ServiceResponse = (JSON, NSError?) -> Void

class FamilySearchService {
	let FS_PLATFORM_PATH_SAND = "https://sandbox.familysearch.org/platform/"
    let FS_PLATFORM_PATH_BETA = "https://beta.familysearch.org/platform/"
	let FS_PLATFORM_PATH_PROD = "https://familysearch.org/platform/"
    var FS_PLATFORM_PATH:String
	
	let FS_OAUTH2_PATH_SAND = "https://sandbox.familysearch.org/cis-web/oauth2/v3/token"
    let FS_OAUTH2_PATH_BETA = "https://identbeta.familysearch.org/cis-web/oauth2/v3/token"
	let FS_OAUTH2_PATH_PROD = "https://ident.familysearch.org/cis-web/oauth2/v3/token"
    var FS_OAUTH2_PATH:String
	
	private let FS_APP_KEY = "your_api_key_here"

    var sessionId: NSString?
    
    private init() {
        FS_PLATFORM_PATH = FS_PLATFORM_PATH_PROD
        FS_OAUTH2_PATH = FS_OAUTH2_PATH_PROD
    }
	
	static let sharedInstance = FamilySearchService()
    
    func setEnvironment(env:String) {
        if (env=="sandbox") {
            FS_PLATFORM_PATH = FS_PLATFORM_PATH_SAND
            FS_OAUTH2_PATH = FS_OAUTH2_PATH_SAND
        }
        else if (env=="beta") {
            FS_PLATFORM_PATH = FS_PLATFORM_PATH_BETA
            FS_OAUTH2_PATH = FS_OAUTH2_PATH_BETA
        }
        else if (env=="prod") {
            FS_PLATFORM_PATH = FS_PLATFORM_PATH_PROD
            FS_OAUTH2_PATH = FS_OAUTH2_PATH_PROD
        }
    }
	
	
	func authenticate(username: String, password: String, onCompletion: StringResponse) {
		var params = [String: String]()
		params["grant_type"] = "password";
        params["client_id"] = FS_APP_KEY;
        params["username"] = username;
        params["password"] = password;
        
		//-- change to sandbox environment for known sandbox usernames
		//-- simplifies testing from an app store release
        if username=="tum000205905" || username=="tum000142047" {
            setEnvironment("sandbox")
        }
		
		sessionId = nil;
		let headers = [String: String]()
		
		makeHTTPPostRequest(FS_OAUTH2_PATH, body: params, headers: headers, onCompletion: {json, err in
			self.sessionId = json["access_token"].description
            if self.sessionId!.length == 0 || self.sessionId! == "null" {
                self.sessionId = nil
                if err == nil {
                    let jerror = json["error_description"]
                    if jerror != nil {
                        let error = NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":jerror.description])
                        onCompletion(self.sessionId, error)
                        return
                    }
                }
            }
			onCompletion(self.sessionId, err)
		})
	}
	
	func getPerson(personId: NSString, onCompletion: ServiceResponse) {
		if (sessionId != nil) {
			var headers = [String: String]()
			headers["Authorization"] = "Bearer \(sessionId!)"
			headers["Accept"] = "application/x-gedcomx-v1+json"
			makeHTTPGetRequest(FS_PLATFORM_PATH + "tree/persons/\(personId)", headers: headers, onCompletion: {json, err in
				onCompletion(json, err)
			})
		} else {
			onCompletion(nil, NSError(domain: "FamilySearchService", code: 401, userInfo: ["message":"Not authenticated with FamilySearch"]))
		}
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
	
    func makeHTTPPostJSONRequest(path: String, body: [String: AnyObject], headers: [String: String], onCompletion: ServiceResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
		
		// Set the headers
		for(field, value) in headers {
			request.setValue(value, forHTTPHeaderField: field);
            //print("Header \(field):\(value)")
		}
        
        do {
	 
            // Set the POST body for the request
            let options = NSJSONWritingOptions()
            print("makeHTTPPostJSONRequest: \(request)")
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: options)
            let session = NSURLSession.sharedSession()
            session.configuration.HTTPMaximumConnectionsPerHost = 5
	 
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if error != nil {
                    print(error!.description)
                }
                if response == nil {
                    onCompletion(nil, error)
                    return
                }
                let httpResponse = response as! NSHTTPURLResponse
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
        } catch let aError as NSError {
            print(aError)
        }
	}
	
    func makeHTTPPostRequest(path: String, body: [String: String], headers: [String: String], onCompletion: ServiceResponse) {
		let request = NSMutableURLRequest(URL: NSURL(string: path)!)
	 
		// Set the method to POST
		request.HTTPMethod = "POST"
        
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
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let session = NSURLSession.sharedSession()
        session.configuration.HTTPMaximumConnectionsPerHost = 5
	 
        print("makeHTTPPostRequest: \(request)?\(postString)")
		let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                print(error!.description)
            }
            if response == nil {
                onCompletion(nil, error)
                return
            }
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode != 200 {
                print(response)
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