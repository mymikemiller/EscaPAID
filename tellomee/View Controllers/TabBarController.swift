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
    }
    
    // called whenever a tab button is tapped
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController is DiscoverVC {
            (viewController as! DiscoverVC).refreshTable()
        }
    }
}
