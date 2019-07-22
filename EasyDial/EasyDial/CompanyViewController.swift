//
//  CompanyViewController.swift
//  EasyDial
//
//  Created by Omri Ohayon on 18/07/2019.
//  Copyright © 2019 Omri Ohayon. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import Firebase

class CompanyViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var favoriteFilterImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var company : Company!
    
    var isAdmin : Bool = false

    var branchesToPresent : [Branch] = []
    var isFilterFavorite = false
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if company != nil {
            let url = URL(string: (self.company?.imageStr)!)!
            downloadImage(from: url)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let headerBranchTap = UITapGestureRecognizer(target: self, action: #selector(onTapHeaderBranch))
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(headerBranchTap)
        
        isAdmin = defaults.bool(forKey: "isAdmin")
        print("isAdmin = " + isAdmin.description)
        
        let favoriteFilterTap = UITapGestureRecognizer(target: self, action: #selector(onFliterFavoriteClicked))
        favoriteFilterImageView.isUserInteractionEnabled = true
        favoriteFilterImageView.addGestureRecognizer(favoriteFilterTap)
        
        branchesToPresent = company.branches
    }
    
    //Action
    @objc func onTapHeaderBranch() {
        callNumber(phoneNumber: company.mainBranch)
    }
    
    private func onTapSpecificBranch(branchIndex : Int) {
        let branchNumber = company.branches[branchIndex].number
        callNumber(phoneNumber: company.mainBranch + branchNumber)
    }
    
    private func callNumber(phoneNumber:String) {
        print("callNumber called with - " + phoneNumber)

        if let phoneCallURL:NSURL = NSURL(string:"tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.openURL(phoneCallURL as URL);
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.branchesToPresent.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cellTableView") as! MyTableViewCell

        let branch = self.branchesToPresent[indexPath.item]
        cell.myLabel.text = branch.name
        
        cell.verifiedImg.image = branch.isVerified ?
            UIImage(named: "ic_verified") : UIImage(named: "ic_unverified")
        
        cell.myImageView.image = isFavoriteBranch(branch: branch) ?
            UIImage(named: "ic_favorite") : UIImage(named: "ic_unfavorite")
        
        cell.myImageView.isUserInteractionEnabled = true
        cell.myImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFavoriteClicked)))
        cell.myImageView.tag = indexPath.item
        
        return cell
    }
    
    func onFavoriteClicked(gesture : UITapGestureRecognizer) {
        print("onFavoriteClicked")
        let cellImage = gesture.view! as! UIImageView
        let branchIndex = cellImage.tag

        let isFav = isFavoriteBranch(branch: company.branches[branchIndex])
        
        DispatchQueue.main.async() {
            cellImage.image = isFav ? UIImage(named: "ic_unfavorite") : UIImage(named: "ic_favorite")
        }
        
        defaults.set(!isFav, forKey: company.name+"_"+company.branches[branchIndex].name)
    }
    
    func onFliterFavoriteClicked(gesture : UITapGestureRecognizer) {
        print("onFliterFavoriteClicked")
        self.isFilterFavorite = !self.isFilterFavorite
        
        if self.isFilterFavorite{
            DispatchQueue.main.async() {
                self.favoriteFilterImageView.image = UIImage(named: "ic_favorite_filter")
            }
            branchesToPresent.removeAll()
            for branch in company.branches{
                if isFavoriteBranch(branch:branch) {
                    //Means this branch is our favorite
                    branchesToPresent.append(branch)
                }
            }
            
        }else{
            DispatchQueue.main.async() {
                self.favoriteFilterImageView.image = UIImage(named: "ic_unfavorite_filter")
            }
            branchesToPresent.removeAll()
            branchesToPresent = company.branches
        }

        
        self.tableView.reloadData()

    }
    
    func isFavoriteBranch(branch: Branch) -> Bool {
        return defaults.bool(forKey: company.name+"_"+branch.name)
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onTapSpecificBranch(branchIndex: indexPath.item)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)

            
            DispatchQueue.main.async() {
                let image = UIImage(data: data)
                self.headerImageView.image = image
                self.headerImageView.contentMode = .scaleAspectFit

            }
        }
    }
}
