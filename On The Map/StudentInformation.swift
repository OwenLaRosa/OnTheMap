//
//  StudentInformation.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/4/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import Foundation

struct StudentInformation {
    // structure representing locations of students
    
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var link: String
    
    init(info: NSDictionary) {
        self.firstName = info["firstName"] as! String!
        self.lastName = info["lastName"] as! String!
        self.latitude = info["latitude"] as! Double!
        self.longitude = info["longitude"] as! Double!
        self.link = info["mediaURL"] as! String!
    }
    
}
