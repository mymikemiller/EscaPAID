//  StoragaeManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/30/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

import FirebaseStorage

class StorageManager: NSObject {
    
    static func storeImage(folder:String, image:UIImage, completion: @escaping (String) -> Void) -> StorageUploadTask? {
        let imageRef = Storage.storage().reference().child(folder).child("\(NSUUID().uuidString).jpg")
        if let imageData = UIImageJPEGRepresentation(image, 0.25) {
            return imageRef.putData(imageData, metadata:nil) {
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
        return nil
    }
    
    static func removeImageFromStorage(folder:String, imageUrl:String) {
        // Remove the .jpg from the file name
        let url = imageUrl.prefix(imageUrl.count - 3)
        
        print(url)
        
        let start = imageUrl.range(of: "profileImages%2F")?.upperBound
        let end = imageUrl.range(of: ".jpg")?.upperBound
        let range = Range(uncheckedBounds: (lower: start!, upper: end!))
        let imageName = String(imageUrl[range])
        
        print("Deleting " + imageName)
        Storage.storage().reference().child(folder).child(imageName).delete() {
            error in
            
            if let error = error {
                print("There was an error deleting an image from storage.")
                print(error)
            }
        }
    }
}

