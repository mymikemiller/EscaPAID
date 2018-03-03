//
//  Reservation.swift
//  tellomee
//
//  Created by Michael Miller on 2/5/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

class Reservation {
    
    enum Status: String {
        case pending = "pending"
        case accepted = "accepted"
        case declined = "declined"
    }
    
    static let databaseDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    static let prettyDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM dd, yyyy"
        return df
    }()
    
    // Id is only assigned once the reservation is saved for the first time, or when it's loaded from the database
    var id: String?
    let experience: Experience
    let user: User
    let date: Date
    let numGuests: Int
    let totalCharge: Double
    let fee: Double
    
    // Status can be changed via the ReservationManager, which also saves the change to the database
    var status: Status
    
    init(experience: Experience, user: User, date: Date, numGuests: Int, totalCharge: Double, fee: Double, status: Status) {
        self.experience = experience
        self.user = user
        self.date = date
        self.numGuests = numGuests
        self.totalCharge = totalCharge
        self.fee = fee
        self.status = status
    }
    
    var dateAsPrettyString: String {
        get { return "\(Reservation.prettyDateFormatter.string(from: (date))) at \(experience.startTime)" }
    }
}
