//
//  Days.swift
//  EscaPAID
//
//  Created by Michael Miller on 1/21/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

struct Days {
    var Monday: Bool
    var Tuesday: Bool
    var Wednesday: Bool
    var Thursday: Bool
    var Friday: Bool
    var Saturday: Bool
    var Sunday: Bool
    
    func toString() -> String {
        var result =
            (Monday ? "Mon, " : "") +
                (Tuesday ? "Tue, " : "") +
                (Wednesday ? "Wed, " : "") +
                (Thursday ? "Thu, " : "") +
                (Friday ? "Fri, " : "") +
                (Saturday ? "Sat, " : "") +
                (Sunday ? "Sun, " : "")
        
        // Remove the trailing comma and space
        result = String(result.dropLast().dropLast())
        
        if (result.isEmpty) {
            result = "None"
        }
        
        return result
    }
    
    static let All: Days = Days(Monday: true, Tuesday: true, Wednesday: true, Thursday: true, Friday: true, Saturday: true, Sunday: true)
}
