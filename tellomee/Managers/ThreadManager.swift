//
//  ThreadManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ThreadManager: NSObject {
    static let databaseRef = Database.database().reference()
    
    static var threads = [Thread]()
    
    static func fillThreads(completion: @escaping () -> Void) {
        let currentUid = Auth.auth().currentUser?.uid
        ThreadManager.threads = [Thread]()
        // Get the current user's threads
        databaseRef.child("userThreads").queryOrderedByKey().queryEqual(toValue: currentUid).observe(.childAdded, with: {
            userThreadSnapshot in
            
            // For each of the user's threads...
            for userThread in userThreadSnapshot.children {
                let threadId = (userThread as! DataSnapshot).key
                
                // To find the uid of the other user in the thread, we need to find the thrad in the threads tree
                databaseRef.child("threads").queryOrderedByKey().queryEqual(toValue: threadId).observeSingleEvent(of: DataEventType.value, with: { (threadSnapshot) in
                    
                    // For each item in the thread object
                    for item in threadSnapshot.children.allObjects as! [DataSnapshot] {
                        let value = item.value as! NSDictionary
                        // ...get the other user's uid
                        let user1 = value["user1"] as! String
                        let user2 = value["user2"] as! String
                        let otherUserUid = currentUid == user1 ? user2 : user1
                    
                        // Get the other user object
                        FirebaseManager.getUser(uid: otherUserUid, completion: { user
                            in
                            let thread = Thread(with: user, threadId: threadId)
                            ThreadManager.threads.append(thread)
                            completion()
                        })
                        
                        
                    }
                })
            }
        })
    }
}
