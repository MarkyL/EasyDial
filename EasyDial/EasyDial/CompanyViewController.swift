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
    
    var company : Company!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if company != nil {
            print("received company with values - {0}",self.company ?? "NO COMPANY")
            let url = URL(string: (self.company?.imageStr)!)!
            downloadImage(from: url)
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onTapHeaderBranch))
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(singleTap)
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
        return (self.company?.branches.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = company?.branches[indexPath.item].name
        
        return cell
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started url:, {0}", url)

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
