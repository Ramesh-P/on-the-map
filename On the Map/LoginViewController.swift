//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/8/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

// MARK: Login View Controller
class LoginViewController: UIViewController {
    
    // MARK: Properties
    var fontSize: CGFloat = CGFloat()
    var textFields: [UITextField] = [UITextField]()
    var leftViewImage: UIImageView = UIImageView()
    
    // MARK: Outlets
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var objectHeight: NSLayoutConstraint!
    @IBOutlet weak var spaceBetweenObjects: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Actions
    @IBAction func loginToUdacity(_ sender: UIButton) {
        
        // Dismiss keyboard and prepare to login
        view.endEditing(true)
        setUIEnabled(false)
        startAnimating()
        
        if userIDTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError(Constants.ErrorMessage.loginStatus.title.description, Constants.ErrorMessage.emptyCredentials.description)
        } else {
            
            // Step-1: Set the parameters
            let parameters: [String:String] = [
                Udacity.JSONBodyKeys.Username: userIDTextField.text!,
                Udacity.JSONBodyKeys.Password: passwordTextField.text!
            ]
            
            // Authenticate with Udacity login
            UdacityAPIMethods.sharedInstance().loginWithID(parameters, authentication: Udacity.JSONBodyKeys.UdacityLogin) { (success, error) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(Constants.ErrorMessage.loginStatus.title.description, error)
                    }
                }
            }
        }
    }
    
    @IBAction func signupToUdacity(_ sender: UIButton) {
        
        // Dismiss keyboard and prepare to signup
        view.endEditing(true)
        clearTextFields()
        
        // Open Udacity signup page in Safari
        if let url = URL(string: Udacity.Constants.SignUpURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: UIButton) {
        
        // Dismiss keyboard and prepare to login
        view.endEditing(true)
        clearTextFields()
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.loginBehavior = FBSDKLoginBehavior.web
        
        loginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if error != nil {
                self.displayError(Constants.ErrorMessage.loginStatus.title.description, error as! String?)
                return
            }
            
            if (result?.token) != nil {
                self.startAnimating()
                let accessToken = FBSDKAccessToken.current().tokenString
                
                // Step-1: Set the parameters
                let parameters: [String:String] = [
                    Udacity.JSONBodyKeys.AccessToken: accessToken!
                ]
                
                // Authenticate with Udacity login
                UdacityAPIMethods.sharedInstance().loginWithID(parameters, authentication: Udacity.JSONBodyKeys.FacebookLogin) { (success, error) in
                    performUIUpdatesOnMain {
                        if success {
                            self.completeLogin()
                        } else {
                            self.displayError(Constants.ErrorMessage.loginStatus.title.description, error)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize
        userIDTextField.delegate = self
        passwordTextField.delegate = self
        textFields = [userIDTextField, passwordTextField]
        
        loginButton.isExclusiveTouch = true
        signupButton.isExclusiveTouch = true
        facebookButton.isExclusiveTouch = true
        
        // Layout
        configureUI()
        configureTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Layout
        clearTextFields()
        setUIEnabled(true)
        stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopAnimating()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Dismiss keyboard
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Class Functions
    func completeLogin() {
        
        // Enable UI and prepare to exit
        setUIEnabled(true)
        clearTextFields()
        
        // Present student location views
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentLocationNavigationController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
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

// MARK: LoginViewController: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - LoginViewController (Configure UI)
private extension LoginViewController {
    
    func clearTextFields() {
        
        // Clear user login credential
        for textField in textFields {
            textField.text = ""
        }
    }
    
    func setUIEnabled(_ enabled: Bool) {
        
        // Enable or disable UI elements
        userIDTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        signupButton.isEnabled = enabled
        facebookButton.isEnabled = enabled
    }
    
    func configureUI() {
        
        // Layout UI elements by device
        let currentScreenHeight = UIScreen.main.bounds.size.height
        
        switch currentScreenHeight {
        case Constants.ScreenHeight.phonePlus:
            objectHeight.constant = 49
            spaceBetweenObjects.constant = 12
            fontSize = 17.0
        case Constants.ScreenHeight.phone:
            objectHeight.constant = 44
            spaceBetweenObjects.constant = 11
            fontSize = 16.0
        case Constants.ScreenHeight.phoneSE:
            objectHeight.constant = 37
            spaceBetweenObjects.constant = 9
            fontSize = 14.0
        default:
            break
        }
    }
    
    func configureTextFields() {
        
        // Layout text fields
        for textField in textFields {
            if textField.tag == 0 {
                leftViewImage = UIImageView(image: UIImage(named: "LoginScene User ID"))
            } else if textField.tag == 1 {
                leftViewImage = UIImageView(image: UIImage(named: "LoginScene Password"))
            }
            
            leftViewImage.frame = CGRect(x: 0.0, y: 0.0, width: objectHeight.constant, height: objectHeight.constant)
            textField.leftView = leftViewImage
            textField.leftViewMode = UITextFieldViewMode.always
            textField.font = UIFont(name: "SFUIText-Regular", size: fontSize)
        }
        
        // Set text field left padding
        TextField.padding(height: objectHeight.constant)
    }
    
    func startAnimating() {
        
        activityIndicator.startAnimating()
        self.view.alpha = 0.75
    }
    
    func stopAnimating() {
        
        activityIndicator.stopAnimating()
        self.view.alpha = 1.0
    }
}

