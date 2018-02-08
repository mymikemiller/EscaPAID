//
//  ReceiptVCTableViewController.swift
//  tellomee
//
//  Created by Michael Miller on 2/2/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ConfirmationTableVC: UITableViewController {
    
    var reservation: Reservation?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var providerButton: UIButton!
    @IBOutlet weak var numGuestsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = reservation?.experience.title
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = dateFormatter.string(from: (reservation?.date)!)
        
        timeLabel.text = reservation?.experience.startTime
        providerButton.setTitle(reservation?.experience.curator.displayName, for: UIControlState.normal)
        numGuestsLabel.text = String((reservation?.numGuests)!)
        totalLabel.text =
            String(format: "$%.02f", (reservation?.totalCharge)!
            )
    }
    
    func goToMessageThread() {
        // Don't allow sending messages to self
        if (FirebaseManager.user?.uid == self.reservation?.experience.curator.uid) {
            let alertVC = UIAlertController(title: "Error", message: "You can't send a message to yourself.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }
        
        // Go to the message thread between the user and the experience curator
        ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: (self.reservation?.experience.curator)!, completion: {thread in
            
            let threadsNavigationController: ThreadsNavigationController = self.tabBarController?.viewControllers![2] as! ThreadsNavigationController
            threadsNavigationController.threadToShowOnLoad = thread
            self.tabBarController?.selectedViewController = threadsNavigationController
        })
    }
    
    @IBAction func messageButton_click(_ sender: Any) {
        goToMessageThread()
    }
    
    @IBAction func payButton_click(_ sender: Any) {
        
        
        // Don't allow reserving own experience
        if (FirebaseManager.user?.uid == self.reservation?.experience.curator.uid) {
            let alertVC = UIAlertController(title: "Error", message: "You can't reserve your own experience.", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }
        
        // Reserve the experience.
        ReservationProcessor.reserve(reservation!)
        
        // Go to the message thread so the user can follow up
        goToMessageThread()
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
