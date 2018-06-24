//
//  Config.swift
//  EscaPAID
//
//  Created by Michael Miller on 3/14/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

class Config {

    // Configure the app based on the target. Look in the main.infoDictionary in the Supporting Files folder (which will be {AppName Dev/Prod}-Info.plist) for the Configuration property (which should match the app name). This will be a key for a dictionary in Configuration.plist with all the app-specific values such as server addresses.

    static let current = Config(dictionary: NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Configuration", ofType: "plist")!)?[Bundle.main.infoDictionary!["Configuration"]] as! NSDictionary)

    private let dictionary: NSDictionary

    private init(dictionary: NSDictionary) {
        self.dictionary = dictionary
    }
    
    // Config variables that depend on the production / development
    
    // "production" or "development"
    static var stage: String {
        return Bundle.main.infoDictionary!["Stage"] as! String
    }
    
    static var databasePrefix: String {
        return (stage.lowercased() == "production") ? "prod" : "dev";
    }
    
    // Config variables that depend on the target (they are defined in Configuration.plist) but also depend on the stage
    
    var stripeClientId: String { return dictionary.value(forKey: (Config.stage.lowercased() == "production") ? "Stripe Client Id" : "Stripe Test Client Id") as! String }
    
    
    // Config variables defined in Configuration.plist (i.e. they depend on the target and not the stage).
    
    var appName: String { return dictionary.value(forKey: "App Name") as! String }
    
    var stripeCompanyName: String { return dictionary.value(forKey: "Stripe Company Name") as! String }
    
    var stripePublishableKey: String { return dictionary.value(forKey: "Stripe Publishable Key") as! String }
    
    var feePercent: Double { return dictionary.value(forKey: "Fee Percent") as! Double }
    
    var serverURL: String { return dictionary.value(forKey: "Server URL") as! String }
    
    var categories: [String] { return dictionary.value(forKey:"Categories") as! [String] }
    
    var gradientStartColor: UIColor {
        let hex = dictionary.value(forKey:"Gradient Start Color") as! String
        return UIColor(hexString: hex)! }
    
    var gradientEndColor: UIColor {
        let hex = dictionary.value(forKey:"Gradient End Color") as! String
        return UIColor(hexString: hex)! }

    var introText: String { return dictionary.value(forKey: "Intro Text") as! String }
    
    var experienceText: String { return dictionary.value(forKey: "Experience Text") as! String }
    
    var experiencesText: String { return dictionary.value(forKey: "Experiences Text") as! String }
    
    var curatorText: String { return dictionary.value(forKey: "Curator Text") as! String }
    
    var curatorArticle: String { return dictionary.value(forKey: "Curator Article") as! String }
    
    var mainColor: UIColor {
        let hex = dictionary.value(forKey:"Main Color") as! String
        return UIColor(hexString: hex)! }
}
