
//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/3/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var linkField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        locationField.delegate = self
        linkField.delegate = textFieldDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func saveLocation(sender: UIButton) {
        // remove cursor from text fields
        locationField.resignFirstResponder()
        linkField.resignFirstResponder()
        // check if the link field is empty
        if validateUrl(linkField.text!) {
            // geocode the location
            let geocoder = CLGeocoder()
            
            // show activity during geocoding
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            geocoder.geocodeAddressString(locationField.text!, completionHandler: {(placemark, error) -> Void in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    // geocoding failed, show the error
                    NSNotificationCenter.defaultCenter().postNotificationName(geocodingDidFail, object: nil)
                    return
                }
                let location = placemark![0]
                let parameters: [String: AnyObject] = [
                    "mapString": self.locationField.text!,
                    "mediaURL": self.linkField.text!,
                    "latitude": location.location!.coordinate.latitude as Double,
                    "longitude": location.location!.coordinate.longitude as Double
                ]
                // post information to server
                let api = API()
                api.postLocationData(parameters)
                self.activityIndicator.stopAnimating()
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            // URL is not valid, show the error
            NSNotificationCenter.defaultCenter().postNotificationName(invalidURLError, object: nil)
        }
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showURLError", name: invalidURLError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showGeocodingError", name: geocodingDidFail, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissView", name: addLocationViewShouldClose, object: nil)
    }
    
    func showURLError() {
        // prompt the user for a valid URL
        let alertView = UIAlertController(title: "Error", message: "Please enter a valid URL.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func showGeocodingError() {
        // prompt the user for a valid location
        let alertView = UIAlertController(title: "Geocoding Failed", message: "The location \"\(locationField.text)\" could not be found. Please try again with a more specific location.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    // source: http://discussions.udacity.com/t/validating-urls/14093
    func validateUrl(url: String) -> Bool {
        // determines if the url is formatted properly
        
        // regular url format
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        // check if string conforms to format
        if let match = url.rangeOfString(pattern, options: .RegularExpressionSearch) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // remove cursor from the text field
        textField.resignFirstResponder()
        
        // geocode the location and create a pin
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationField.text!, completionHandler: {(placemark, error) -> () in
            if error != nil {
                // do not display any new information on the map
                return
            }
            // create a placemark object and get the coordinates
            let location = placemark![0]
            let pin = MKPointAnnotation()
            pin.coordinate.latitude = location.location!.coordinate.latitude
            pin.coordinate.longitude = location.location!.coordinate.longitude
            // move the map to the location, then add the pin
            let centerCoordinate =  CLLocationCoordinate2DMake(pin.coordinate.latitude, pin.coordinate.longitude)
            self.mapView.setCenterCoordinate(centerCoordinate, animated: true)
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(pin)
        })
        return true
    }
    
}
