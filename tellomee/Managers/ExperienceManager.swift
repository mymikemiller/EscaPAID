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
        
        databaseRef.child("experiences").queryOrdered(byChild: "city").queryEqual(toValue: FirebaseManager.user?.city).observe(.childAdded, with: {
            snap in
            
            
            getExperience(snap: snap, completion: { (experience) in
                experiences.append(experience)
                completion()
            })
        })
    }
    
    static func getExperience(experienceId: String, completion: @escaping (_ experience: Experience) -> Void) {
        databaseRef.child("experiences").child(experienceId).observeSingleEvent(of: .value, with: {
            snap in
            
            getExperience(snap: snap, completion: completion)
            
        })
    }
    
    private static func getExperience(snap: DataSnapshot, completion: @escaping (_ experience: Experience) -> Void) {
        
        let result = snap.value as! [String:AnyObject]
        
        FirebaseManager.getUser(uid: result["uid"] as! String) { (curator) in
            
            var days = Days.All
            if (result["days"] != nil) {
                days = Days(Monday: result["days"]!["monday"] as! Bool,
                            Tuesday: result["days"]!["tuesday"] as! Bool,
                            Wednesday: result["days"]!["wednesday"] as! Bool,
                            Thursday: result["days"]!["thursday"] as! Bool,
                            Friday: result["days"]!["friday"] as! Bool,
                            Saturday: result["days"]!["saturday"] as! Bool,
                            Sunday: result["days"]!["sunday"] as! Bool)
            }
            
            let experience = Experience(
                id: snap.key,
                title: result["title"] as! String,
                category: result["category"] as! String,
                city: result["city"] as! String,
                startTime: result["startTime"] as! String,
                endTime: result["endTime"] as! String,
                includes: result["includes"] as! String,
                price: Double(result["price"]! as! Double),
                days: days,
                maxGuests: result["maxGuests"] as! Int,
                description: result["description"] as! String,
                imageUrls: result["images"] as! [String],
                curator: curator)
            
            completion(experience)
        }
    }
}
