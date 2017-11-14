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
    
    static func addPost(username:String, text:String, toId:String, fromId:String) {
        if (text != "") {
            let chatName = getChatName(fromId: fromId, toId: toId)
            let post = ["uid":fromId,
                        "username":username,
                        "text":text,
                        "toId":toId]
            databaseRef.child("posts").child(chatName).childByAutoId().setValue(post)
        }
    }
    
    static func fillPosts(uid:String?, toId:String, completion: @escaping(_ result:String) -> Void) {
        messages = [JSQMessage]()
        let chatName = getChatName(fromId: uid!, toId: toId)
        
        databaseRef.child("posts").child(chatName).observe(.childAdded, with:{
            snapshot in
            print(snapshot)
            if let result = snapshot.value as? [String:AnyObject]{
                let message = JSQMessage(senderId: result["uid"]! as! String,
                                         displayName: result["username"]! as! String,
                                         text: result["text"]! as! String)
                PostManager.messages.append(message!)
            }
            completion("")
        })
    }
    
    private static func getChatName(fromId:String, toId:String) -> String {
        // The chat name is what groups chats between two people together.
        // The name is the alphabetical string "fromId - toId" or "toId - fromId"
        if (fromId < toId) {
            return fromId + " - " + toId
        }
        return toId + " - " + fromId
    }
}
