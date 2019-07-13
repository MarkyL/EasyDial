//
//  Branch.swift
//  EasyDial
//
//  Created by Omri Ohayon on 13/07/2019.
//  Copyright © 2019 Omri Ohayon. All rights reserved.
//

import Foundation
import Firebase

struct Branch{
    
    let ref : DatabaseReference?
    let name : String
    let number : String
    var isVerified : Bool
    
    init(name : String = "" , number : String , isVerified : Bool) {
        
        self.ref = nil
        self.name = name
        self.number = number
        self.isVerified = isVerified
        
    }
    
    
    init?(snapshot: DataSnapshot){
        guard
        let value = snapshot.value as? [String: AnyObject],
        let number = value["number"] as? String,
        let isVerified = value["isVerified"] as? Bool
        else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.name = snapshot.key
        self.number = number
        self.isVerified = isVerified
        
    }

    
    func toAnyObject()->Any{
        return ["number" : number,
                "isVerified" : isVerified]
    }
    
    
}
