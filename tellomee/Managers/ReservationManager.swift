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


class ReservationManager: NSObject {
    
    static let databaseRef = Database.database().reference()
    
    var reservations = [Reservation]()
    
    func fillReservations(forUser user: User, completion: @escaping () -> Void) {
        reservations = [Reservation]()
        
        ReservationManager.databaseRef.child("reservations").queryOrdered(byChild: "user").queryEqual(toValue: user.uid).observe(.childAdded, with: {
            snap in
            
            self.processReservationSnapshot(snap, completion: completion)
        })
    }
    
    func fillReservations(forCurator curator: User, completion: @escaping () -> Void) {
        reservations = [Reservation]()
        
        ReservationManager.databaseRef.child("reservations").queryOrdered(byChild: "curator").queryEqual(toValue: curator.uid).observe(.childAdded, with: {
            snap in
            
            self.processReservationSnapshot(snap, completion: completion)
        })
    }
    
    func processReservationSnapshot(_ snap: DataSnapshot, completion: @escaping () -> Void) {
        
        if let result = snap.value as? [String:AnyObject]{
            
            // Get the user first
            FirebaseManager.getUser(uid: result["user"] as! String) { (user) in
                    
                ExperienceManager.getExperience(experienceId: result["experienceId"] as! String) {
                    (experience) in
                    
                    let date = Reservation.databaseDateFormatter.date(from: result["date"] as! String)
                    
                    let reservation = Reservation(experience: experience, user: user, date: date!, numGuests: result["numGuests"] as! Int)
                    
                    self.reservations.append(reservation)
                    completion()
                }
            }
        }
    }
    
    static func saveNew(reservation: Reservation) {
     FirebaseManager.databaseRef.child("reservations").childByAutoId().updateChildValues([
            "experienceId":reservation.experience.id,
            "curator":reservation.experience.curator.uid,
            "user": reservation.user.uid,
            "date": Reservation.databaseDateFormatter.string(from: reservation.date),
            "numGuests": reservation.numGuests])
    }
}
