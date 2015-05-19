//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/3/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var linkField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        subscribeToNotifications()
        locationField.delegate = textFieldDelegate
        linkField.delegate = textFieldDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func saveLocation(sender: UIBarButtonItem) {
        // remove cursor from text fields
        locationField.resignFirstResponder()
        linkField.resignFirstResponder()
        // check if the URL is valid
        if linkField.text == "" {
            NSNotificationCenter.defaultCenter().postNotificationName(invalidURLError, object: nil)
        } else if let url = NSURL(string: linkField.text) {
            // geocode the location
            let geocoder = CLGeocoder()
            
            // show activity during geocoding
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            geocoder.geocodeAddressString(locationField.text, completionHandler: {(placemark, error) -> Void in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    // geocoding failed, show the error
                    NSNotificationCenter.defaultCenter().postNotificationName(geocodingDidFail, object: nil)
                    return
                }
                let location = placemark[0] as! CLPlacemark
                let parameters = [
                    "mapString": self.locationField.text,
                    "mediaURL": self.linkField.text,
                    "latitude": location.location.coordinate.latitude as Double,
                    "longitude": location.location.coordinate.longitude as Double
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
    
}
