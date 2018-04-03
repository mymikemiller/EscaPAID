//
//  ReservationProcessor.swift
//  EscaPAID
//
//  Created by Michael Miller on 2/5/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

class ReservationProcessor {
    
    static func reserve(_ reservation: Reservation, completion: @escaping () -> Void) {
        // Save the reservation to the database
        ReservationManager.save(reservation: reservation, completion: {
            completion()
        })
    }
    
    static func postReservationConfirmationMessage(for reservation: Reservation) {
        
        // Post to to the message thread between the user and the experience curator
        ThreadManager.getOrCreateThread(with: reservation.experience.curator, completion: {thread in
            
            let text = "*** \(FirebaseManager.user!.firstName) just booked \(reservation.experience.title) for \(reservation.dateAsPrettyString) ***"
            
            // Post a message to the experience provider.
            PostManager.addPost(threadId: (thread.threadId), text: text, toId: thread.user.uid, fromId: (FirebaseManager.user?.uid)!)
        })
    }
}
