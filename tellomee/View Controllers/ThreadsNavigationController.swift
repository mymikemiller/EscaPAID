//
//  ThreadsNavigationController.swift
//  tellomee
//
//  Created by Michael Miller on 11/24/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ThreadsNavigationController: UINavigationController {
    
    var initialThread:Thread?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (initialThread != nil) {
            (viewControllers.first as! ThreadsTableVC).startChat(thread: initialThread!)
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
