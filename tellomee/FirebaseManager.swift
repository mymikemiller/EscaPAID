//
//  FIrebaseManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit

class FirebaseManager: NSObject {
    static let databaseRef = Database.database().reference()
    static var currentUserId = ""
    static var currentUser:FirebaseAuth.User? = nil
    
    enum EmailLogInResult {
        case Success
        case Error
        case EmailNotVerified
    }
    
    static func sendVerificationEmail() {
        if (currentUser == nil) {
            assertionFailure("Unable to send verification email. User is nil.")
        }
        currentUser?.sendEmailVerification(completion: nil)
    }
    
    static func logInWithEmail(email:String, password:String, completion:
        @escaping (_ result:EmailLogInResult) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(EmailLogInResult.Error)
            } else {
                if let user = user {
                    currentUser = user
                    currentUserId = user.uid
                    if (user.isEmailVerified) {
                        print ("Email verified. Signing in...")
                        completion(EmailLogInResult.Success)
                    } else {
                        completion(EmailLogInResult.EmailNotVerified)
                    }
                }
            }
        })
    }
    
    static func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    static func createAccountWithEmail(email:String, phone:String, displayName:String, password:String, completion: @escaping() -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Send the verification email. We'll need to verify it before logging in fully.
            user?.sendEmailVerification(completion: nil)
            
            // Add the user to our database (even if they're not verified) so we can associate information with the user.
            addUser(email: email, phone: phone, displayName: displayName, profileImageUrl: "")
            
            completion()
        })
    }
    
    static func addUser(email:String, phone:String, displayName: String, profileImageUrl:String) {
        let uid = Auth.auth().currentUser?.uid
        let post = ["uid":uid!,
                    "email":email,
                    "phone":phone,
                    "displayName":displayName,
                    "profileImageUrl":profileImageUrl]
        
        databaseRef.child("users").child(uid!).setValue(post)
    }
    
    
    
    static func logInWithFacebook(from:UIViewController, completion:
        @escaping (_ success:Bool) -> Void) {
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: from) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    from.present(alertController, animated: true, completion: nil)
                    completion(false)
                    return
                }
                
                currentUser = user
                currentUserId = user!.uid
                
                let phone = user?.phoneNumber ?? ""
                
                addUser(email: (user?.email!)!,
                        phone: phone,
                        displayName: (user?.displayName!)!,
                        profileImageUrl: (Auth.auth().currentUser?.photoURL?.absoluteString)!)
                completion(true)
                
            })
        }
    }
}
