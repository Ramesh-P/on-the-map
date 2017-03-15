//
//  UdacityAPIConstants.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/11/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Udacity API Constants
struct Udacity {
    
    // MARK: URLs
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let SignUpURL = "https://udacity.com/account/auth#!/signup"
    }
    
    // MARK: Methods
    struct Methods {
        static let Session = "/session"
        static let Users = "/users"
        static let GET = "GET"
        static let Post = "POST"
        static let Delete = "DELETE"
        
        struct HTTPHeader {
            static let KeyAccept = "Accept"
            static let KeyContentType = "Content-Type"
            static let ValueApplicationJSON = "application/json"
        }
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let UdacityLogin = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let FacebookLogin = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Session
        static let Session = "session"
        static let SessionID = "id"
        
        // MARK: Account
        static let Account = "account"
        static let UserID = "key"
        static let RegisteredUser = "registered"
        static let UserInfo = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
        // MARK: Status
        static let StatusCode = "status"
        static let StatusMessage = "error"
    }
    
    // MARK: Cross-site Request Forgery
    struct XSRF {
        static let CookieNameXSRF = "XSRF-TOKEN"
        static let HTTPHeaderXSRF = "X-XSRF-TOKEN"
    }
}

