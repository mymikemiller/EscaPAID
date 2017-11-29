//
//  Experience.swift
//  tellomee
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class Experience: NSObject {
    
    var id:String
    var title:String
    var includes:String
    var experienceDescription:String
    var imageUrls:[String]
    var curator:User
    
    var uiImages: [UIImage] {
        var uiImages = [UIImage]()
        for imageUrlString in imageUrls {
            if let url = NSURL(string: imageUrlString) {
                if let data = NSData(contentsOf: url as URL) {
                    // TODO: What if the data is not an image or the URL isn't valid?
                    let uiImage = UIImage(data: data as Data)
                    uiImages.append(uiImage!)
                }
            }
        }
        return uiImages
    }
    
    init(id:String,
         title:String,
         includes:String,
         description:String,
         imageUrls:[String],
         curator:User) {
        
        self.id = id
        self.title = title
        self.includes = includes
        self.experienceDescription = description
        self.imageUrls = imageUrls
        self.curator = curator
    }
    
    
    func save() {
        FirebaseManager.databaseRef.child("experiences").child(id).updateChildValues([
            "title":title,
            "includes":includes,
            "description":experienceDescription,
            "images":imageUrls])
    }
}

