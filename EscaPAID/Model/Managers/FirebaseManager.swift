//
//  FIrebaseManager.swift
//  EscaPAID
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
    static var user:User? = nil
    static var currentFirebaseUser:FirebaseAuth.User? = nil
    
    // The result of attempting to log in with email
    enum EmailLogInResult {
        case Success
        case Error  
        case EmailNotVerified
    }
    
    // The result of attempting to initialize the User
    enum InitializationResult {
        case Success
        case Error
    }
    
    static func sendVerificationEmail() {
        if (currentFirebaseUser == nil) {
            assertionFailure("Unable to send verification email. User is nil.")
        }
        currentFirebaseUser?.sendEmailVerification(completion: nil)
    }
    
    static func sendPasswordResetEmail(to email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    static func logInWithEmail(email:String, password:String, completion:
        @escaping (_ result:EmailLogInResult) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completion(EmailLogInResult.Error)
            } else {
                if let firebaseUser = result?.user {
                    
                    if (firebaseUser.isEmailVerified) {
                        print ("Email verified. Signing in...")
                        
                        initializeUser(firebaseUser: firebaseUser, completion: { (result) in
                            
                            switch result {
                            case InitializationResult.Success:
                                completion(EmailLogInResult.Success)
                            default:
                                completion(EmailLogInResult.Error)
                            }
                        })
                    } else {
                        completion(EmailLogInResult.EmailNotVerified)
                    }
                }
            }
        })
    }
    
    static func initializeUser(firebaseUser: FirebaseAuth.User, completion: @escaping (InitializationResult) -> Void) {
        // Store the firebase user
        currentFirebaseUser = firebaseUser
        
        // Get and store the User object
        getUser(uid: firebaseUser.uid, completion: { (user) in
            
            if let user = user {
                //Save the logged in user
                self.user = user
                
                completion(InitializationResult.Success)
            } else {
                print("No user information found for \(firebaseUser.uid)")
                completion(InitializationResult.Error)
            }
            
        })

    }
    
    static func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    static func createAccountWithEmail(email:String, firstName:String, lastName:String, password:String, completion: @escaping(String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (result, error) in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            
            // Send the verification email. We'll need to verify it before logging in fully.
            result?.user.sendEmailVerification(completion: nil)
            
            // Add the user to our database (even if they're not verified) so we can associate information with the user.
            addUser(email: email, firstName: firstName, lastName: lastName, profileImageUrl: "") {user in
                
                guard (user != nil) else {
                    // Couldn't create the user. The server may be down.
                    completion("Error creating user")
                    return
                }
                
                print("user added")
                
                completion(nil)
            }
        })
    }
    
    static func addUser(email:String, firstName: String,  lastName: String, profileImageUrl:String, completion: @escaping (_ user:User?) -> Void) {
        let uid = Auth.auth().currentUser?.uid
        let displayName = firstName + " " + lastName
        
        // Get the server to create a stripe customer, and set the returned stripeCustomerId
        MainAPIClient.shared.createCustomer(email: email, description: displayName, completion: { (customerId) in
            
            guard (customerId != nil) else {
                // Couldn't create the user (possibly because we can't connect to our server).
                completion(nil)
                return
            }
            
            let newUser = ["uid":uid!,
                           "email":email,
                           "city": "", // Start with a blank city. The user will fill it in later
                           "firstName":firstName,
                           "lastName":lastName,
                           "aboutMe":"",
                           "profileImageUrl":profileImageUrl,
                           "stripeCustomerId": customerId]
            
            databaseRef.child("users").child(uid!).setValue(newUser) { (error, ref) -> Void in
                getUser(uid: uid!, completion: { (user) in
                    if let user = user {
                        completion(user)
                    } else {
                        print("Failed to add user. No user information found for \(uid!)")
                    }
                })
            }
        })
    }
    
    static func getUser(uid:String, completion: @escaping (User?) -> Void) {
        databaseRef.child("users").child(uid).observeSingleEvent(of: DataEventType.value, with: { (snap) in
            
            if (snap.exists()) {
                let value = snap.value as! NSDictionary
                let uid = value["uid"] as! String
                let city = value["city"] as! String
                let email = value["email"] as! String
                let firstName = value["firstName"] as! String
                let lastName = value["lastName"] as! String
                let aboutMe = value["aboutMe"] as! String
                let profileImageUrl = value["profileImageUrl"] as! String
                
                let user = User(uid: uid, city: city, email: email, firstName: firstName, lastName: lastName, aboutMe: aboutMe, profileImageUrl: profileImageUrl)
                
                // Set the stripe ID if we have one (if we're a curator)
                user.stripeCuratorId = value["stripeCuratorId"] as? String
                
                // Set the stripe ID if we have one (we should have one - only for a brief period in customer creation do we not have one)
                user.stripeCustomerId = value["stripeCustomerId"] as? String

                
                completion(user)
            } else {
                completion(nil)
            }
        })
    }
    
    
    
    static func logInWithFacebook(from:UIViewController, completion:
        @escaping (_ success:Bool) -> Void) {
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
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
            Auth.auth().signIn(with: credential, completion: { (firebaseUser, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    from.present(alertController, animated: true, completion: nil)
                    completion(false)
                    return
                }
                
                currentFirebaseUser = firebaseUser
                
                // Split out the first and last name as Facebook only gives us the full name
                let components = (firebaseUser?.displayName)!.components(separatedBy: " ")
                let firstName = components[0]
                let lastName = components.count > 1 ? components[1] : ""
                
                addUser(email: (firebaseUser?.email!)!,
                        firstName: firstName,
                        lastName: lastName,
                        profileImageUrl: (Auth.auth().currentUser?.photoURL?.absoluteString)!) { user in
                            
                            guard (user != nil) else {
                                // Couldn't create the user. The server may be down
                                fatalError("Error creating account")
                                completion(false)
                                return
                            }
                            
                            //Save the logged in user
                            self.user = user
                            
                            completion(true)
                }
            })
        }
    }
}
