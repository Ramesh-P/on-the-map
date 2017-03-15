//
//  TextField.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/9/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Text Field Extensions
class TextField: UITextField {
    
    // MARK: Properties
    static var pad: UIEdgeInsets = UIEdgeInsets()
    
    // MARK: Initializers
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    // MARK: Overrides
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return UIEdgeInsetsInsetRect(bounds, TextField.pad)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        return UIEdgeInsetsInsetRect(bounds, TextField.pad)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return UIEdgeInsetsInsetRect(bounds, TextField.pad)
    }
    
    // MARK: Class Functions
    static func padding(height: CGFloat) {
        
        TextField.pad = UIEdgeInsets(top: 0, left: height + 10, bottom: 0, right: 20)
    }
}

