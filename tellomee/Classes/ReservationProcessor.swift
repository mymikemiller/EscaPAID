//
//  ReservationProcessor.swift
//  tellomee
//
//  Created by Michael Miller on 2/5/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

class ReservationProcessor {
    
    static func reserve(_ reservation: Reservation) {
        // Post a confirmation message to the curator
        postReservationConfirmationMessage(for: reservation)
        
        // Save the reservation to the database
        ReservationManager.saveNew(reservation: reservation)
    }
    
    static func postReservationConfirmationMessage(for reservation: Reservation) {
        
        // Post to to the message thread between the user and the experience curator
        ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: reservation.experience.curator, completion: {thread in
            
            let text = "*** \(FirebaseManager.user!.displayName) just booked \(reservation.experience.title) for \(reservation.dateAsString) ***"
            
            // Post a message to the experience provider.
            PostManager.addPost(threadId: (thread.threadId), text: text, toId: thread.user.uid, fromId: (FirebaseManager.user?.uid)!)
        })
    }
}
