//
//  StudentLocationTableViewController.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/15/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit

// MARK: Student Location Table View Controller
class StudentLocationTableViewController: UIViewController {
    
    // MARK: Properties
    static var studentsTable: UITableView = UITableView()
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: Outlets
    @IBOutlet weak var studentsTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize
        StudentLocationTableViewController.studentsTable = studentsTable
        StudentLocationTableViewController.activityIndicator = activityIndicator
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Class Functions
    func displayError(_ title: String?, _ message: String?) {
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Student Location Table View Delegate and Data Source
extension StudentLocationTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return StudentLocationTabBarController.studentInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Initialize
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentDetailCell", for: indexPath) as UITableViewCell
        let studentDetail = StudentLocationTabBarController.studentInformation[(indexPath as NSIndexPath).row]
        
        let firstName: String = studentDetail.firstName
        let lastName: String = studentDetail.lastName
        let fullName: String = ((firstName + " " + lastName).trimmingCharacters(in: .whitespaces)).capitalized
        
        let url: String = (studentDetail.mediaURL).trimmingCharacters(in: .whitespaces).lowercased()
        
        // Present
        cell.textLabel!.text = (fullName != "") ? fullName : "[No Name]"
        cell.detailTextLabel!.text = (url != "") ? url : "[No Media URL]"
        cell.imageView!.image = UIImage(named: "Pin")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        let url = URL(string: (cell?.detailTextLabel?.text)!)
        
        // Guard if no URL was returned
        guard (url != nil) else {
            displayError(Constants.ErrorMessage.accessStatus.title.description, Constants.ErrorMessage.openMediaURL.description)
            return
        }
        
        // Display media link in Safari
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            displayError(Constants.ErrorMessage.accessStatus.title.description, Constants.ErrorMessage.openMediaURL.description)
        }
    }
}

