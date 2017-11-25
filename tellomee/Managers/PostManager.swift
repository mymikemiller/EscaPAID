//
//  PostManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import JSQMessagesViewController

class PostManager: NSObject {
    static let databaseRef = Database.database().reference()
    static var messages = [JSQMessage]()
    static var observeHandle: DatabaseHandle? = nil
    
    static func addPost(threadId:String, text:String, toId:String, fromId:String) {
        if (text != "") {
            // Store the timestamp (todo: or somehow use Firebase.ServerValue.timestamp())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            
            let post = ["fromId":fromId,
                        "toId":toId,
                        "timestamp":dateString,
                        "text":text]
            
            // Add the thread post
            databaseRef.child("threadPosts").child(threadId).childByAutoId().setValue(post)
        }
    }
    
    static func fillPosts(uid:String?, toId:String, threadId:String, completion: @escaping(_ result:String) -> Void) {
        messages = [JSQMessage]()
        
        if (uid == toId) {
            // Users can't send messages to themselves
            completion("")
            return
        }
        
        // If we've previously registered an observer, remove it so we don't end up with duplicate messages showing up
        if (observeHandle != nil) {
            databaseRef.child("threadPosts").child(threadId).removeObserver(withHandle: observeHandle!)
        }
        observeHandle = databaseRef.child("threadPosts").child(threadId).observe(.childAdded, with:{
            snapshot in
            
            if let result = snapshot.value as? [String:AnyObject]{
                // Add the message to our message list
                let message = JSQMessage(senderId: result["fromId"]! as! String,
                                         displayName: "", // We don't display the display name, so we don't need one
                                         text: result["text"]! as! String)
                messages.append(message!)
                
                // Also bump up the thread in our thread list
                ThreadManager.bump(threadId: threadId)
            }
            completion("")
        })
    }
    
    static func clearPosts() {
        messages = [JSQMessage]()
    }
    
//    static func getMostRecentMessageDate(fromId:String, toId:String) -> Date {
//        let chatName = getChatName(fromId: fromId, toId: toId)
//        let lastItemQuery = databaseRef.child("posts").child(chatName).queryOrderedByKey().queryLimited(toLast: 1)
//
//        lastItemQuery.observeSingleEvent(of: DataEventType.childAdded) { (snapshot) in
//            print(snapshot)
//        }
//        return Date()
//    }
}
