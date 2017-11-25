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
            
            // Only try to find the thread if we have any children
            if (snap.childrenCount > 0) {
                let userThreads = snap.value as! [String:AnyObject]
                for userThreadId in userThreads.keys {
                    let otherUserUid = (userThreads[userThreadId] as! [String:AnyObject])["with"] as! String
                    if (otherUserUid == curator.uid) {
                        // We found the thread
                        threadId = userThreadId
                        break
                    }
                }
            }
            
            if (threadId == nil) {
                // Create a thread
                // todo: move dateFormatter to a static constant
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var newThread = [
                        "with":curator.uid,
                        "read":true,
                        "lastMessageTimestamp":dateFormatter.string(from:Date())] as [String : Any]
            
                threadId = databaseRef.child("userThreads").child(user.uid).childByAutoId().key
                databaseRef.child("userThreads").child(user.uid).child(threadId!).setValue(newThread)
                
                // Also add the same threadId (unread) to the curator's userThreads so the thread appears in their inbox
                newThread["with"] = user.uid
                newThread["read"] = false
                databaseRef.child("userThreads").child(curator.uid).child(threadId!).setValue(newThread)
            }
            
            let thread = Thread(with: curator, threadId: threadId!, lastMessageTimestamp: Date(), read: true)
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
                let results = (userThread as! DataSnapshot).value as! [String:AnyObject]
                let otherUserUid = results["with"] as! String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let lastMessageTimestampString = results["lastMessageTimestamp"] as! String
                let lastMessageTimestamp = dateFormatter.date(from: lastMessageTimestampString)
                
                let read = results["read"] as! Bool
            
                // Get the other user object
                FirebaseManager.getUser(uid: otherUserUid, completion: { user
                    in
                    
                    // Create the thread object and add it to our list
                    let thread = Thread(with: user, threadId: threadId, lastMessageTimestamp: lastMessageTimestamp!, read: read)
                    ThreadManager.add(thread: thread)
                    completion()
                })
            }
        })
    }
}
