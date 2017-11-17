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
    var uid:String
    var email:String
    var phone:String
    var displayName:String
    var profileImageUrl:String
    
    init(uid:String, email:String, displayName:String, phone:String, profileImageUrl:String) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.phone = phone
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
                        self.profileImageUrl = downloadUrl
                    FirebaseManager.databaseRef.child("users").child(self.uid).updateChildValues(["profileImageUrl":downloadUrl])
                    }
                }
            }
        }
    }
}
