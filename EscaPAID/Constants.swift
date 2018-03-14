//
//  Constants.swift
//  tellomee
//
//  Created by Michael Miller on 12/8/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    // If true, the user will automatically be logged in based on what's hardcoded in the input fields.
    static var autoLogin = true
    
    static let numGuests = ["1",
                            "2",
                            "3",
                            "4",
                            "5",
                            "6",
                            "7",
                            "8"]
    
    static let stripeApiVersion =  "2018-02-06"
    
    
    
    static let cities = ["San Francisco",
                  "Seattle",
                  "Salt Lake City"]
    
    static let categories = ["Adventure",
                         "Lifestyle",
                         "Cullinary"]
    
    static let feePercent = 0.1 // 10% fee deducted from the total charge for reservations

    static let stripePublishableKey = "pk_test_Qw7nfjZOYT8EyoLpE51Dm9fw"
    static let stripeClientId = "ca_AbsKVVP7BmIJFntfSkToXhxtLSAvbIUM"
}
