//
//  TabBarController.swift
//  tellomee
//
//  Created by Michael Miller on 1/8/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    static var firebaseCloudMessagingToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tell our UITabBarController subclass to handle its own delegate methods
        self.delegate = self
        
        // The user logged in successfully so register the token
        registerFCMToken()
        
        // Listen for internal broadcast notifications specifying that the user tapped on a push notification specifying they got a new message
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showThreadFromNotification(notification:)),
                                               name: Notification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST),
                                               object: nil)
    }
    
    // Registers the current token and unregisters the token of the previously logged in user
    private func registerFCMToken() {
        if let token = TabBarController.firebaseCloudMessagingToken {
            
            let uidKey = "uid"
            let tokenKey = "token"
            
            // Unregister the token for the previous user. We don't do this immediately when we log out because we want to continue sending notifications to that user (even when logged out) until a new user logs in (i.e. until we reach this function)
            let defaults = UserDefaults.standard
            if let uid = defaults.string(forKey: uidKey),
                let token = defaults.string(forKey: tokenKey) {
                
                // Only remove the token if the previous user wasn't the one who just logged in
                if (uid != FirebaseManager.user?.uid) {
                    User.removeFCMToken(uid: uid, token: token)
                }
            }
            
            // Register the new user's token
            FirebaseManager.user?.addFCMToken(token: token)
            
            // Cache the current user so we can unregister if another user logs in
            defaults.set(FirebaseManager.user?.uid, forKey: uidKey)
            defaults.set(token, forKey: tokenKey)
        }
    }
    
    @objc func showThreadFromNotification(notification: Notification) {
        let user = (notification.object as! [String : User])["user"]!
        
        for (index, viewController) in childViewControllers.enumerated() {
            if viewController.isKind(of: ThreadsNavigationController.self){
                // Set the user to show on load because if the ThreadsNavigationController hasn't been loaded yet, it won't be able to respond to the notification itself
                let threadsNavigationController = viewController as! ThreadsNavigationController
                threadsNavigationController.userToShowOnLoad = user
                
                // Switch to the inbox tab
                selectedIndex = index
            }
        }
    }
    
    // called whenever a tab button is tapped
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController is DiscoverVC {
            (viewController as! DiscoverVC).refreshTable()
        }
    }
    
}
