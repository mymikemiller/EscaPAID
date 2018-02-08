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
    
    func clear() {
        reservations = [Reservation]()
    }
    
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
                    
                    let status = Reservation.Status(rawValue: result["status"] as! String)!
                    
                    let reservation =
                        Reservation(experience: experience,
                                    user: user,
                                    date: date!,
                                    numGuests: result["numGuests"] as! Int,
                                    totalCharge: result["totalCharge"] as! Double,
                                    fee: result["fee"] as! Double,
                                    status: status)
                    
                    // The id isn't stored as a value, it's the snapthot's key
                    reservation.id = snap.key
                    
                    self.reservations.append(reservation)
                    completion()
                }
            }
        }
    }
    
    // Saves to database and assigns an id
    static func saveNew(reservation: Reservation) {
        let newRef = FirebaseManager.databaseRef.child("reservations").childByAutoId()
        
        // Set the key so we can edit the reservation later
        reservation.id = newRef.key
        FirebaseManager.databaseRef.child("reservations").childByAutoId().updateChildValues([
            "experienceId":reservation.experience.id,
            "curator":reservation.experience.curator.uid,
            "user": reservation.user.uid,
            "date": Reservation.databaseDateFormatter.string(from: reservation.date),
            "numGuests": reservation.numGuests,
            "totalCharge": reservation.totalCharge,
            "fee": reservation.fee,
            "status": reservation.status])
    }
    
    static func setStatus(for reservation: Reservation!, status: Reservation.Status) {
        
        if let id = reservation.id {
            FirebaseManager.databaseRef.child("reservations").child(id).updateChildValues([
                "status":status.rawValue])
        } else {
            NSException(name:NSExceptionName(rawValue: "SetStatusOnUnsavedReservation"), reason:"You must use ReservationManager.saveNew on a new Reservation before calling setStatus").raise()
        }
       
    }
}
