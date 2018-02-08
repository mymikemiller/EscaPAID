//
//  ReceiptTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 2/7/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ReceiptTableVC: UITableViewController {
    
    var reservation: Reservation?
    
    @IBOutlet weak var experienceTitle: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var user: UIButton!
    @IBOutlet weak var guests: UILabel!
    
    @IBOutlet weak var curatorSubtotal: UILabel!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var curatorTotal: UILabel!
    @IBOutlet weak var curatorSubtotalCell: UITableViewCell!
    @IBOutlet weak var feeCell: UITableViewCell!
    @IBOutlet weak var curatorTotalCell: UITableViewCell!
    
    @IBOutlet weak var customerTotal: UILabel!
    @IBOutlet weak var customerTotalCell: UITableViewCell!
    
    @IBOutlet weak var acceptCell: UITableViewCell!
    @IBOutlet weak var declineCell: UITableViewCell!
    
    @IBOutlet weak var message: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        experienceTitle.text = reservation?.experience.title
        date.text = reservation?.dateAsPrettyString
        user.setTitle(otherUser.displayName, for: .normal)
        guests.text = "\(reservation!.numGuests) \(reservation!.numGuests == 1 ? " guest" : " guests")"
        
        let totalChargeString = String(format: "$%.02f", reservation!.totalCharge)

        // The curator sees the subtotal, fee and curator total, while the customer only sees the "subtotal" (the total that he was charged). The visibility of these rows is determined in heightForRowAt
        customerTotal.text = totalChargeString
        curatorSubtotal.text = totalChargeString
        fee.text = String(format: "$%.02f", reservation!.fee)
        curatorTotal.text = String(format: "$%.02f", reservation!.totalCharge - reservation!.fee)
    }
    
    var isViewedByCurator: Bool {
        get {
            // users are not always equal, so compare the uid's
            return reservation!.experience.curator.uid == FirebaseManager.user?.uid
        }
    }
    
    // Show the curator if the buyer is looking at the receipt, show the buyer if the curator is looking at the receipt
    var otherUser: User {
        get {
            return (isViewedByCurator ? reservation?.user : reservation?.experience.curator)!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Hde the customer total if we're the curator, hide the subtotal, fee and curator total cell if we're the user
        let cell = tableView.cellForRow(at: indexPath)
        if (isViewedByCurator && cell == customerTotalCell) {
            return 0
        } else if (!isViewedByCurator &&
            (cell == curatorSubtotalCell ||
             cell == feeCell ||
             cell == curatorTotalCell)) {
                return 0
        }
        
        // Calling super will use the height set in your storyboard, avoiding hardcoded values
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    // Go to the chat for the shown user
//    ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: getWhoWith(reservation: reservation), completion: {thread in
//
//    let threadsNavigationController: ThreadsNavigationController = self.tabBarController?.viewControllers![2] as! ThreadsNavigationController
//    threadsNavigationController.threadToShowOnLoad = thread
//    self.tabBarController?.selectedViewController = threadsNavigationController
//    })

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
