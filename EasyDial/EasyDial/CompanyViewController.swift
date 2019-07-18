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

class CompanyViewController: UIViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    var company : Company?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if company != nil {
            print("received company with values - {0}",self.company ?? "NO COMPANY")
            let url = URL(string: (self.company?.imageStr)!)!
            downloadImage(from: url)
        }
        
        
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
