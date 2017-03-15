//
//  StudentInformationViewController.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 1/24/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

// MARK: Student Information View Controller
class StudentInformationViewController: UIViewController {
    
    // MARK: Properties
    var fontSize: CGFloat = CGFloat()
    var textFields: [UITextField] = [UITextField]()
    var leftViewImage: UIImageView = UIImageView()
    static var mapString: String = String()
    static var latitude: Double = Double()
    static var longitude: Double = Double()
    static var mediaURL: String = String()
    
    // MARK: Outlets
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var studentLocationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var objectHeight: NSLayoutConstraint!
    @IBOutlet weak var spaceBetweenObjects: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Actions
    @IBAction func findStudentLocation(_ sender: UIButton) {
        
        // Dismiss keyboard and prepare to find student location
        view.endEditing(true)
        setUIEnabled(false)
        startAnimating()
        
        // Verify inputs not empty
        verifyInput()  { (success, error) in
            if success {
                
                // Success: verify URL and get media string
                self.getMediaURL()  { (success, error) in
                    if success {
                        
                        // Success: verify address and get coordinates for location
                        self.getGeoLocation()  { (success, error) in
                            if success {
                                
                                // Success: present information posting view
                                let controller = self.storyboard!.instantiateViewController(withIdentifier: "PostInformationNavigationController") as! UINavigationController
                                self.present(controller, animated: true, completion: nil)
                            } else {
                                self.displayError(Constants.ErrorMessage.general.title.description, error)
                            }
                        }
                    } else {
                        self.displayError(Constants.ErrorMessage.general.title.description, error)
                    }
                }
                
            } else {
                self.displayError(Constants.ErrorMessage.general.title.description, error)
            }
        }
    }
    
    @IBAction func cancelInformationPosting(_ sender: UIBarButtonItem) {
        
        // Dismiss keyboard and prepare to exit
        view.endEditing(true)
        setUIEnabled(false)
        
        // Exit
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize
        studentLocationTextField.delegate = self
        mediaURLTextField.delegate = self
        textFields = [studentLocationTextField, mediaURLTextField]
        
        // Layout
        configureUI()
        configureWelcomeMessage()
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
    func verifyInput(completionHandlerForInput: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Verify if location and media URL are entered
        if studentLocationTextField.text!.isEmpty || mediaURLTextField.text!.isEmpty {
            completionHandlerForInput(false, Constants.ErrorMessage.emptyInput.description)
        } else {
            completionHandlerForInput(true, nil)
        }
    }
    
    func getMediaURL(completionHandlerForMediaURL: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let url = URL(string: mediaURLTextField.text!)
        
        // Guard if no URL was returned
        guard (url != nil) else {
            completionHandlerForMediaURL(false, Constants.ErrorMessage.notMediaURL.description)
            return
        }
        
        // Verify and save valid URL
        if UIApplication.shared.canOpenURL(url!) {
            StudentInformationViewController.mediaURL = (url?.absoluteString)!
            completionHandlerForMediaURL(true, nil)
        } else {
            completionHandlerForMediaURL(false, Constants.ErrorMessage.invalidMediaURL.description)
        }
    }
    
    func getGeoLocation(completionHandlerForGeoLocation: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let address = studentLocationTextField.text!
        
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            
            // Guard if no location was returned
            guard (error == nil) else {
                completionHandlerForGeoLocation(false, Constants.ErrorMessage.invalidLocation.description)
                return
            }
            
            /**
             *
             * Eureka! I found out cat, dog, duck, God, man, cupcake all have geolocations :-]
             * And it turned out “really" is located in Newtown, PA at lat: 40.650337, long: -76.348133, but "udacity" returns invalid!! Yikes
             * But on the bright side, the govt. didn’t lie. Area 51 doesn’t exist
             * Warning: Don’t go to lat: 49.8961579, long: 2.2939803. Aliens are real :-[
             *
             */
            
            // Save location details
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                
                StudentInformationViewController.mapString = self.studentLocationTextField.text!
                StudentInformationViewController.latitude = coordinate!.latitude
                StudentInformationViewController.longitude = coordinate!.longitude
                
                completionHandlerForGeoLocation(true, nil)
            }
        })
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

// MARK: StudentInformationViewController: UITextFieldDelegate
extension StudentInformationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - StudentInformationViewController (Configure UI)
private extension StudentInformationViewController {
    
    func clearTextFields() {
        
        // Clear user login credential
        for textField in textFields {
            textField.text = ""
        }
    }
    
    func setUIEnabled(_ enabled: Bool) {
        
        // Enable or disable UI elements
        studentLocationTextField.isEnabled = enabled
        mediaURLTextField.isEnabled = enabled
        findLocationButton.isEnabled = enabled
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
            spaceBetweenObjects.constant = 10
            fontSize = 14.0
        default:
            break
        }
    }
    
    func configureWelcomeMessage() {
        
        // Display greetings
        let firstName = UdacityAPIMethods.sharedInstance().firstName?.uppercased()
        greetingsLabel.text = (firstName != "") ? "HI, \(firstName!)!" : "HELLO, UDACIAN!"
    }
    
    func configureTextFields() {
        
        // Layout text fields
        for textField in textFields {
            if textField.tag == 0 {
                leftViewImage = UIImageView(image: UIImage(named: "InformationScene Student Location"))
            } else if textField.tag == 1 {
                leftViewImage = UIImageView(image: UIImage(named: "InformationScene Media URL"))
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

