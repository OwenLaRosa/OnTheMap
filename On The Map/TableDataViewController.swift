//
//  TableDataViewController.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/6/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import Foundation
import UIKit

class TableDataViewController: UIViewController, UITableViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // refresh the table view
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // create instance of LocationCell
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! UITableViewCell
        let student = self.appDelegate.students[indexPath.row]
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // open the student's link in Safari
        UIApplication.sharedApplication().openURL(NSURL(string: appDelegate.students[indexPath.row].link)!)
    }
    
}
