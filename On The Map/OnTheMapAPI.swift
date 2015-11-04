//
//  OnTheMapAPI.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/2/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import Foundation
import UIKit

class API {
    // separate class for all network logic
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let baseURLString = "https://www.udacity.com/api/"
    
    let parseApplicationID = "PARSE_APPLICATION_ID"
    let parseAPIKey = "PARSE_API_KEY"
    
    func loginWithUdacity(username: String, password: String) {
        // gets session ID from Udacity account
        
        // configure the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(baseURLString)session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // posting failed because of a failure to connect, show error
                NSNotificationCenter.defaultCenter().postNotificationName(downloadDidFail, object: nil)
                return
            }
            // get usable data, first 5 bytes are not needed so remove them
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let response: NSString = NSString(data: newData, encoding: NSUTF8StringEncoding)!
            // check for login failure
            if response.containsString("\"status\": 400") {
                // missing parameter
                NSNotificationCenter.defaultCenter().postNotificationName(missingLoginParameter, object: nil)
            } else if response.containsString("\"status\": 403") {
                // incorrect credentials
                NSNotificationCenter.defaultCenter().postNotificationName(loginDidFail, object: nil)
            } else {
                // login succeeded, parse the data
                let parsedData = (try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)) as! NSDictionary
                let accountInfo = parsedData["account"] as? NSDictionary
                let userID = accountInfo?["key"] as! String
                self.appDelegate.userID = userID
                self.getUdacityUserData(userID)
            }
        }
        task.resume()
    }
    
    func getUdacityUserData(userID: String) {
        // gets a JSON object of Udacity account information
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURLString + "users/\(userID)")!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // failed to get account info, show errir
                NSNotificationCenter.defaultCenter().postNotificationName(downloadDidFail, object: nil)
                return
            }
            // parse the returned data
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let parsedData = (try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)) as! NSDictionary
            // get user information
            let userData = parsedData["user"] as! NSDictionary
            let firstName = userData["first_name"] as! String
            let lastName = userData["last_name"] as! String
            self.appDelegate.firstName = firstName
            self.appDelegate.lastName = lastName
            // login completed, tell the view controller
            NSNotificationCenter.defaultCenter().postNotificationName(loginDidComplete, object: nil)
        }
        task.resume()
    }
    
    // methods for handling the parse API
    
    func getStudentLocations() {
        // gets a list of objects containing students and locations
        
        // valid keys for the response dictionary
        let keys = ["firstName", "lastName", "latitude", "longitude", "mediaURL"]
        
        // make a request to get student information
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                // failed to get data, show error
                NSNotificationCenter.defaultCenter().postNotificationName(downloadDidFail, object: nil)
                return
            } else {
            
            // parse the JSON into a usable object
                let parsedData = (try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as! NSDictionary
                let results = parsedData["results"] as? [NSDictionary]
                let numberOfResults = results?.count
                
                // reset the student information
                self.appDelegate.students.removeAll(keepCapacity: false)
                
                for var index = 0; index < numberOfResults; ++index {
                    // check if the keys are valid
                    var isValid = true
                    for i in keys {
                        if results?[index][i] == nil {
                            // disregard entries with misspellings
                            isValid = false
                            break
                        }
                    }
                    
                    if isValid {
                        // save the student information
                        let studentInfo = StudentInformation(info: (results?[index] as NSDictionary?)!)
                        self.appDelegate.students.append(studentInfo)
                    }
                    // finished with task, alert the view controller
                    NSNotificationCenter.defaultCenter().postNotificationName(studentInfoDidDownload, object: nil)
                }
            }
        }
        task.resume()
    }
    
    func postLocationData(parameters: NSDictionary) {
        // read the parameters
        let mapString = parameters["mapString"] as! String
        let mediaURL = parameters["mediaURL"] as! String
        let latitude = parameters["latitude"] as! Float
        let longitude = parameters["longitude"] as! Float
        
        // configure the request
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // add required data to the POST request
        request.HTTPBody = "{\"uniqueKey\": \"\(appDelegate.userID)\", \"firstName\": \"\(appDelegate.firstName)\", \"lastName\": \"\(appDelegate.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // post failed, show error
                NSNotificationCenter.defaultCenter().postNotificationName(downloadDidFail, object: nil)
                return
            }
            // add student info without having to redownload data
            let info: NSDictionary = [
                "firstName": self.appDelegate.firstName,
                "lastName": self.appDelegate.lastName,
                "latitude": latitude,
                "longitude": longitude,
                "mediaURL": mediaURL
            ]
            let studentInfo = StudentInformation(info: info)
            self.appDelegate.students.append(studentInfo)
            
            // dismiss view and update map data
            NSNotificationCenter.defaultCenter().postNotificationName(studentDataShouldUpdate, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(addLocationViewShouldClose, object: nil)
        }
        task.resume()
    }
    
}
