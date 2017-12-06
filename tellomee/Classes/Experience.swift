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
    
    func addImageUrl(_ url:String) {
        imageUrls.append(url)
        updateImageUrls()
    }
    
    func removeImageUrl(_ url:String) {
        if let index = imageUrls.index(of: url) {
            imageUrls.remove(at: index)
            updateImageUrls()
        }
    }
    
    private func updateImageUrls() {
        FirebaseManager.databaseRef.child("experiences").child(self.id).updateChildValues(["images":imageUrls])
    }
    
    func save() {
        FirebaseManager.databaseRef.child("experiences").child(id).updateChildValues([
            "title":title,
            "includes":includes,
            "description":experienceDescription,
            "images":imageUrls])
    }
}

