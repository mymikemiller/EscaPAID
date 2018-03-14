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
            
            self.insertReservationFromSnapshot(snap, completion: completion)
        })
    }
    
    func fillReservations(forCurator curator: User, completion: @escaping () -> Void) {
        reservations = [Reservation]()
        
        ReservationManager.databaseRef.child("reservations").queryOrdered(byChild: "curator").queryEqual(toValue: curator.uid).observe(.childAdded, with: {
            snap in
            
            self.insertReservationFromSnapshot(snap, completion: completion)
        })
    }
    
    func insertReservationFromSnapshot(_ snap: DataSnapshot, completion: @escaping () -> Void) {
        
        if let result = snap.value as? [String:AnyObject]{
            
            let uid = result["user"] as! String
            
            // Get the user first
            FirebaseManager.getUser(uid: uid) { (user) in
                
                guard let user = user else {
                    print("Error initialization reservation from snapshot. No user at the specified uid: /\(uid)")
                    return
                }
                    
                ExperienceManager.getExperience(experienceId: result["experienceId"] as! String) {
                    (experience) in
                    
                    let date = Reservation.databaseDateFormatter.date(from: result["date"] as! String)
                    
                    let status = Reservation.Status(rawValue: result["status"] as! String)!
                    
                    let reservation =
                        Reservation(experience: experience,
                                    user: user,
                                    date: date!,
                                    numGuests: result["numGuests"] as! Int,
                                    totalCharge: result["totalCharge"] as! Int,
                                    fee: result["fee"] as! Int,
                                    status: status)
                    
                    // The id isn't stored as a value, it's the snapthot's key
                    reservation.id = snap.key
                    
                    // Insert the reservation at the beginning of the list so new Reservations appear at the top of the list
                    self.reservations.insert(reservation, at: 0)
                    completion()
                }
            }
        }
    }
    
    // Saves to database and assigns an id
    static func save(reservation: Reservation, completion: @escaping () -> Void) {
        
        var ref: DatabaseReference
        if (reservation.id == nil) {
            // We're not saved to the database yet. Create a new entry.
            ref = FirebaseManager.databaseRef.child("reservations").childByAutoId()
            
            // Set the key so we can edit the reservation later
            reservation.id = ref.key
        } else {
            // We already exist in the database. Get the corresponding entry.
            ref = FirebaseManager.databaseRef.child("reservations").child(reservation.id!)
        }
        
        let update = [
            "experienceId":reservation.experience.id,
            "curator":reservation.experience.curator.uid,
            "curatorStripeId": reservation.experience.curator.stripeCuratorId,
            "user": reservation.user.uid,
            "userStripeId": reservation.user.stripeCustomerId,
            "date": Reservation.databaseDateFormatter.string(from: reservation.date),
            "numGuests": reservation.numGuests,
            "totalCharge": reservation.totalCharge,
            "fee": reservation.fee,
            "status": reservation.status.rawValue,
            "stripeChargeId": reservation.stripeChargeId] as [String : Any]
    
        ref.updateChildValues(update) { (error, ref) in
            completion()
        }
    }
    
    static func setStatus(for reservation: Reservation!, status: Reservation.Status) {
        
        reservation.status = status
        
        if let id = reservation.id {
            FirebaseManager.databaseRef.child("reservations").child(id).updateChildValues([
                "status":status.rawValue])
        } else {
            NSException(name:NSExceptionName(rawValue: "SetStatusOnUnsavedReservation"), reason:"You must use ReservationManager.saveNew on a new Reservation before calling setStatus").raise()
        }
       
    }
}
