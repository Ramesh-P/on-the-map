//
//  StudentInformation.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/21/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Student Information
struct StudentInformation {
    
    // MARK: Properties
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let latitude: Double
    let longitude: Double
    let mediaURL: String
    
    // MARK: Initializer
    init(dictionary: [String:AnyObject]) {
        
        if let stringUniqueKey = dictionary[Parse.JSONKeys.UniqueKey] as? String {
            uniqueKey = stringUniqueKey
        } else {
            uniqueKey = ""
        }
        
        if let stringFirstName = dictionary[Parse.JSONKeys.FirstName] as? String {
            firstName = stringFirstName
        } else {
            firstName = ""
        }
        
        if let stringLastName = dictionary[Parse.JSONKeys.LastName] as? String {
            lastName = stringLastName
        } else {
            lastName = ""
        }
        
        if let stringMapString = dictionary[Parse.JSONKeys.MapString] as? String {
            mapString = stringMapString
        } else {
            mapString = ""
        }
        
        if let doubleLatitude = dictionary[Parse.JSONKeys.Latitude] as? Double {
            latitude = doubleLatitude
        } else {
            latitude = 0.0
        }
        
        if let doubleLongitude = dictionary[Parse.JSONKeys.Longitude] as? Double {
            longitude = doubleLongitude
        } else {
            longitude = 0.0
        }
        
        if let stringMediaURL = dictionary[Parse.JSONKeys.MediaURL] as? String {
            mediaURL = stringMediaURL
        } else {
            mediaURL = ""
        }
    }
    
    static func allProfilesFrom(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentInformation = [StudentInformation]()
        
        // Iterate through the result array, each student information is a dictionary
        for result in results {
            studentInformation.append(StudentInformation(dictionary: result))
        }
        
        return studentInformation
    }
}

