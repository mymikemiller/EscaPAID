//
//  Reservation.swift
//  tellomee
//
//  Created by Michael Miller on 2/5/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

class Reservation {
    let experience: Experience
    let date: Date
    let numGuests: Int
    
    var total: Double {
        get {
            return Double(numGuests) * (experience.price)
        }
    }
    
    init(experience: Experience, date: Date, numGuests: Int) {
        self.experience = experience
        self.date = date
        self.numGuests = numGuests
    }
}
