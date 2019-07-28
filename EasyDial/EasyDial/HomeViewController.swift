//
//  HomeViewController.swift
//  EasyDial
//
//  Created by Omri Ohayon on 18/07/2019.
//  Copyright © 2019 Omri Ohayon. All rights reserved.
//

import Foundation

import UIKit
import GoogleSignIn
import Firebase

class HomeViewController: UIViewController, GIDSignInUIDelegate , UICollectionViewDataSource, UICollectionViewDelegate , UISearchBarDelegate{
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    var companyRef : DatabaseReference?
    
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var handle : DatabaseHandle?
    
    var chosenCompanyIndex : Int = -1
    
    var companies : [Company] = []
    
    var companiesToPresent : [Company] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLoggedIn(_:)), name: NSNotification.Name("UserLoggedIn"), object: nil)
        
        companyRef = Database.database().reference(withPath: "companies")
        
        initiateProgressBar()
        
        companyRef?.observe(.value, with: { snapshot in
            self.companies.removeAll()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let companyItem = Company(snapshot: snapshot) {
                    self.companies.append(companyItem)
                }
            }
            
            self.companiesToPresent = self.companies
            self.myCollectionView.reloadData()
            self.indicator.stopAnimating()
        })
    }
    
    func downloadImage(from url: URL , cell: MyCollectionViewCell) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {
                let image = UIImage(data: data)
                cell.myImageView.image = image
                cell.myImageView.contentMode = .scaleAspectFit
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
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.companiesToPresent.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let url = URL(string: self.companiesToPresent[indexPath.item].imageStr)!

        self.downloadImage(from: url,cell: cell)
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    func initiateProgressBar(){
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        indicator.startAnimating()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        self.chosenCompanyIndex  = indexPath.item
        
        self.performSegue(withIdentifier: "specificCompany", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CompanyViewController {
            vc.company = self.companiesToPresent[chosenCompanyIndex]
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            companiesToPresent = companies
        } else{
            companiesToPresent = companies.filter({$0.name.contains(searchText)})
        }
        self.myCollectionView.reloadData()
    }
}
