//
//  ThreadsNavigationController.swift
//  tellomee
//
//  Created by Michael Miller on 11/24/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ThreadsNavigationController: UINavigationController {
    
    var threadToShowOnLoad:Thread?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If we have a thread set, go directly to that thread
        if (threadToShowOnLoad != nil) {
            (viewControllers.first as! ThreadsTableVC).startChat(thread: threadToShowOnLoad!)
            
            // Clear the thread to show so we don't go there automatically next time we appear
            threadToShowOnLoad = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
