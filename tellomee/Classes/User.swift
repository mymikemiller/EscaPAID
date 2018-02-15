//
//  User.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class User: NSObject {
    var uid:String
    var city:String
    var email:String
    var phone:String
    var displayName:String
    var profileImageUrl:String
    var aboutMe:String
    
    init(uid:String, city:String, email:String, displayName:String, phone:String, aboutMe:String, profileImageUrl:String) {
        self.uid = uid
        self.city = city
        self.displayName = displayName
        self.email = email
        self.phone = phone
        self.aboutMe = aboutMe
        self.profileImageUrl = profileImageUrl
    }
    
    func getProfileImage() -> UIImage {
        if let url = NSURL(string: profileImageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                return UIImage(data: data as Data)!
            }
        }
        return #imageLiteral(resourceName: "profile")
    }
    
    func updateProfileImageUrl(_ url:String) {
        
        profileImageUrl = url
        
        // Immediately save it to the database
        FirebaseManager.databaseRef.child("users").child(self.uid).updateChildValues(["profileImageUrl":url])
    }
    
    func addFCMToken(token: String) {
        FirebaseManager.databaseRef.child("users").child(self.uid).child("notificationTokens").child(token).setValue(true)
    }
    
    func update() {
        FirebaseManager.databaseRef.child("users").child(self.uid).updateChildValues([
            "city":city,
            "displayName":displayName,
            "phone":phone,
            "aboutMe":aboutMe,
            "profileImageUrl":profileImageUrl])
    }
}
