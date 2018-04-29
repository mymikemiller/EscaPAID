//
//  Constants.swift
//  EscaPAID
//
//  Created by Michael Miller on 12/8/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

// Constants that don't depend on the target. See Config.swift for config settings varying per target.
class Constants: NSObject {
    
    // Debug mode enables things like extra login buttons for debug accounts
    static var debugMode = false
    
    static let stripeApiVersion =  "2018-02-06"
    
    // The ratio of width to height of the ExperienceCards
    static let cardRatio = 380/185.0
    
    // The expected ratio of width to height of the experience images. It's ok for them to vary, but they'll be aspect fit into a space with this ratio
    static let experienceImageRatio = 414/260.0
    
    static let numGuests = ["1",
                            "2",
                            "3",
                            "4",
                            "5",
                            "6",
                            "7",
                            "8"]
    
    static let cities = ["San Francisco",
                         "Seattle",
                         "Salt Lake City"]
    
    static let skillLevels = ["Beginner",
                              "Intermediate",
                              "Expert"]

}
