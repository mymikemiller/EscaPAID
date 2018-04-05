//
//  ThreadsNavigationController.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/24/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ThreadsNavigationController: UINavigationController {
    
    var userToShowOnLoad:User?
    
    static let SHOW_THREAD_POST = "ShowThreadPost"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for internal broadcast notifications specifying that the user tapped on a push notification specifying they got a new message
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showThreadFromNotification(notification:)),
                                               name: Notification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST),
                                               object: nil)
        
        // If we have a user set, go directly to that thread
        if let userToShowOnLoad = userToShowOnLoad {
            goToMessageThread(user: userToShowOnLoad)
        }
    }
    
    @objc func showThreadFromNotification(notification: Notification) {
        let user = (notification.object as! [String : User])["user"]!
        self.goToMessageThread(user: user)
    }
    
    private func goToMessageThread(user: User) {
        // Don't allow sending messages to self
        if (FirebaseManager.user?.uid == user.uid) {
            let alertVC = UIAlertController(title: "Error", message: "You can't send a message to yourself.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }
        
        // The uid of the childmost chat view
        var currentlyDisplayedUid = ""
        if self.childViewControllers.count > 1 {
            let chatVC = self.childViewControllers[1] as! ChatVC
            currentlyDisplayedUid = (chatVC.thread?.user.uid)!
        }
        
        // Only show the thread if we're not currently on that thread
        if user.uid != currentlyDisplayedUid {
        
            // Go to the message thread between the current user and the specified user
            ThreadManager.getOrCreateThread(with: user, completion: {thread in
                
                self.showThread(thread)
            })
        }
    }
    
    private func showThread(_ thread: Thread) {
        (self.viewControllers.first as! ThreadsTableVC).startChat(thread: thread)
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
