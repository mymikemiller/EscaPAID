//
//  LaunchScreenViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/15/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import FirebaseAuth

class OriginScreenVC: UIViewController {
    
    @IBOutlet weak var introTextLabel: UILabel!
    
    @IBOutlet weak var whenUsingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        introTextLabel.text = Config.current.introText
        
        whenUsingLabel.text = "When using " + Config.current.appName + " you accept our"
        
        // Handle the case when the user is already logged in when launching the app
        Auth.auth().addStateDidChangeListener() { auth, user in
            
            guard user != nil else { return }
            
            print("Already logged in. Initializing.");
            
            FirebaseManager.initializeUser(firebaseUser: user!, completion: { (result) in
                if (result == FirebaseManager.InitializationResult.Success) {
                    
                    print("Got success");
                    
                    self.performSegue(withIdentifier: "origin_already_logged_in_showApp", sender: nil)
                } else {
                    // We failed to log in. Do nothing. The user will have to log in again.
                }
            })
        }
    }
    
    @IBAction func termsButton_click(_ sender: Any) {
        if let url = URL(string: Config.current.termsLink) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func privacyButton_click(_ sender: Any) {
        if let url = URL(string: Config.current.privacyLink) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func facebookLogin_click(_ sender: Any) {
        FirebaseManager.logInWithFacebook(from: self) { (success:Bool) in
            if (success) {
                self.performSegue(withIdentifier: "origin_facebook_showApp", sender: sender)
            }
        }
    }
}


