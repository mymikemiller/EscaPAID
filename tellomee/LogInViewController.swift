//
//  ViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/10/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Log in immediately as test1
//        loginButton_click("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButton_click(_ sender: Any) {
        FirebaseManager.logInWithEmail(email: email.text!, password: password.text!) { (success:Bool) in
            if (success) {
                self.performSegue(withIdentifier: "showProfile", sender: sender)
            }
        }
    }
    
    @IBAction func createAccountButton_click(_ sender: Any) {
        FirebaseManager.createAccountWithEmail(email: email.text!, password: password.text!, username: username.text!) {
            (result:String) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showProfile", sender: sender)
            }
        }
        
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        FirebaseManager.logInWithFacebook(from: self) { (success:Bool) in
            if (success) {
                self.performSegue(withIdentifier: "showProfile", sender: sender)
                
                // Present the main view (or do it the above way)
                //                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                //                    UIApplication.shared.keyWindow?.rootViewController = viewController
                //                    self.dismiss(animated: true, completion: nil)
                //                }
            }
        }
        
        
    }
    
}

