//
//  ReviewManager.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/26/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ReviewManager: NSObject {
    static let databaseRef = Database.database().reference()
    
    var reviews: [Review] = []
    var observeHandle: DatabaseHandle?
    
    static func addReview(experienceId:String, text:String) {
        if (text != "") {
            
            // Store the date (todo: or somehow use Firebase.ServerValue.timestamp())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            
            let review = ["date":dateString,
                          "text":text]
            
            // Add the review
            PostManager.databaseRef.child("experienceReviews").child(experienceId).childByAutoId().setValue(review)
        }
    }
    
    func fillReviews(experience:Experience, completion: @escaping() -> Void) {
        let databaseQuery = ReviewManager.databaseRef.child("experienceReviews").child(experience.id)
        
        // First remove the previous observe handle
        if (observeHandle != nil) {
            databaseQuery.removeObserver(withHandle: observeHandle!)
        }
        
        // Now perform the query
        observeHandle = databaseQuery.observe(.childAdded, with:{
            snapshot in
            
            ReviewManager.getReview(snapshot, experience: experience, completion: { review in
                self.reviews.append(review)
                
                // Signal that we've gotten a new review
                completion()
            })
        })
    }
    
    func fillReviews(curator:User, completion: @escaping() -> Void) {
        
        ExperienceManager.getExperiences(forCurator: curator, completion: { experience in
            // We have one of the curator's experiences, now get all its reviews
            self.fillReviews(experience: experience, completion: {                 // We got a new review. Let the caller know.
                completion()
            })
        })
    }
    
    private static func getReview(_ snapshot: DataSnapshot, experience: Experience, completion: @escaping (_ review: Review) -> Void) {
        
        if let result = snapshot.value as? [String:AnyObject]{
            let text = result["text"]! as! String
            let title = result["title"]! as! String
            let reviewerUid = result["reviewer"]! as! String
            let dateString = result["date"]! as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dateString)!
            
            
            // Get the user who wrote the review
            FirebaseManager.getUser(uid: reviewerUid, completion: { (reviewer) in
                
                if (reviewer != nil) {
                    
                    let review = Review(experience: experience, title: title, text: text, reviewer: reviewer!, date: date)
                    
                    completion(review)
                }
            })
        }
    }
}

