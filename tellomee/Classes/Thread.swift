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
    
    // The user this is a thread between (between this user and firebase's current authenticated user)
    var user:User
    
    var threadId:String
    var lastMessageTimestamp:Date
    var read:Bool
    
    init(with:User, threadId:String, lastMessageTimestamp: Date, read: Bool) {
        self.user = with
        self.threadId = threadId
        self.lastMessageTimestamp = lastMessageTimestamp
        self.read = read
    }
    
    func setRead(read: Bool) {
        self.read = read
        // Write it to the database
        FirebaseManager.databaseRef.child("userThreads").child(FirebaseManager.currentUserId).child(threadId).updateChildValues(["read":read])
    }
}
