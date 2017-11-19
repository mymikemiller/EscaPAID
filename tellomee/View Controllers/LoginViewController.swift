//
//  LoginViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/15/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var initEmail: String = ""
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // We set initEmail when coming here after creating a new account
        if (!initEmail.isEmpty) { email.text = initEmail }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton_click(_ sender: Any) {
        FirebaseManager.logInWithEmail(email: email.text!, password: password.text!) { (result:FirebaseManager.EmailLogInResult) in
            if (result == FirebaseManager.EmailLogInResult.Success) {
                self.performSegue(withIdentifier: "login_ShowProfile", sender: sender)
            } else if (result == FirebaseManager.EmailLogInResult.EmailNotVerified) {
                let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(self.email.text ?? "your email")?", preferredStyle: .alert)
                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                    (_) in
                    FirebaseManager.currentUser?.sendEmailVerification(completion: nil)
                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertVC.addAction(alertActionCancel)
                alertVC.addAction(alertActionOkay)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                // Either the user put in the wrong password, or they signed up using facebook and are now trying to log in with a password (which was never set up)
                let alertVC = UIAlertController(title: "Log in error", message: "Check that your password is correct and that you're using the correct log in method.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
