//
//  CreateAccountViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/15/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccountButton_click(_ sender: Any) {
        FirebaseManager.createAccountWithEmail(email: email.text!, password: password.text!, username: username.text!) {
            DispatchQueue.main.async {
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "create_ShowLogin") {
            (segue.destination as! LoginViewController).initEmail = email.text!
        }
    }

}
