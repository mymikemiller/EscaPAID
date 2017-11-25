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
    
    // Add a thread and keep them sorted in descending order by timestamp of last message
    static func add(thread:Thread) {
        threads.append(thread)
        threads.sort { (one, two) -> Bool in
            one.lastMessageTimestamp > two.lastMessageTimestamp
        }
    }
    
    // Bump up the specified thread to the front of the list
    static func bump(threadId:String) {
        let index = threads.index { (thread) -> Bool in
            thread.threadId == threadId
        }
        if (index != nil) {
            let thread = threads.remove(at: index!)
            threads.insert(thread, at: 0)
        }
    }
    
    static func getOrCreateThread(between user:User, and curator:User, completion: @escaping (Thread) -> ()) {
        // Try to find a thread that exists. Look in the user's threads and see if any thread exists that contains the curator as the other user
        databaseRef.child("userThreads").child(user.uid).observeSingleEvent(of: .value) {
            (snap) in
            
            var threadId:String? = nil
            let enumerator = snap.children
            while threadId == nil, let rest = enumerator.nextObject() as? DataSnapshot {
                let existingThreadId = rest.key
                
                // See if this threadId refers to one between the user and the curator
                // Get the actual thread
                databaseRef.child("threads").queryOrderedByKey().queryEqual(toValue: existingThreadId).observeSingleEvent(of: .value, with: { (threadSnap) in
                    
                    // For each item in the thread object
                    for item in threadSnap.children.allObjects as! [DataSnapshot] {
                        let value = item.value as! NSDictionary
                        // ...get the other user's uid
                        let user1 = value["user1"] as! String
                        let user2 = value["user2"] as! String
                        if (user1 == curator.uid || user2 == curator.uid) {
                            threadId = existingThreadId
                            break
                        }
                    }
                })
            }
            
            if (threadId == nil) {
                // Create a thread
                // todo: move dateFormatter to a static constant
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let newThread = ["user1":user.uid,
                        "user2":curator.uid,
                        "lastMessageTimestamp":dateFormatter.string(from:Date())]
            
                threadId = databaseRef.child("threads").childByAutoId().key
                databaseRef.child("threads").child(threadId!).setValue(newThread)
            }
            
            // Add this new thread to both users' userThreads so it shows up in their inbox
            databaseRef.child("userThreads").child(user.uid).child(threadId!).setValue(true)
            databaseRef.child("userThreads").child(curator.uid).child(threadId!).setValue(true)
            
            let thread = Thread(with: curator, threadId: threadId!, lastMessageTimestamp: Date())
            completion(thread)
        }
    }
    
    static func fillThreads(completion: @escaping () -> Void) {
        let currentUid = Auth.auth().currentUser?.uid
        ThreadManager.threads = [Thread]()
        // Get the current user's threads
        databaseRef.child("userThreads").queryOrderedByKey().queryEqual(toValue: currentUid).observe(.childAdded, with: {
            userThreadSnapshot in
            
            // For each of the user's threads...
            for userThread in userThreadSnapshot.children {
                let threadId = (userThread as! DataSnapshot).key
                
                // To find the uid of the other user in the thread, we need to find the thread in the threads tree
                databaseRef.child("threads").queryOrderedByKey().queryEqual(toValue: threadId).observeSingleEvent(of: DataEventType.value, with: { (threadSnapshot) in
                    
                    // For each item in the thread object
                    for item in threadSnapshot.children.allObjects as! [DataSnapshot] {
                        let value = item.value as! NSDictionary
                        // ...get the other user's uid
                        let user1 = value["user1"] as! String
                        let user2 = value["user2"] as! String
                        let otherUserUid = currentUid == user1 ? user2 : user1
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let lastMessageTimestampString = value["lastMessageTimestamp"] as! String
                        let lastMessageTimestamp = dateFormatter.date(from: lastMessageTimestampString)
                    
                        // Get the other user object
                        FirebaseManager.getUser(uid: otherUserUid, completion: { user
                            in
                            
                            // Create the thread object and add it to our list
                            let thread = Thread(with: user, threadId: threadId, lastMessageTimestamp: lastMessageTimestamp!)
                            ThreadManager.add(thread: thread)
                            completion()
                        })
                    }
                })
            }
        })
    }
}
