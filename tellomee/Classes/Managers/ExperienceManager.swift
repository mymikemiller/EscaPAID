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
    
    var experiences = [Experience]()
    
    func fillExperiences(forCity city: String, completion: @escaping () -> Void) {
        experiences = [Experience]()
        
        ExperienceManager.databaseRef.child("experiences").queryOrdered(byChild: "city").queryEqual(toValue: city).observe(.childAdded, with: {
            snap in
            
            
            ExperienceManager.getExperience(snap, completion: { (experience) in
                self.experiences.append(experience)
                completion()
            })
        })
    }
    
    
    func fillExperiences(forCurator user: User, completion: @escaping () -> Void) {
        experiences = [Experience]()
        
        ExperienceManager.databaseRef.child("experiences").queryOrdered(byChild: "uid").queryEqual(toValue: user.uid).observe(.childAdded, with: {
            snap in
            
            ExperienceManager.getExperience(snap, completion: { (experience) in
                self.experiences.append(experience)
                completion()
            })
        })
    }
    
    func fillExperiences(forFavoritesOf user: User, completion: @escaping () -> Void) {
        experiences = [Experience]()
        
        // Get the favorites for the user, in order of the timestamp saved as the value
        ExperienceManager.databaseRef.child("userFavorites/\(user.uid)").queryOrderedByValue().observe(.childAdded, with: { snapshot in
            let experienceId = snapshot.key
            let timestamp = snapshot.value!
            
            // Get the actual experience
            ExperienceManager.databaseRef.child("experiences/\(experienceId)").observeSingleEvent(of: .value, with: {
                snap in
                
                ExperienceManager.getExperience(snap, completion: { (experience) in
                    self.experiences.append(experience)
                    // Sort by experience.dateFavorited, which every experience here should have
                    self.experiences = self.experiences.sorted(by: { (a, b) -> Bool in
                        a.favoritedTimestamp! > b.favoritedTimestamp!
                    })
                    
                    completion()
                })
            })
        })
        
        // Remove the experience from our list when the experience is removed from the favorites list on the database
        ExperienceManager.databaseRef.child("userFavorites/\(user.uid)").queryOrderedByValue().observe(.childRemoved, with: { snapshot in
            // Remove the Experience with the returned id from our collection, then call the completion
            let removedId = snapshot.key
            print("removing " + removedId)
            self.experiences = self.experiences.filter( { ( experience: Experience ) in return experience.id != removedId } )
            completion()
        })
    }
    
    static func getExperience(experienceId: String, completion: @escaping (_ experience: Experience) -> Void) {
        databaseRef.child("experiences").child(experienceId).observeSingleEvent(of: .value, with: {
            snap in
            
            getExperience(snap, completion: completion)
            
        })
    }
    
    private static func getExperience(_ snap: DataSnapshot, completion: @escaping (_ experience: Experience) -> Void) {
        
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
            
            databaseRef.child("userFavorites/\(FirebaseManager.user!.uid)/\(experience.id)").observeSingleEvent(of: .value, with: {
                snap in
                
                if (snap.exists()) {
                
                    let timestamp:Int = snap.value! as! Int
                    experience.favoritedTimestamp = timestamp
                }
                
                completion(experience)
                
            })
           
        }
    }
    
    static func onIsFavoriteChanged(experience: Experience, completion: @escaping (_ isFavorite: Bool) -> Void) {
        // Find out whether or not the experience is a favorite of the current user.
        databaseRef.child("userFavorites/\((FirebaseManager.user?.uid)!)/\(experience.id)").observe(.value, with: { (snap) in
            
            // If it's a favorite, snap.value won't be nil because there is a child at that address
            let isFavorite = snap.exists()
            completion(isFavorite)
            
        })
    }
    
    static func favorite(experience: Experience) {
        let ref = FirebaseManager.databaseRef.child("userFavorites/\((FirebaseManager.user?.uid)!)/\(experience.id)")
        ref.setValue(Firebase.ServerValue.timestamp())
    }
    static func unFavorite(experience: Experience) {
        let ref = FirebaseManager.databaseRef.child("userFavorites/\((FirebaseManager.user?.uid)!)/\(experience.id)")
        ref.removeValue()
    }
}
