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
    
    let COMPANY_BRANCH_DELIMITER = "_"
    
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
        
        downloadAndShowCompanyLogo()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initTapRecognizers()
        isAdmin = defaults.bool(forKey: "isAdmin")
        branchesToPresent = company.branches
    }
    
    func downloadAndShowCompanyLogo() {
        if company != nil {
            let url = URL(string: (self.company?.imageStr)!)!
            downloadImage(from: url)
        }
    }
    
    func initTapRecognizers() {
        initHeaderTapRecognizer()
        initFavFilterTapRecognizer()
    }
    
    func initHeaderTapRecognizer() {
        let headerBranchTap = UITapGestureRecognizer(target: self, action: #selector(onTapHeaderBranch))
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(headerBranchTap)
    }
    
    func initFavFilterTapRecognizer() {
        let favoriteFilterTap = UITapGestureRecognizer(target: self, action: #selector(onFliterFavoriteClicked))
        favoriteFilterImageView.isUserInteractionEnabled = true
        favoriteFilterImageView.addGestureRecognizer(favoriteFilterTap)
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
        
        if isAdmin {
            handleAdminCellBehavior(verifiedImg: cell.verifiedImg, branchIndex: indexPath.item)
        }
        
        handleFavoriteBehavior(favoriteImg: cell.myImageView, branchIndex: indexPath.item)
        
        
        return cell
    }
    
    func handleAdminCellBehavior(verifiedImg : UIImageView, branchIndex : Int) {
        verifiedImg.image = self.branchesToPresent[branchIndex].isVerified ?
            UIImage(named: "ic_verified") : UIImage(named: "ic_unverified")
        
        verifiedImg.isUserInteractionEnabled = true
        verifiedImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onVerifyClicked)))
        verifiedImg.tag = branchIndex
    }
    
    func handleFavoriteBehavior(favoriteImg : UIImageView, branchIndex : Int) {
        favoriteImg.image = isFavoriteBranch(branch: self.branchesToPresent[branchIndex]) ?
            UIImage(named: "ic_favorite") : UIImage(named: "ic_unfavorite")
        
        favoriteImg.isUserInteractionEnabled = true
        favoriteImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFavoriteClicked)))
        favoriteImg.tag = branchIndex
    }
    
    func onVerifyClicked(gesture : UITapGestureRecognizer) {
        print("onVerifyClicked")
        let verifyImage = gesture.view! as! UIImageView
        let branch = company.branches[verifyImage.tag]
        
        let isVerified = branch.isVerified
        
        DispatchQueue.main.async() {
            verifyImage.image = isVerified ? UIImage(named: "ic_unverified") : UIImage(named: "ic_verified")
        }
        
        Database.database().reference(withPath: "companies").child(company.name).child("branches")
            .child(branch.name).updateChildValues(["isVerified" : !isVerified])
    }
    
    func onFavoriteClicked(gesture : UITapGestureRecognizer) {
        print("onFavoriteClicked")
        let cellImage = gesture.view! as! UIImageView
        let branchIndex = cellImage.tag

        let isFav = isFavoriteBranch(branch: company.branches[branchIndex])
        
        DispatchQueue.main.async() {
            cellImage.image = isFav ? UIImage(named: "ic_unfavorite") : UIImage(named: "ic_favorite")
        }
        
        defaults.set(!isFav, forKey: company.name + COMPANY_BRANCH_DELIMITER + company.branches[branchIndex].name)
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
        return defaults.bool(forKey: company.name + COMPANY_BRANCH_DELIMITER + branch.name)
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
            
            DispatchQueue.main.async() {
                let image = UIImage(data: data)
                self.headerImageView.image = image
                self.headerImageView.contentMode = .scaleAspectFit
            }
        }
    }
}
