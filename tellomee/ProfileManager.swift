//
//  ProfileManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ProfileManager: NSObject {
    static let databaseRef = Database.database().reference()
    static let uid = Auth.auth().currentUser?.uid
    
    static var users = [TellomeeUser]()
    
    static func getCurrentUser(uid:String) -> TellomeeUser? {
        if let i = users.index(where: {$0.uid == uid}) {
            return users[i]
        }
        return nil
    }
    
    static func fillUsers(completion: @escaping () -> Void) {
        databaseRef.child("users").observe(.childAdded, with: {
            snapshot in
            print(snapshot)
            if let result = snapshot.value as? [String:AnyObject] {
                let uid = result["uid"]! as! String
                let username = result["username"]! as! String
                let email = result["email"]! as! String
                let profileImageUrl = result["profileImageUrl"]! as! String
                
                let u = TellomeeUser(uid: uid, username: username, email: email, profileImageUrl: profileImageUrl)
                ProfileManager.users.append(u)
                completion()
            }
        })
    }
}
