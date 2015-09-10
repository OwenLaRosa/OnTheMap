//
//  LoginViewController.swift
//  On The Map
//
//  Created by Owen LaRosa on 5/2/15.
//  Copyright (c) 2015 Owen LaRosa. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    let textFieldDelegate = TextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameField.delegate = textFieldDelegate
        passwordField.delegate = textFieldDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        subscribeToNotifications()
        activityView.hidden = true
        activityView.hidesWhenStopped = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func login(sender: UIButton) {
        // remove cursor from text fields
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        // configure the UI
        activityView.hidden = false
        loginButton.enabled = false
        usernameField.enabled = false
        passwordField.enabled = false
        activityView.startAnimating()
        // begin logging in
        var api = API()
        api.loginWithUdacity(usernameField.text, password: passwordField.text)
    }
    
    @IBAction func signUpTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showDownloadError", name: downloadDidFail, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoginError", name: loginDidFail, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "completeLogin", name: loginDidComplete, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMissingCredentialsError", name: missingLoginParameter, object: nil)
    }
    
    func showDownloadError() {
        // show information posting error
        let alertView = UIAlertController(title: "Login Failed", message: "Could not connect to server.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: {
            self.resetUI()
        })
    }
    
    func showMissingCredentialsError() {
        // prompt user for username and password
        let alertView = UIAlertController(title: "Login Failed", message: "Please enter a username and password.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: {
            self.resetUI()
        })
    }
    
    func showLoginError() {
        // show login error
        let alertView = UIAlertController(title: "Login Failed", message: "The username or password is incorrect.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: {
            self.resetUI()
        })
    }
    
    func completeLogin() {
        // login successful, proceed to main content
        self.resetUI()
        performSegueWithIdentifier("showTabBarController", sender: nil)
    }
    
    func resetUI() {
        // stop animating and hide the activity indicator
        activityView.stopAnimating()
        usernameField.enabled = true
        passwordField.enabled = true
        loginButton.enabled = true
    }

}
