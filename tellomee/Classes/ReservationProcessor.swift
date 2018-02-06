//
//  ReservationProcessor.swift
//  tellomee
//
//  Created by Michael Miller on 2/5/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

class ReservationProcessor {
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df
    }()
    
    static func reserve(_ reservation: Reservation) {
        // Post a confirmation message to the curator
        postReservationConfirmationMessage(for: reservation)
    }
    
    static func postReservationConfirmationMessage(for reservation: Reservation) {
        
        // Post to to the message thread between the user and the experience curator
        ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: reservation.experience.curator, completion: {thread in
            
            let text = "*** \(FirebaseManager.user!.displayName) just booked \(reservation.experience.title) for \(dateFormatter.string(from: (reservation.date))) at \(reservation.experience.startTime) ***"
            
            // Post a message to the experience provider.
            PostManager.addPost(threadId: (thread.threadId), text: text, toId: thread.user.uid, fromId: (FirebaseManager.user?.uid)!)
        })
    }
}
