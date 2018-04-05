//
//  ThreadManager.swift
//  EscaPAID
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
    
    // Store a dictionary of callback lists to inform when a thread is created. Key the dictionary on the uid for who the created/retrieved thread. Clear that thread's list after calling all callbacks.
    static var getOrCreateThreadCompletions: [String:[(Thread) -> ()]] = [:]
    
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
    
    static func getOrCreateThread(with curator:User, completion: @escaping (Thread) -> ()) {
        
        print("getOrCreateThread with " + curator.uid)
        // Append the completion to the list of completions to call when we actually find or create the thread
        // We have to get the array out, then append to it because Swift doesn't let us modify it until Swift 5. See
        // https://stackoverflow.com/questions/24534229/swift-modifying-arrays-inside-dictionaries
        if var completionsToCall = getOrCreateThreadCompletions[curator.uid] {
            completionsToCall.append(completion)
            getOrCreateThreadCompletions[curator.uid] = completionsToCall
            
            // Exit early from any attempt to find/create the second, third, etc. time. We've already added it to the list, so its completion will be called once we get/create the thread
            if (completionsToCall.count > 1) {
                return
            }
        } else {
            getOrCreateThreadCompletions[curator.uid] = [completion]
        }
        
        let myUid = FirebaseManager.user!.uid
        
        if (myUid == curator.uid) {
            fatalError("Cannot create a thread with self")
        }
        
        // Try to find a thread that exists. Look in the user's threads and see if any thread exists that contains the curator as the other user
        databaseRef.child("userThreads").child(myUid).queryOrdered(byChild: "with").queryEqual(toValue: curator.uid).observeSingleEvent(of: .value) {
            (snap) in
            
            var threadId:String? = nil
            
            // The query should return 0 or 1 threads
            if (snap.childrenCount > 1) {
                fatalError("Found multiple userThreads to the same user")
            }
            if (snap.childrenCount == 1) {
                let userThreads = snap.value as! [String:AnyObject]
                // Get the first thread (there should be only 1)
                threadId = userThreads.keys[userThreads.keys.startIndex]
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
            
                let threadRef = databaseRef.child("userThreads").child(myUid).childByAutoId()
                
                threadRef.setValue(newThread)
                threadId = threadRef.key
                print("created thread", threadId!, "in user", myUid)
                
                // Also add the same threadId (unread) to the curator's userThreads so the thread appears in their inbox
                newThread["with"] = myUid
                newThread["read"] = false
                databaseRef.child("userThreads").child(curator.uid).child(threadId!).setValue(newThread)
                
                print("set value on curator " + curator.uid + " for thread " + threadId!)
            }
            
            let thread = Thread(with: curator, threadId: threadId!, lastMessageTimestamp: Date(), read: true)
            
            // Finally, call the completions we have queued up
            if let completions = getOrCreateThreadCompletions[curator.uid] {
                for completionToCall in completions {
                    completionToCall(thread)
                }
                // Now clear out the completions list to prepare for next time
                getOrCreateThreadCompletions.removeValue(forKey: curator.uid)
            }
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
