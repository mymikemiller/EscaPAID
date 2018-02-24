//
//  Constants.swift
//  tellomee
//
//  Created by Michael Miller on 12/8/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class Constants: NSObject {
    static let cities = ["San Francisco",
                  "Seattle",
                  "Salt Lake City"]
    
    static let categories = ["Adventure",
                         "Lifestyle",
                         "Cullinary"]
    
    static let numGuests = ["1",
                             "2",
                             "3",
                             "4",
                             "5",
                             "6",
                             "7",
                             "8"]
    
    static let feePercent = 0.1 // 10% fee deducted from the total charge for reservations

    static let stripeApiVersion =  "2018-02-06"
    static let stripeClientId = "ca_AbsKVVP7BmIJFntfSkToXhxtLSAvbIUM"
}
