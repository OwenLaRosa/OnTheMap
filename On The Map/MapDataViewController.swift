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
        super.viewDidLoad()
        // get map data once the view loads
        let api = API()
        api.getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        subscribeToNofitications()
    }
    
    @IBAction func changeMapType(sender: UIBarButtonItem) {
        let alertController = UIAlertController()
        alertController.title = "Change map type."
        
        // default street map type
        let standardViewButton = UIAlertAction(title: "Standard", style: .Default) {
            action in self.mapView.mapType = .Standard
        }
        // satellite map view
        let satelliteViewButton = UIAlertAction(title: "Satellite", style: .Default) {
            action in self.mapView.mapType = .Satellite
        }
        // satelite view with street information
        let hybridViewButton = UIAlertAction(title: "Hybrid", style: .Default) {
            action in self.mapView.mapType = .Hybrid
        }
        // dismisses the view
        let cancelButton = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(standardViewButton)
        alertController.addAction(satelliteViewButton)
        alertController.addAction(hybridViewButton)
        alertController.addAction(cancelButton)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func subscribeToNofitications() {
        // listen for when the map data is downloaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populateMapWithAnnotations", name: studentInfoDidDownload, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMostRecentAnnotation", name: studentDataShouldUpdate, object: nil)
    }
    
    func populateMapWithAnnotations() {
        dispatch_async(dispatch_get_global_queue(0, 0), {
            // gather data on background thread
            var annotations = [MKAnnotation]()
            for i in self.appDelegate.students {
                // convert student information to annotation
                let pin = self.makeAnnoation(i)
                annotations.append(pin)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                // add annoations to map on main thread
                self.mapView.addAnnotations(annotations)
            })
        })
    }
    
    func makeAnnoation(info: StudentInformation) -> MKPointAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
        pin.title = "\(info.firstName) \(info.lastName)"
        pin.subtitle = info.link
        return pin
    }
    
    func addMostRecentAnnotation() {
        // adds most recent student object to the map (the one submitted by the user)
        let info = appDelegate.students[appDelegate.students.count - 1]
        dispatch_async(dispatch_get_global_queue(0, 0), {
            // create pin in background
            let pin = self.makeAnnoation(info)
            dispatch_async(dispatch_get_main_queue(), {
                // update the map on the main thread
                self.mapView.addAnnotation(pin)
            })
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        // custom class to configure map annotations
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // open the student's link in Safari
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
}
