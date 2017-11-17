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
    
    static var users = [User]()
    
    static func getCurrentUser(uid:String) -> User? {
        if let i = users.index(where: {$0.uid == uid}) {
            return users[i]
        }
        return nil
    }
    
    static func fillUsers(completion: @escaping () -> Void) {
        ProfileManager.users = [User]()
        databaseRef.child("users").observe(.childAdded, with: {
            snapshot in
            print(snapshot)
            if let result = snapshot.value as? [String:AnyObject] {
                let uid = result["uid"]! as! String
                let email = result["email"]! as! String
                let displayName = result["displayName"]! as! String
                let phone = result["phone"]! as! String
                let profileImageUrl = result["profileImageUrl"]! as! String
                
                let u = User(uid: uid, email: email, displayName: displayName, phone: phone, profileImageUrl: profileImageUrl)
                ProfileManager.users.append(u)
                completion()
            }
        })
    }
}
