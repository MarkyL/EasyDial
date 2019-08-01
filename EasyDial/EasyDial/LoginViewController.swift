//
//  LoginViewController.swift
//  EasyDial
//
//  Created by Mark Lurie on 12/07/2019.
//  Copyright © 2019 Omri Ohayon. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(onUserLoggedIn(_:)), name: NSNotification.Name("UserLoggedIn"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func onUserLoggedIn(_ notification: NSNotification) {
        print("onuserloggedin")
        
        if let user = notification.userInfo?["user"] as? GIDGoogleUser {
            // do something with your image
            let email = user.profile.email
            print("onUserLoggedin , user email = {0}", email ?? "emptyMail")
        }
        dismiss(animated: true, completion: nil)
    }

}
