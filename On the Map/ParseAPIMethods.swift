//
//  ParseAPIMethods.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/11/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Parse API Methods
class ParseAPIMethods: NSObject {
    
    // MARK: Properties
    var session = URLSession.shared
    
    // MARK: Initializers
    override init() {
        
        super.init()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseAPIMethods {
        
        struct Singleton {
            static var sharedInstance = ParseAPIMethods()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Tasks
    func taskForGETMethod(_ request: NSMutableURLRequest, completionHandlerForGET: @escaping (_ success: Bool, _ error: String?, _ result: AnyObject?) -> Void) -> URLSessionDataTask {
        
        // Step-3: Configure the request
        request.addValue(Parse.Methods.HTTPHeader.ParseApplicationIDValue, forHTTPHeaderField: Parse.Methods.HTTPHeader.ParseApplicationID)
        request.addValue(Parse.Methods.HTTPHeader.ParseRestAPIKeyValue, forHTTPHeaderField: Parse.Methods.HTTPHeader.ParseRestAPIKey)
        
        // Step-4: Make the request
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
    
    func taskForPOSTMethod(_ request: NSMutableURLRequest, completionHandlerForPOST: @escaping (_ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // Step-4: Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Guard if there was an error
            guard (error == nil) else {
                completionHandlerForPOST(false, Constants.ErrorMessage.sessionRequestError.description)
                return
            }
            
            // Guard if response is not in success range
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForPOST(false, Constants.ErrorMessage.sessionRequestResponseError.description)
                return
            }
            
            // Guard if no data was returned
            guard data != nil else {
                completionHandlerForPOST(false, Constants.ErrorMessage.sessionRequestDataError.description)
                return
            }
            
            // Step-5, 6: Success
            completionHandlerForPOST(true, nil)
        }
        
        // Step-7: Start the request
        task.resume()
        
        return task
    }
    
    // MARK: GET Methods
    func getStudentsInformation(_ completionHandlerForStudentsInformation: @escaping (_ success: Bool, _ error: String?, _ result: [StudentInformation]?) -> Void) {
        
        // Step-1: Set the parameters
        let parameters: [String:String] = [
            Parse.Methods.QueryItems.Key.Limit: Parse.Methods.QueryItems.Value.Limit,
            //Parse.Methods.QueryItems.Key.Skip: Parse.Methods.QueryItems.Value.Skip,
            Parse.Methods.QueryItems.Key.Order: Parse.Methods.QueryItems.Value.DescendingOrderOfUpdate
        ]
        
        // Step-2: Build the URL
        let request = NSMutableURLRequest(url: urlFrom(parameters, withPathExtension: Parse.Methods.StudentLocation))
        
        // Make the request
        let _ = taskForGETMethod(request) { (success, error, result) in
            
            // Guard if there was an error
            guard (error == nil) else {
                completionHandlerForStudentsInformation(false, error, nil)
                return
            }
            
            // Get student information
            if success {
                if let result = result?[Parse.JSONKeys.Result] as? [[String:AnyObject]] {
                    let studentsInformation = StudentInformation.allProfilesFrom(result)
                    completionHandlerForStudentsInformation(true, nil, studentsInformation)
                } else {
                    completionHandlerForStudentsInformation(false, Constants.ErrorMessage.getStudentsInformationError.description, nil)
                }
            }
        }
    }
    
    // MARK: POST Methods
    func createNewStudentLocation(_ parameters: [String:AnyObject], completionHandlerForNewStudentLocation: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Step-2: Build the URL
        let request = NSMutableURLRequest(url: url(withPathExtension: Parse.Methods.StudentLocation))
        
        // Step-3: Configure the request
        request.httpMethod = Parse.Methods.Post
        request.addValue(Parse.Methods.HTTPHeader.ParseApplicationIDValue, forHTTPHeaderField: Parse.Methods.HTTPHeader.ParseApplicationID)
        request.addValue(Parse.Methods.HTTPHeader.ParseRestAPIKeyValue, forHTTPHeaderField: Parse.Methods.HTTPHeader.ParseRestAPIKey)
        request.addValue(Parse.Methods.HTTPHeader.ValueApplicationJSON, forHTTPHeaderField: Parse.Methods.HTTPHeader.KeyContentType)
        request.httpBody = jsonBody(parameters)
        
        // Make the request
        let _ = taskForPOSTMethod(request) { (success, error) in
            
            // Guard if there was an error
            guard (error == nil) else {
                completionHandlerForNewStudentLocation(false, error)
                return
            }
            
            // If new location is added
            if success {
                completionHandlerForNewStudentLocation(true, nil)
            } else {
                completionHandlerForNewStudentLocation(false, Constants.ErrorMessage.createNewStudentLocationError.description)
            }
        }
    }
    
    // MARK: PUT Methods
}

// MARK: - Parse API Methods (Helper Functions)
private extension ParseAPIMethods {
    
    func urlFrom(_ parameters: [String:String], withPathExtension: String? = nil) -> URL {
        
        // Create an URL from parameters with path extension
        var components = URLComponents()
        components.scheme = Parse.Constants.ApiScheme
        components.host = Parse.Constants.ApiHost
        components.path = Parse.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func url(withPathExtension: String? = nil) -> URL {
        
        // Create an URL with path extension
        var components = URLComponents()
        components.scheme = Parse.Constants.ApiScheme
        components.host = Parse.Constants.ApiHost
        components.path = Parse.Constants.ApiPath + (withPathExtension ?? "")
        
        return components.url!
    }
    
    func parseData(_ data: Data, completionHandlerForParsedData: (_ success: Bool, _ error: String?, _ result: AnyObject?) -> Void) {
        
        //Parse the data
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            completionHandlerForParsedData(false, Constants.ErrorMessage.parseDataError.description, nil)
            return
        }
        
        // Use parsed data
        completionHandlerForParsedData(true, nil, parsedResult)
    }
    
    func jsonBody(_ parameters: [String:AnyObject]) -> Data {
        
        // Build JSON body from parameters
        var jsonBody: Data = Data()
        
        jsonBody = "{\"\(Parse.JSONKeys.UniqueKey)\": \"\(parameters[Parse.JSONKeys.UniqueKey]!)\", \"\(Parse.JSONKeys.FirstName)\": \"\(parameters[Parse.JSONKeys.FirstName]!)\", \"\(Parse.JSONKeys.LastName)\": \"\(parameters[Parse.JSONKeys.LastName]!)\",\"\(Parse.JSONKeys.MapString)\": \"\(parameters[Parse.JSONKeys.MapString]!)\", \"\(Parse.JSONKeys.MediaURL)\": \"\(parameters[Parse.JSONKeys.MediaURL]!)\",\"\(Parse.JSONKeys.Latitude)\": \(parameters[Parse.JSONKeys.Latitude]!), \"\(Parse.JSONKeys.Longitude)\": \(parameters[Parse.JSONKeys.Longitude]!)}".data(using: String.Encoding.utf8)!
        
        return jsonBody
    }
}

