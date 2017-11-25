//
//  ExperienceVC.swift
//  tellomee
//
//  Created by Michael Miller on 11/23/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceVC: UIViewController {
    
    var experience:Experience?

    @IBOutlet weak var experienceTitle: UILabel!
    
    @IBOutlet weak var curator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let experience = experience {
            experienceTitle.text = experience.title
            curator.text = "By: \(experience.curator.displayName)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func messageButton_click(_ sender: Any) {
        FirebaseManager.getUser(uid: FirebaseManager.currentUserId) { (user) in
    
            ThreadManager.getOrCreateThread(between: user, and: (self.experience?.curator)!, completion: {thread in
                
                let threadsNavigationController: ThreadsNavigationController = self.tabBarController?.viewControllers![2] as! ThreadsNavigationController
                threadsNavigationController.initialThread = thread
                self.tabBarController?.selectedViewController = threadsNavigationController
            })
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
