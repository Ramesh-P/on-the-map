//
//  StudentLocationTabBarController.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/15/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

// MARK: Student Location Tab Bar Controller
class StudentLocationTabBarController: UITabBarController, UINavigationControllerDelegate {
    
    // MARK: Properties
    let navigationControllerDelegate = AppNavigationControllerDelegate()
    static var studentInformation: [StudentInformation] = [StudentInformation]()
    
    // MARK: Actions
    @IBAction func logoutAndExit(_ sender: UIBarButtonItem) {
        
        // Logout of Udacity and Facebook
        setUIEnabled(false)
        startAnimating()
        logoutAndExit()
    }
    
    @IBAction func reloadStudentList(_ sender: UIBarButtonItem) {
        
        // Refresh
        setUIEnabled(false)
        startAnimating()
        getStudentsInformation()
    }
    
    @IBAction func addStudentInformation(_ sender: UIBarButtonItem) {
        
        // Get student name and present student information view
        setUIEnabled(false)
        startAnimating()
        getStudentNameAndExit()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize
        navigationControllerDelegate.setBackgroundImage(self)
        
        let tabBarItems = tabBar.items! as [UITabBarItem]
        for tabBarItem in tabBarItems {
            tabBarItem.imageInsets = UIEdgeInsetsMake(6.0, 0.0, -6.0, 0.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Initialize
        setUIEnabled(true)
        getStudentsInformation()
        startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Class Functions
    func logoutAndExit() {
        
        // Chain completion handlers for each request so that they run one after the other
        logoutOfUdacity() { (success, error) in
            
            // Success: logged out of Udacity
            if success {
                self.logoutOfFacebook() { (success, error) in
                    
                    // Success: logged out of Facebook
                    if success {
                        
                        // Exit
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.displayError(Constants.ErrorMessage.logoutStatus.title.description, error)
                    }
                }
            } else {
                self.displayError(Constants.ErrorMessage.logoutStatus.title.description, error)
            }
        }
    }
    
    func logoutOfUdacity(completionHandlerForUdacityLogout: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Logout of Udacity
        UdacityAPIMethods.sharedInstance().deleteSession() { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    completionHandlerForUdacityLogout(true, nil)
                } else {
                    completionHandlerForUdacityLogout(false, error)
                }
            }
        }
    }
    
    func logoutOfFacebook(completionHandlerForFacebookLogout: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Logout of Facebook
        //if (FBSDKAccessToken.current() != nil) {
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()
        //}
        
        completionHandlerForFacebookLogout(true, nil)
    }
    
    func getStudentsInformation() {
        
        // Get current information
        ParseAPIMethods.sharedInstance().getStudentsInformation { (success, error, studentInformation) in
            performUIUpdatesOnMain {
                if success {
                    if let studentInformation = studentInformation {
                        StudentLocationTabBarController.studentInformation = studentInformation
                        StudentLocationTableViewController.studentsTable.reloadData()
                        StudentLocationMapKitViewController().reloadMapView()
                        self.setUIEnabled(true)
                        self.stopAnimating()
                    } else {
                        self.displayError(Constants.ErrorMessage.accessStatus.title.description, error)
                    }
                } else {
                    self.displayError(Constants.ErrorMessage.accessStatus.title.description, error)
                }
            }
        }
    }
    
    func getStudentNameAndExit() {
        
        // Get student name
        UdacityAPIMethods.sharedInstance().getStudentName { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    
                    // Success: present student information view
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentInformationNavigationController") as! UINavigationController
                    self.present(controller, animated: true, completion: nil)
                } else {
                    self.displayError(Constants.ErrorMessage.accessStatus.title.description, error)
                }
            }
        }
    }
    
    func displayError(_ title: String?, _ message: String?) {
        
        // Reset UI
        setUIEnabled(true)
        stopAnimating()
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - StudentLocationTabBarController (Configure UI)
private extension StudentLocationTabBarController {
    
    func setUIEnabled(_ enabled: Bool) {
        
        // Enable or disable UI elements
        self.view.isUserInteractionEnabled = enabled
    }
    
    func startAnimating() {
        
        StudentLocationMapKitViewController.activityIndicator.startAnimating()
        StudentLocationMapKitViewController.studentsMap.alpha = 0.5
        
        StudentLocationTableViewController.activityIndicator.startAnimating()
        StudentLocationTableViewController.studentsTable.alpha = 0.5
    }
    
    func stopAnimating() {
        
        StudentLocationMapKitViewController.activityIndicator.stopAnimating()
        StudentLocationMapKitViewController.studentsMap.alpha = 1.0
        
        StudentLocationTableViewController.activityIndicator.stopAnimating()
        StudentLocationTableViewController.studentsTable.alpha = 1.0
    }
}

