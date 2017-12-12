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
    var category:String
    var city:String
    var includes:String
    var experienceDescription:String
    var imageUrls:[String]
    var curator:User
    
    init(id:String,
         title:String,
         category:String,
         city:String,
         includes:String,
         description:String,
         imageUrls:[String],
         curator:User) {
        
        self.id = id
        self.title = title
        self.category = category
        self.city = city
        self.includes = includes
        self.experienceDescription = description
        self.imageUrls = imageUrls
        self.curator = curator
    }
    
    static func createNewExperience() -> Experience {
        let newRef = FirebaseManager.databaseRef.child("experiences").childByAutoId()
        newRef.child("title").setValue("")
        return Experience(id: newRef.key,
                          title: "",
                          category: "",
                          city: (FirebaseManager.user?.city)!,
                          includes: "",
                          description: "",
                          imageUrls: [],
                          curator: FirebaseManager.user!)
    }
    
    func deleteSelf() {
        FirebaseManager.databaseRef.child("experiences").child(id).removeValue()
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
            "category":category,
            "city": city,
            "includes":includes,
            "description":experienceDescription,
            "images":imageUrls])
    }
    
    
}

