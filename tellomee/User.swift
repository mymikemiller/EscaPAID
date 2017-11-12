//
//  User.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import FirebaseStorage

class User: NSObject {
    var username:String
    var email:String
    var uid:String
    var profileImageUrl:String
    
    init(uid:String, username:String, email:String, profileImageUrl:String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        
    }
    
    func getProfileImage() -> UIImage {
        if let url = NSURL(string: profileImageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                return UIImage(data: data as Data)!
            }
        }
        return UIImage()
    }

    func uploadProfilelPhoto(profileImage:UIImage) {
        let profileImageRef = Storage.storage().reference().child("profileImages").child("\(NSUUID().uuidString).jpg")
        if let imageData = UIImageJPEGRepresentation(profileImage, 0.25) {
            profileImageRef.putData(imageData, metadata:nil) {
                metadata, error in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                } else {
                    print(metadata)
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString {
                        if (self.profileImageUrl == "") {
                            self.profileImageUrl = downloadUrl
                        FirebaseManager.databaseRef.child("users").child(self.uid).updateChildValues(["profileImageUrl":downloadUrl])
                        }
                    }
                }
            }
        }
    }
}
