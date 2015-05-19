//
//  MapDataViewController.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/5/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapDataViewController: UIViewController, MKMapViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    var didLaunch = false
    
    override func viewDidLoad() {
        // get map data once the view loads
        let api = API()
        api.getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToNofitications()
    }
    
    func subscribeToNofitications() {
        // listen for when the map data is downloaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populateMapWithAnnotations", name: studentInfoDidDownload, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMostRecentAnnotation", name: studentDataShouldUpdate, object: nil)
    }
    
    func populateMapWithAnnotations() {
        // remove old annotations if any exist
        let annotations = mapView.annotations
        if annotations.count > 0 {
            mapView.removeAnnotations(annotations)
        }
        
        // make annotations for each student object
        for i in appDelegate.students {
            placeAnnotation(i)
        }
    }
    
    func placeAnnotation(info: StudentInformation) {
        // creates a pin for each student
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
        pin.title = "\(info.firstName) \(info.lastName)"
        pin.subtitle = info.link
        mapView.addAnnotation(pin)
    }
    
    func addMostRecentAnnotation() {
        placeAnnotation(appDelegate.students[0])
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // custom class to configure map annotations
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // open the student's link in Safari
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
}
