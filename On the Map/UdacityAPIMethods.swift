//
//  UdacityAPIMethods.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/11/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Udacity API Methods
class UdacityAPIMethods: NSObject {
    
    // MARK: Properties
    var session = URLSession.shared
    var jsonData: AnyObject! = nil
    var sessionID: String? = nil
    var userID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    // MARK: Initializers
    override init() {
        
        super.init()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityAPIMethods {
        
        struct Singleton {
            static var sharedInstance = UdacityAPIMethods()
        }

        return Singleton.sharedInstance
    }
    
    // MARK: Tasks
    func taskForGETMethod(_ request: NSMutableURLRequest, completionHandlerForGET: @escaping (_ success: Bool, _ error: String?, _ result: AnyObject?) -> Void) -> URLSessionDataTask {
        
        // Step-3, 4: Configure and make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Guard if there was an error
            guard (error == nil) else {
                completionHandlerForGET(false, Constants.ErrorMessage.sessionRequestError.description, nil)
                return
            }
            
            // Guard if response is not in success range
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForGET(false, Constants.ErrorMessage.sessionRequestResponseError.description, nil)
                return
            }
            
            // Guard if no data was returned
            guard let data = data else {
                completionHandlerForGET(false, Constants.ErrorMessage.sessionRequestDataError.description, nil)
                return
            }
            
            // Step-5, 6: Parse and use the data
            self.parseData(data, completionHandlerForParsedData: completionHandlerForGET)
        }
        
        // Step-7: Start the request
        task.resume()
        
        return task
    }
    
    // MARK: Authentication
    func loginWithID(_ parameters: [String:String], authentication: String, completionHandlerForLogin: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Chain completion handlers for each request so that they run one after the other
        createSession(parameters, authentication)  { (success, error, result) in
            if success {
                
                // Success: save parsed JSON data
                self.jsonData = result
                
                self.getSessionID(self.jsonData) { (success, error, result) in
                    if success {
                        
                        // Success: save session ID
                        self.sessionID = result
                        
                        self.getUserID(self.jsonData) { (success, error, result) in
                            if success {
                                
                                // Success: save user ID
                                self.userID = result
                                
                                completionHandlerForLogin(true, nil)
                            } else {
                                completionHandlerForLogin(false, error)
                            }
                        }
                    } else {
                        completionHandlerForLogin(false, error)
                    }
                }
            } else {
                completionHandlerForLogin(false, error)
            }
        }
    }
    
    // MARK: POST Methods
    func createSession(_ parameters: [String:String], _ authentication: String, completionHandlerForSession: @escaping (_ success: Bool, _ error: String?, _ result: AnyObject?) -> Void) {
        
        // Step-2: Build the URL
        let request = NSMutableURLRequest(url: url(withPathExtension: Udacity.Methods.Session))
        
        // Step-3: Configure the request
        request.httpMethod = Udacity.Methods.Post
        request.addValue(Udacity.Methods.HTTPHeader.ValueApplicationJSON, forHTTPHeaderField: Udacity.Methods.HTTPHeader.KeyAccept)
        request.addValue(Udacity.Methods.HTTPHeader.ValueApplicationJSON, forHTTPHeaderField: Udacity.Methods.HTTPHeader.KeyContentType)
        request.httpBody = jsonBody(parameters as [String : AnyObject], authentication)
        
        // Step-4: Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Guard if there was an error
            guard (error == nil) else {
                completionHandlerForSession(false, Constants.ErrorMessage.sessionRequestError.description, nil)
                return
            }
            
            // Guard if response is not in success range
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode == 401 || statusCode == 403 {
                    completionHandlerForSession(false, Constants.ErrorMessage.invalidCredentials.description, nil)
                } else {
                    completionHandlerForSession(false, Constants.ErrorMessage.sessionRequestResponseError.description, nil)
                }
                
                return
            }
            
            // Guard if no data was returned
            guard let data = data else {
                completionHandlerForSession(false, Constants.ErrorMessage.sessionRequestDataError.description, nil)
                return
            }
            
            // Step-5, 6: Parse and use the data
            self.parseData(data, completionHandlerForParsedData: completionHandlerForSession)
        }
        
        // Step-7: Start the request
        task.resume()
    }
    
    // MARK: DELETE Methods
    func deleteSession(completionHandlerForDeleteSession: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Step-1: Build the URL
        let request = NSMutableURLRequest(url: url(withPathExtension: Udacity.Methods.Session))
        
        // Step-2: Configure the request
        request.httpMethod = Udacity.Methods.Delete
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Udacity.XSRF.CookieNameXSRF {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Udacity.XSRF.HTTPHeaderXSRF)
        }
        
        // Step-3: Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Step-4: Send status to completion handler
            if error != nil {
                completionHandlerForDeleteSession(false, Constants.ErrorMessage.sessionRequestError.description)
                return
            } else {
                completionHandlerForDeleteSession(true, nil)
            }
        }
        
        // Step-5: Start the request
        task.resume()
    }
    
    // MARK: GET Methods
    func getStudentName(_ completionHandlerForStudentName: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Step-1: Set the parameters
        let id: String
        
        if let stringUserID = userID {
            id = "/" + stringUserID
        } else {
            id = "/"
        }
        
        // Step-2: Build the URL
        let request = NSMutableURLRequest(url: url(withPathExtension: Udacity.Methods.Users + id))
        
        // Make the request
        let _ = taskForGETMethod(request) { (success, error, result) in
            
            // Guard if there was an error
            guard (error == nil) else {
                completionHandlerForStudentName(false, error)
                return
            }
            
            // Get student name
            if success {
                
                // Success: save parsed JSON data
                self.jsonData = result
                
                self.getFirstName(self.jsonData) { (success, error, result) in
                    if success {
                        
                        // Success: save student first name
                        self.firstName = result
                        
                        self.getLastName(self.jsonData) { (success, error, result) in
                            if success {
                                
                                // Success: save student last name
                                self.lastName = result
                                
                                completionHandlerForStudentName(true, nil)
                            } else {
                                completionHandlerForStudentName(false, error)
                            }
                        }
                    } else {
                        completionHandlerForStudentName(false, error)
                    }
                }
            } else {
                completionHandlerForStudentName(false, error)
            }
        }
    }
}

