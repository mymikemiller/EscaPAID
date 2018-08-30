//
//  Experience.swift
//  EscaPAID
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
    var startTime:String
    var endTime:String
    var includes:String
    // Like on Stripe, price is stored in pennies
    var price:Int
    var days:Days
    var maxGuests:Int
    var skillLevel:String
    var experienceDescription:String
    var imageUrls:[String]
    var curator:User
    
    init(id:String,
         title:String,
         category:String,
         city:String,
         startTime:String,
         endTime:String,
         includes:String,
         price:Int,
         days:Days,
         maxGuests:Int,
         skillLevel:String,
         description:String,
         imageUrls:[String],
         curator:User) {
        
        self.id = id
        self.title = title
        self.category = category
        self.city = city
        self.startTime = startTime
        self.endTime = endTime
        self.includes = includes
        self.price = price
        self.days = days
        self.maxGuests = maxGuests
        self.skillLevel = skillLevel
        self.experienceDescription = description
        self.imageUrls = imageUrls
        self.curator = curator
    }
    
    static func createNewExperience() -> Experience {
        let newRef = FirebaseManager.databaseRef.child("experiences").childByAutoId()
        newRef.child("title").setValue("")
        return Experience(id: newRef.key,
                          title: "",
                          category: Config.current.categories[0],
                          city: (FirebaseManager.user?.city)!,
                          startTime: "7:00 PM",
                          endTime: "8:00 PM",
                          includes: "",
                          price: 0,
                          days: Days.All,
                          maxGuests: 1,
                          skillLevel: Constants.skillLevels[0],                          description: "",
                          imageUrls: [],
                          curator: FirebaseManager.user!)
    }
    
    // An Experience is "active" if it has any available days for booking
    func isActive() -> Bool {
        return days.Monday || days.Tuesday || days.Wednesday || days.Thursday || days.Friday || days.Saturday || days.Sunday;
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
        
        let daysDict = ["monday": days.Monday,
                        "tuesday": days.Tuesday,
                        "wednesday": days.Wednesday,
                        "thursday": days.Thursday,
                        "friday": days.Friday,
                        "saturday": days.Saturday,
                        "sunday": days.Sunday]
        
        FirebaseManager.databaseRef.child("experiences").child(id).updateChildValues([
            "title":title,
            "category":category,
            "city": city,
            "days": daysDict,
            "startTime": startTime,
            "endTime": endTime,
            "maxGuests": maxGuests,
            "skillLevel": skillLevel,
            "includes":includes,
            "price":price,
            "description":experienceDescription,
            "images":imageUrls,
            "uid":curator.uid])
        
    }
}

