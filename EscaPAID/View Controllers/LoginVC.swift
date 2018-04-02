//
//  LoginViewController.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/15/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var orLogInWIthEmailLabel: UILabel!
    
    var initEmail: String = ""
    var initPassword:String = ""
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orLogInWIthEmailLabel.drawLineOnBothSides(labelWidth: 10, color: UIColor.white)

        // We set initEmail when coming here after creating a new account
        if (!initEmail.isEmpty) { email.text = initEmail }
        if (!initPassword.isEmpty) { password.text = initPassword }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (Constants.autoLogin) {
            // Automatically log the user in
            loginButton_click(self)
        }
    }
    
    @IBAction func facebookLogin_click(_ sender: Any) {
        FirebaseManager.logInWithFacebook(from: self) { (success:Bool) in
            if (success) {
                self.performSegue(withIdentifier: "login_facebook_showApp", sender: sender)
            }
        }
    }

    
    @IBAction func loginButton_click(_ sender: Any) {
        let email = self.email.text!.trimmingCharacters(in: .whitespaces)
        FirebaseManager.logInWithEmail(email: email, password: password.text!) { (result:FirebaseManager.EmailLogInResult) in
            if (result == FirebaseManager.EmailLogInResult.Success) {
                
                // Don't perform segue here, load vc
                self.performSegue(withIdentifier: "login_ShowApp", sender: sender)
                
                
            } else if (result == FirebaseManager.EmailLogInResult.EmailNotVerified) {
                let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(self.email.text ?? "your email")?", preferredStyle: .alert)
                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                    (_) in
                    FirebaseManager.currentFirebaseUser?.sendEmailVerification(completion: nil)
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
    
    @IBAction func mikem_click(_ sender: Any) {
        email.text = "mikem.exe@gmail.com"
        password.text = "testtest"
        loginButton_click(self)
    }
    
    @IBAction func tellomee_a_click(_ sender: Any) {
        email.text = "tellomee.a@gmail.com"
        password.text = "testtest"
        loginButton_click(self)
    }
    
    @IBAction func tellomee_b_click(_ sender: Any) {
        email.text = "tellomee.b@gmail.com"
        password.text = "testtest"
        loginButton_click(self)
    }
    
    @IBAction func escapaid_a_click(_ sender: Any) {
        email.text = "escapaid.a@gmail.com"
        password.text = "testtest"
        loginButton_click(self)
    }
    
    @IBAction func signUpButton_click(_ sender: Any) {
        let createAccountVC: CreateAccountVC = self.storyboard?.instantiateViewController(withIdentifier: "createAccountViewController") as! CreateAccountVC
        self.present(createAccountVC, animated: true, completion: nil)
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
