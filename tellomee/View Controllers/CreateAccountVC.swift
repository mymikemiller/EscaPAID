//
//  CreateAccountViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/15/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verifyPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccountButton_click(_ sender: Any) {
        
        if ((name.text?.isEmpty)! || (email.text?.isEmpty)! || (password.text?.isEmpty)!) {
            let alertVC = UIAlertController(title: "Error", message: "Please fill in all required fields.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        if ((password.text?.count)! < 6) {
            let alertVC = UIAlertController(title: "Error", message: "Password must have at least 6 characters.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        if (password.text != verifyPassword.text) {
            let alertVC = UIAlertController(title: "Error", message: "Passwords don't match.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        FirebaseManager.createAccountWithEmail(email: email.text!, phone: phone.text!, displayName: name.text!, password: password.text!) {
            errorString in
            
            DispatchQueue.main.async {
                
                if (errorString != nil) {
                    let alertVC = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
                    alertVC.addAction(alertActionOkay)
                    self.present(alertVC, animated: true, completion: nil)
                    return
                }
                
                // FirebaseManager.createAccountWithEmail sent a verification email. Notify the user that they need to address the email then log in.
                let alertVC = UIAlertController(title: "Verify your email", message: "Please verify your email address to continue.", preferredStyle: .alert)
                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                    (_) in
                    // Send the user a verification email then redirect them to the log in screen
                    self.performSegue(withIdentifier: "create_ShowLogin", sender: sender)
                }
                
                alertVC.addAction(alertActionOkay)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButton_click(_ sender: Any) {
        let originVC: OriginScreenVC = self.storyboard?.instantiateViewController(withIdentifier: "originViewController") as! OriginScreenVC
        // Prevent auto-login or we'll immediately be logged back in
        Constants.autoLogin = false
        self.present(originVC, animated: true, completion: nil)

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "create_ShowLogin") {
            (segue.destination as! LoginVC).initEmail = email.text!
            (segue.destination as! LoginVC).initPassword = password.text!
        }
    }

}
