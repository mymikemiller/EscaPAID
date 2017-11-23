//
//  Thread.swift
//  tellomee
//
//  Created by Michael Miller on 11/20/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import Foundation

import UIKit
import FirebaseStorage

class Thread: NSObject {
    
    // The user this is a thread between (between this user and firebase's current authorized user)
    var user:User
    
    var threadId:String
    var lastMessageTimestamp:Date
    
    init(with:User, threadId:String, lastMessageTimestamp: Date) {
        self.user = with
        self.threadId = threadId
        self.lastMessageTimestamp = lastMessageTimestamp
    }
}
