//
//  ReceiptVCTableViewController.swift
//  tellomee
//
//  Created by Michael Miller on 2/2/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ConfirmationTableVC: UITableViewController {
    
    var experience: Experience?
    var date: String?
    var time: String?
    var numGuests: Int?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var providerButton: UIButton!
    @IBOutlet weak var numGuestsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = experience?.title
        dateLabel.text = date
        timeLabel.text = time
        providerButton.setTitle(experience?.curator.displayName, for: UIControlState.normal)
        numGuestsLabel.text = String(numGuests!)
        totalLabel.text =
            String(format: "$%.02f", getTotal())
    }
    
    func getTotal() -> Double {
        return Double(numGuests!) * (experience?.price)!
    }
    
    @IBAction func messageButton_click(_ sender: Any) {
        
        if (FirebaseManager.user?.uid == self.experience?.curator.uid) {
            let alertVC = UIAlertController(title: "Error", message: "You can't send a message to yourself.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }
        
        ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: (self.experience?.curator)!, completion: {thread in
            
            let threadsNavigationController: ThreadsNavigationController = self.tabBarController?.viewControllers![2] as! ThreadsNavigationController
            threadsNavigationController.threadToShowOnLoad = thread
            self.tabBarController?.selectedViewController = threadsNavigationController
        })
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
