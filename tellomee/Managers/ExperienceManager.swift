//
//  ExperienceManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ExperienceManager: NSObject {
    static let databaseRef = Database.database().reference()
    
    static var experiences = [Experience]()
    
    static func fillExperiences(completion: @escaping () -> Void) {
        experiences = [Experience]()
        
        databaseRef.child("experiences").queryOrdered(byChild: "city").queryEqual(toValue: "SF").observe(.childAdded, with: {
            snap in
            
            FirebaseManager.getUser(uid: FirebaseManager.currentUserId) { (user) in
                
                if let result = snap.value as? [String:AnyObject]{
                    let experience = Experience(
                        title: result["title"] as! String,
                        curator: user)
                    
                    experiences.append(experience)
                    completion()
                }
                
            }
            
        })
    }
}

