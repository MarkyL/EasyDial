//
//  Company.swift
//  EasyDial
//
//  Created by Omri Ohayon on 13/07/2019.
//  Copyright © 2019 Omri Ohayon. All rights reserved.
//

import Foundation
import Firebase

struct Company{
    
    let ref : DatabaseReference?
    let name : String
    let imageStr : String
    var branches : [Branch] = []
    
    
    init(name : String = "" , imageStr : String , branches: [Branch] ) {
        
        self.ref = nil
        self.name = name
        self.imageStr = imageStr
        self.branches = branches
        
    }
    
    
    init?(snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: AnyObject],
            let imageStr = value["imageStr"] as? String
            else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.name = snapshot.key
        self.imageStr = imageStr
        
        if let branches = snapshot.childSnapshot(forPath: "branches") as? DataSnapshot {
            for child in branches.children {
                if let snapshot = child as? DataSnapshot,
                    let branch = Branch(snapshot: snapshot) {
                    self.branches.append(branch)
                }
            }
        }
    }
    
    func toAnyObject() -> Any {
        
        return ["imageStr" : imageStr ,
                "branches" : getBranches()]
    }
    
    func getBranches() -> Any {
        
        var branches  = [String:Any]()
        for branch in self.branches {
            branches[branch.name] = branch.toAnyObject()
        }
        
        return branches
    }
    
    
}
