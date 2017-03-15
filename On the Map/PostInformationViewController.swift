//
//  PostInformationViewController.swift
//  On the Map
//
//  Created by Ramesh Parthasarathy on 2/1/17.
//  Copyright © 2017 Ramesh Parthasarathy. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// MARK: Post Information View Controller
class PostInformationViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    let navigationControllerDelegate = AppNavigationControllerDelegate()
    var parameters: [String:AnyObject] = [String:AnyObject]()
    
    // MARK: Outlets
    @IBOutlet weak var studentLocation: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Actions
    @IBAction func submitStudentInformation(_ sender: UIButton) {
        
        // Prepare to submit student information
        setUIEnabled(false)
        startAnimating()
        studentLocation.deselectAnnotation(studentLocation.annotations[0], animated: true)
        
        // Add new location and media URL
        ParseAPIMethods.sharedInstance().createNewStudentLocation(parameters) { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    let presentingViewController: UIViewController! = self.presentingViewController
                    self.dismiss(animated: false) {
                        presentingViewController.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.displayError(Constants.ErrorMessage.updateStatus.title.description, error)
                }
            }
        }
    }

    @IBAction func cancelInformationPosting(_ sender: UIBarButtonItem) {
        
        // Exit
        setUIEnabled(false)
        studentLocation.deselectAnnotation(studentLocation.annotations[0], animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize
        navigationControllerDelegate.setBackgroundImage(self)
        studentLocation.delegate = self
        setParameters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Layout
        setUIEnabled(true)
        startAnimating()
        setAnnotation()
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
    func setParameters() {
        
        // Step-1: Set the parameters
        parameters = [
            Parse.JSONKeys.UniqueKey: UdacityAPIMethods.sharedInstance().userID as AnyObject,
            Parse.JSONKeys.FirstName: UdacityAPIMethods.sharedInstance().firstName as AnyObject,
            Parse.JSONKeys.LastName: UdacityAPIMethods.sharedInstance().lastName as AnyObject,
            Parse.JSONKeys.MapString: StudentInformationViewController.mapString as AnyObject,
            Parse.JSONKeys.Latitude: StudentInformationViewController.latitude as AnyObject,
            Parse.JSONKeys.Longitude: StudentInformationViewController.longitude as AnyObject,
            Parse.JSONKeys.MediaURL: StudentInformationViewController.mediaURL as AnyObject
        ]
    }
    
    func setAnnotation() {
        
        // Set annotation
        let latitude = CLLocationDegrees(parameters[Parse.JSONKeys.Latitude] as! Double)
        let latitudeDelta: CLLocationDegrees = 1/180.0

        let longitude = CLLocationDegrees(parameters[Parse.JSONKeys.Longitude] as! Double)
        let longitudeDelta: CLLocationDegrees = 1/180.0

        let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        
        let coordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
        studentLocation.setRegion(coordinateRegion, animated: true)
        
        var address: String = (parameters[Parse.JSONKeys.MapString])!.trimmingCharacters(in: .whitespaces).capitalized
        address = (address != "") ? address : "[No Address]"
        
        var url: String = (parameters[Parse.JSONKeys.MediaURL])!.trimmingCharacters(in: .whitespaces).lowercased()
        url = (url != "") ? url : "[No Media URL]"

        // Add and display annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = address
        annotation.subtitle = url
        studentLocation.addAnnotation(annotation)
        studentLocation.selectAnnotation(studentLocation.annotations[0], animated: true)
    }
    
    func displayError(_ title: String?, _ message: String?) {
        
        // Reset UI
        setUIEnabled(true)
        stopAnimating()
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { handler -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Post Information MapKit Delegate
extension PostInformationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Add custom pin & callout accessory view to the map
        let Identifier = "LocationPin"
        var annotationView: MKAnnotationView?
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier)
            annotationView?.image = UIImage(named: "Pin")
            annotationView?.canShowCallout = true
            
            let rightButton = UIButton(type: .custom)
            rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 45.0, height: 45.0)
            rightButton.setImage(UIImage(named: "Right Arrow"), for: .normal)
            rightButton.adjustsImageWhenHighlighted = false
            annotationView?.rightCalloutAccessoryView = rightButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let url = URL(string: (view.annotation?.subtitle!)!)
            
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
}

// MARK: - PostInformationViewController (Configure UI)
private extension PostInformationViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        
        // Enable or disable UI elements
        self.view.isUserInteractionEnabled = enabled
    }
    
    func startAnimating() {
        
        activityIndicator.startAnimating()
        studentLocation.alpha = 0.5
    }
    
    func stopAnimating() {
        
        activityIndicator.stopAnimating()
        studentLocation.alpha = 1.0
    }
}

