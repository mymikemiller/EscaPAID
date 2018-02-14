//
//  TabBarController.swift
//  tellomee
//
//  Created by Michael Miller on 1/8/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tell our UITabBarController subclass to handle its own delegate methods
        self.delegate = self
        
        // Listen for internal broadcast notifications specifying that the user tapped on a push notification specifying they got a new message
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showThreadFromNotification(notification:)),
                                               name: Notification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST),
                                               object: nil)
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
