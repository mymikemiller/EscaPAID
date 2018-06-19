//
//  ExperienceManager.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ExperienceManager: Manager {
    
    var experiences = [Experience]()
    
    // Record the queries and observe handles we use so we can easily remove the observers when we change the query
    var databaseQuery: DatabaseQuery?
    var observeHandle: DatabaseHandle?
    
    // Keep track of when Experiences were favorited. Values here are only used for sorting favorites, therefore there may be irrelevant values here for Experiences that are not currently favorited.
    static var favoritedTimestamps = [Experience : Int]()
    
    func clear() {
        experiences = [Experience]()
        
        // Also remove the observer
        databaseQuery?.removeObserver(withHandle: observeHandle!)
    }
    
    func fillExperiences(forCity city: String, completion: @escaping () -> Void) {
        clear()
        
        databaseQuery = Manager.databaseRef.child("experiences").queryOrdered(byChild: "city").queryEqual(toValue: city)
        observeHandle = databaseQuery?.observe(.childAdded, with: {
            snap in
            
            ExperienceManager.getExperience(snap, completion: { (experience) in
                self.experiences.append(experience)
                completion()
            })
        })
    }
    
    
    func fillExperiences(forCurator user: User, completion: @escaping () -> Void) {
        clear()
        
        databaseQuery = ExperienceManager.databaseRef.child("experiences").queryOrdered(byChild: "uid").queryEqual(toValue: user.uid)
        observeHandle = databaseQuery?.observe(.childAdded, with: {
            snap in
            
            ExperienceManager.getExperience(snap, completion: { (experience) in
                self.experiences.append(experience)
                completion()
            })
        })
    }
    
    static func getExperiences(forCurator user: User, completion: @escaping (Experience) -> Void) {
        ExperienceManager.databaseRef.child("experiences").queryOrdered(byChild: "uid").queryEqual(toValue: user.uid).observe(.childAdded, with: {
            snap in
            
            ExperienceManager.getExperience(snap, completion: { (experience) in
                completion(experience)
            })
        })
    }

    
    func fillExperiences(forFavoritesOf user: User, completion: @escaping () -> Void) {
        clear()
        
        // Get the favorites for the user, in order of the timestamp saved as the value
        databaseQuery = ExperienceManager.databaseRef.child("userFavorites/\(user.uid)").queryOrderedByValue()
        observeHandle = databaseQuery?.observe(.childAdded, with: { snapshot in
            let experienceId = snapshot.key
            let timestamp = snapshot.value! as! Int
            
            // Get the actual experience
            ExperienceManager.databaseRef.child("experiences/\(experienceId)").observeSingleEvent(of: .value, with: {
                snap in
                
                ExperienceManager.getExperience(snap, completion: { (experience) in
                    self.experiences.append(experience)
                    // Cache the time the Experience was favorited so we can sort
                    ExperienceManager.favoritedTimestamps[experience] = timestamp
                    // Sort by experience.dateFavorited, which every experience here should have
                    self.experiences = self.experiences.sorted(by: { (a, b) -> Bool in
                        ExperienceManager.favoritedTimestamps[a]! > ExperienceManager.favoritedTimestamps[b]!
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
            
            if (snap.hasChildren()) {
                getExperience(snap, completion: completion)
            }
            
        })
    }
    
    private static func getExperience(_ snap: DataSnapshot, completion: @escaping (_ experience: Experience) -> Void) {
        
        let result = snap.value as! [String:AnyObject]
        let uid = result["uid"] as! String
        let experienceId = snap.key
        
        FirebaseManager.getUser(uid: uid) { (curator) in
            
            guard let curator = curator else {
                print("When getting experience \(experienceId), failed to retrieve curator at uid \(uid)")
                return
            }
            
            var days = Days.All
            let resultDays = result["days"]! as! [String:AnyObject]
            if (result["days"] != nil) {
                days = Days(Monday: resultDays["monday"] as! Bool,
                            Tuesday: resultDays["tuesday"] as! Bool,
                            Wednesday: resultDays["wednesday"] as! Bool,
                            Thursday: resultDays["thursday"] as! Bool,
                            Friday: resultDays["friday"] as! Bool,
                            Saturday: resultDays["saturday"] as! Bool,
                            Sunday: resultDays["sunday"] as! Bool)
            }
            
            let experience = Experience(
                id: experienceId,
                title: result["title"] as! String,
                category: result["category"] as! String,
                city: result["city"] as! String,
                startTime: result["startTime"] as! String,
                endTime: result["endTime"] as! String,
                includes: result["includes"] as! String,
                price: result["price"]! as! Int,
                days: days,
                maxGuests: result["maxGuests"] as! Int,
                skillLevel: result["skillLevel"] as! String,
                description: result["description"] as! String,
                imageUrls: result["images"] as! [String],
                curator: curator)
            
            completion(experience)
        }
    }
    
    static func onIsFavoriteChanged(experience: Experience, completion: @escaping (_ isFavorite: Bool) -> Void) {
        // Find out whether or not the experience is a favorite of the current user.
        databaseRef.child("userFavorites/\((FirebaseManager.user?.uid)!)/\(experience.id)").observe(.value, with: { (snap) in
            
            // If it's a favorite, snap will exist because there is a child at that address
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
