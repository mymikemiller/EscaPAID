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
    var photoUrl:String = ""
    var curator:User
    
    init(id:String,
         title:String,
         includes:String,
         description:String,
         curator:User) {
        
        self.id = id
        self.title = title
        self.includes = includes
        self.experienceDescription = description
        self.curator = curator
    }
    
    func save() {
        FirebaseManager.databaseRef.child("experiences").child(id).updateChildValues([
            "title":title,
            "includes":includes,
            "description":experienceDescription,
            "photoUrl":photoUrl])
    }
}

