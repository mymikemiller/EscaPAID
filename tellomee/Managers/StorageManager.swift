//  StoragaeManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/30/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

import FirebaseStorage

class StorageManager: NSObject {
    
    static func storeImage(folder:String, image:UIImage, completion: @escaping (String) -> Void) {
        let imageRef = Storage.storage().reference().child(folder).child("\(NSUUID().uuidString).jpg")
        if let imageData = UIImageJPEGRepresentation(image, 0.25) {
            imageRef.putData(imageData, metadata:nil) {
                metadata, error in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                } else {
                    print(metadata)
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString {
                        
                        completion(downloadUrl)
                    }
                }
            }
        }
    }
}

