//
//  Experience.swift
//  tellomee
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class Experience: NSObject {
    
    var title:String
    var photoUrl:String = ""
    var curator:User
    
    init(title:String, curator:User) {
        self.title = title
        self.curator = curator
    }
}

