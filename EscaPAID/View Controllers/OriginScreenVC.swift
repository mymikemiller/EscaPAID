//
//  LaunchScreenViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/15/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class OriginScreenVC: UIViewController {
    
    @IBOutlet weak var introTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        introTextLabel.text = Config.current.introText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (Constants.autoLogin) {
            performSegue(withIdentifier: "origin_login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin_click(_ sender: Any) {
        FirebaseManager.logInWithFacebook(from: self) { (success:Bool) in
            if (success) {
                self.performSegue(withIdentifier: "origin_facebook_showApp", sender: sender)
            }
        }
    }
}