// MARK: - Udacity API Methods (Helper Functions)
private extension UdacityAPIMethods {
    
    func url(withPathExtension: String? = nil) -> URL {
        
        // Create an URL with path extension
        var components = URLComponents()
        components.scheme = Udacity.Constants.ApiScheme
        components.host = Udacity.Constants.ApiHost
        components.path = Udacity.Constants.ApiPath + (withPathExtension ?? "")
        
        return components.url!
    }
    
    func jsonBody(_ parameters: [String:AnyObject], _ authentication: String? = nil) -> Data {
        
        // Build JSON body from parameters
        var jsonBody: Data = Data()
        if authentication == Udacity.JSONBodyKeys.UdacityLogin {
            
            // Authentication: Udacity ID & password
            jsonBody = "{\"\(authentication!)\": {\"\(Udacity.JSONBodyKeys.Username)\": \"\(parameters[Udacity.JSONBodyKeys.Username]!)\", \"\(Udacity.JSONBodyKeys.Password)\": \"\(parameters[Udacity.JSONBodyKeys.Password]!)\"}}".data(using: String.Encoding.utf8)!
        } else if authentication == Udacity.JSONBodyKeys.FacebookLogin {
            
            // Authentication: Facebook ID & password
            jsonBody = "{\"\(authentication!)\": {\"\(Udacity.JSONBodyKeys.AccessToken)\": \"\(parameters[Udacity.JSONBodyKeys.AccessToken]!);\"}}".data(using: String.Encoding.utf8)!
        }
        
        return jsonBody
    }
    
    func parseData(_ data: Data, completionHandlerForParsedData: (_ success: Bool, _ error: String?, _ result: AnyObject?) -> Void) {
        
        //Parse the data
        //let range = Range(uncheckedBounds: (5, data.count - 5))
        let range = Range(uncheckedBounds: (5, data.count))
        let newData = data.subdata(in: range) /* subset response data! */
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
        } catch {
            completionHandlerForParsedData(false, Constants.ErrorMessage.parseDataError.description, nil)
            return
        }
        
        // Use parsed data
        completionHandlerForParsedData(true, nil, parsedResult)
    }
    
    func getSessionID(_ jsonData: AnyObject, completionHandlerForSessionID: (_ success: Bool, _ error: String?, _ result: String?) -> Void) {
        
        // Guard if session key is not in the result
        guard let session = jsonData[Udacity.JSONResponseKeys.Session] as? [String:AnyObject] else {
            completionHandlerForSessionID(false, Constants.ErrorMessage.sessionID.description, nil)
            return
        }
        
        // Get session ID
        if let sessionID = session[Udacity.JSONResponseKeys.SessionID] as? String {
            completionHandlerForSessionID(true, nil, sessionID)
        } else {
            completionHandlerForSessionID(false, Constants.ErrorMessage.sessionID.description, nil)
        }
    }
    
    func getUserID(_ jsonData: AnyObject, completionHandlerForUserID: (_ success: Bool, _ error: String?, _ result: String?) -> Void) {
        
        // Guard if account key is not in the result
        guard let account = jsonData[Udacity.JSONResponseKeys.Account] as? [String:AnyObject] else {
            completionHandlerForUserID(false, Constants.ErrorMessage.userID.description, nil)
            return
        }
        
        // Get user ID
        if let userID = account[Udacity.JSONResponseKeys.UserID] as? String {
            completionHandlerForUserID(true, nil, userID)
        } else {
            completionHandlerForUserID(false, Constants.ErrorMessage.userID.description, nil)
        }
    }
    
    func getFirstName(_ jsonData: AnyObject, completionHandlerForFirstName: (_ success: Bool, _ error: String?, _ result: String?) -> Void) {
        
        // Guard if user info key is not in the result
        guard let userInfo = jsonData[Udacity.JSONResponseKeys.UserInfo] as? [String:AnyObject] else {
            completionHandlerForFirstName(false, Constants.ErrorMessage.userInfo.description, nil)
            return
        }
        
        // Get user first name
        if let stringFirstName = userInfo[Udacity.JSONResponseKeys.FirstName] as? String {
            completionHandlerForFirstName(true, nil, stringFirstName)
        } else {
            completionHandlerForFirstName(true, nil, "")
        }
    }
    
    func getLastName(_ jsonData: AnyObject, completionHandlerForLastName: (_ success: Bool, _ error: String?, _ result: String?) -> Void) {
        
        // Guard if user info key is not in the result
        guard let userInfo = jsonData[Udacity.JSONResponseKeys.UserInfo] as? [String:AnyObject] else {
            completionHandlerForLastName(false, Constants.ErrorMessage.userInfo.description, nil)
            return
        }
        
        // Get user last name
        if let stringLastName = userInfo[Udacity.JSONResponseKeys.LastName] as? String {
            completionHandlerForLastName(true, nil, stringLastName)
        } else {
            completionHandlerForLastName(true, nil, "")
        }
    }
}

