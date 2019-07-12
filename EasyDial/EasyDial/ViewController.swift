//
//  ViewController.swift
//  EasyDial
//
//  Created by Omri Ohayon on 28/06/2019.
//  Copyright © 2019 Omri Ohayon. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLoggedIn(_:)), name: NSNotification.Name("UserLoggedIn"), object: nil)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "isUserLoggedIn")) {
            print("user is logged in and on main view!!!")
            GIDSignIn.sharedInstance()?.signIn()
        } else {
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    
    public func onUserLoggedIn(_ notification: NSNotification) {
        print("onuserloggedin main viewcontroller")
        
    }
    
    @IBAction func onLogoutClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            self.performSegue(withIdentifier: "loginView", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out : %@", signOutError)
        }
    }
}

