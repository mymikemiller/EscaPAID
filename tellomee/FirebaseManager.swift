//
//  FIrebaseManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager: NSObject {
    static let databaseRef = Database.database().reference()
    static var currentUserId = ""
    static var currentUser:User? = nil
    
    
    static func LogIn(email:String, password:String, completion:
        @escaping (_ success:Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                currentUser = user
                currentUserId = (user?.uid)!
                completion(true)
            }
        })
    }
    
    static func CreateAccount(email:String, password:String, username:String, completion: @escaping(_ result:String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            AddUser(username: username, email: email)
            
            LogIn(email: email, password: password) {
                (success:Bool) in
                if (success) {
                    print ("login successful after account creation")
                } else {
                    print ("login unsuccessful after account creation")
                }
            }
            completion("")
        })
    }
    
    static func AddUser(username: String, email:String) {
        let uid = Auth.auth().currentUser?.uid
        let post = ["uid":uid!,
                    "username":username,
                    "email":email,
                    "profileImageUrl":""]
        
        databaseRef.child("users").child(uid!).setValue(post)
    }
    
    
}
