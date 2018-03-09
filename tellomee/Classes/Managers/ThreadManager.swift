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
    static let THREAD_UPDATED = "THREAD_UPDATED"
    
    var threads = [Thread]()
    
    var observeHandle: DatabaseHandle?
    
    override init() {
        super.init()
        
        // Listen for internal broadcast notifications specifying that the user tapped on a push notification specifying they got a new message
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onThreadUpdated(notification:)),
                                               name: Notification.Name(rawValue: ThreadManager.THREAD_UPDATED),
                                               object: nil)
    }
    
    @objc func onThreadUpdated(notification: Notification) {
        let threadId = (notification.object as! [String : String])["threadId"]!
        bump(threadId: threadId)
    }

    
    // Add a thread and keep them sorted in descending order by timestamp of last message
    func add(thread:Thread) {
        threads.append(thread)
        threads.sort { (one, two) -> Bool in
            one.lastMessageTimestamp > two.lastMessageTimestamp
        }
    }
    
    // Bump up the specified thread to the front of the list
    func bump(threadId:String) {
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
    
    func fillThreads(onThreadUpdate: @escaping (Thread) -> Void, completion: @escaping () -> Void) {
        let currentUid = FirebaseManager.user?.uid
        
        // Empty the thread list
        threads = [Thread]()
        
        // Get the current user's threads
        observeHandle = ThreadManager.databaseRef.child("userThreads").queryOrderedByKey().queryEqual(toValue: currentUid).observe(DataEventType.value, with: {
            userThreadsSnapshot in
            
            // If the user has a thread...
            if (userThreadsSnapshot.hasChildren()) {
                // ...there should be only one user thread with the specified id so we use nextObject to get the first (only)
                let item = userThreadsSnapshot.children.nextObject() as! DataSnapshot
                for threadChild in item.children {
                    let threadSnapshot = threadChild as! DataSnapshot
                    let threadId = threadSnapshot.key
                    let values = threadSnapshot.value as! [String:AnyObject]
                    
                    // If there's no "with" in the database, check that the user wasn't somehow able to send a message to himself and went in to the chat and called Thread.setRead
                    let otherUserId = values["with"] as! String

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let lastMessageTimestampString = values["lastMessageTimestamp"] as! String
                    let lastMessageTimestamp = dateFormatter.date(from: lastMessageTimestampString)

                    let read = values["read"] as! Bool
                    
                    // See if we already have the thread object
                    let thread = self.threads.first(where:{$0.threadId == threadId})
                    
                    if (thread != nil) {
                        thread!.read = read
                        // We already have the thread in our list. Bump it to the top if it's not read.
                        if (!read) {
                            self.bump(threadId: threadId)
                            completion()
                        }
                    } else {
                        // Get the other user object so we can create and add the thread object to our array
                        FirebaseManager.getUser(uid: otherUserId, completion: { user
                            in
                            
                            guard let user = user else {
                                print("Error filling threads. No user at the specified uid: /\(otherUserId)")
                                return
                            }
                            
                            // Create the thread object and add it to our list
                            let thread = Thread(with: user, threadId: threadId, lastMessageTimestamp: lastMessageTimestamp!, read: read)
                            self.add(thread: thread)
                            
                            completion()
                        })
                    }
                }
            }
        })
    }
    
    
    func removeObserver() {
        if observeHandle != nil {
            ThreadManager.databaseRef.child("userThreads").child(FirebaseManager.user!.uid).removeObserver(withHandle: observeHandle!)
        }
    }
}
