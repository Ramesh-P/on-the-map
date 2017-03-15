//
//  ParseAPIConstants.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/11/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Parse API Constants
struct Parse {
    
    // MARK: URLs
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    // MARK: Methods
    struct Methods {
        static let StudentLocation = "/StudentLocation"
        static let GET = "GET"
        static let Post = "POST"
        static let Put = "PUT"
        
        struct HTTPHeader {
            static let ParseApplicationID = "X-Parse-Application-Id"
            static let ParseApplicationIDValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let ParseRestAPIKey = "X-Parse-REST-API-Key"
            static let ParseRestAPIKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            
            // POST and PUT Methods
            static let KeyContentType = "Content-Type"
            static let ValueApplicationJSON = "application/json"
        }
        
        struct QueryItems {
            
            struct Key {
                static let Limit = "limit"
                static let Skip = "skip"
                static let Order = "order"
            }
            
            struct Value {
                static let Limit = "100"
                static let Skip = "400"
                static let DescendingOrderOfUpdate = "-updatedAt"
            }
        }
    }
    
    // MARK: JSON Keys
    struct JSONKeys {
        static let Result = "results"
        
        // Student Info
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        
        // Student Location
        static let MapString = "mapString"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        // Student Interest
        static let MediaURL = "mediaURL"
        
        // Student Permissions
        static let AccessControlList = "ACL"
        
        // Update Time
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
}

