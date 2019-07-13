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
    
    var companyRef : DatabaseReference?
    
    @IBOutlet weak var imageView: UIImageView!
    
    var handle : DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLoggedIn(_:)), name: NSNotification.Name("UserLoggedIn"), object: nil)
        
        companyRef = Database.database().reference(withPath: "companies")
        
        
        
        companyRef?.observe(.value, with: { snapshot in
            var newCompanies : [Company] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let companyItem = Company(snapshot: snapshot) {
                    newCompanies.append(companyItem)
                }
            }
            
            print("Fetched companies = {0} ", newCompanies)
            
            let url = URL(string: newCompanies[0].imageStr)!
            self.downloadImage(from: url)
        })
    }
    
    func downloadImage(from url: URL) {
        print("Download Started, {0}", generateCurrentTimeStamp())
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished, {0}", self.generateCurrentTimeStamp())
            
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
                print("self.imageView is set, {0}", self.generateCurrentTimeStamp())
            }
        }
    }
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
    
    @IBAction func onAddClicked(_ sender: Any) {
        
        var branches : [Branch] = []
        let ordersBranch = Branch(name: "Orders", number: "05412341,2", isVerified: false)
        let customerBranch = Branch(name: "Customer", number: "05412341,2", isVerified: false)
        branches.append(ordersBranch)
        branches.append(customerBranch)
        let company = Company(imageStr: "img", branches: branches)
        
        if let cRef = self.companyRef?.child("test"){
            let c = company.toAnyObject()
            cRef.setValue(c)
        }
        
        
        
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

