//
//  ReservationManager.swift
//  tellomee
//
//  Created by Michael Miller on 2/6/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class ReservationsManager: NSObject {
    
    static let databaseRef = Database.database().reference()
    
    var reservations = [Reservation]()
    
    func fillReservations(forUser user: User, completion: @escaping () -> Void) {
        reservations = [Reservation]()
        
        ReservationsManager.databaseRef.child("reservations").queryOrdered(byChild: "user").queryEqual(toValue: user.uid).observe(.childAdded, with: {
            snap in
            
            self.processReservationSnapshot(snap)
        })
    }
    
    func fillReservations(forCurator curator: User, completion: @escaping () -> Void) {
        reservations = [Reservation]()
        
        ReservationsManager.databaseRef.child("reservations").queryOrdered(byChild: "curator").queryEqual(toValue: curator.uid).observe(.childAdded, with: {
            snap in
            
            self.processReservationSnapshot(snap)
        })
    }
    
    func processReservationSnapshot(_ snap: DataSnapshot) {
        
        if let result = snap.value as? [String:AnyObject]{
            
//            FirebaseManager.getUser(uid: result["uid"] as! String) { (curator) in
//
//                var days = Days.All
//                if (result["days"] != nil) {
//                    days = Days(Monday: result["days"]!["monday"] as! Bool,
//                                Tuesday: result["days"]!["tuesday"] as! Bool,
//                                Wednesday: result["days"]!["wednesday"] as! Bool,
//                                Thursday: result["days"]!["thursday"] as! Bool,
//                                Friday: result["days"]!["friday"] as! Bool,
//                                Saturday: result["days"]!["saturday"] as! Bool,
//                                Sunday: result["days"]!["sunday"] as! Bool)
//                }
//
//                let experience = Experience(
//                    id: snap.key,
//                    title: result["title"] as! String,
//                    category: result["category"] as! String,
//                    city: result["city"] as! String,
//                    startTime: result["startTime"] as! String,
//                    endTime: result["endTime"] as! String,
//                    includes: result["includes"] as! String,
//                    price: Double(result["price"]! as! Double),
//                    days: days,
//                    maxGuests: result["maxGuests"] as! Int,
//                    description: result["description"] as! String,
//                    imageUrls: result["images"] as! [String],
//                    curator: curator)
//
//                experiences.append(experience)
//                completion()
//            }
            
        }
    }
}
