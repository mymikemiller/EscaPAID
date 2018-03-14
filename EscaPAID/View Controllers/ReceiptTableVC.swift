//
//  ReceiptTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 2/7/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ReceiptTableVC: UITableViewController {
    
    let RESPONSE_SECTION = 2
    
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
    
    // Hide the rows for the Response section if the customer is viewing the receipt
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!isViewedByCurator && section == RESPONSE_SECTION) {
            return 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    // Hide the header for the Response section if the customer is viewing the receipt
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (!isViewedByCurator && section == RESPONSE_SECTION) {
            return 0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        // Add the checkmark to the clicked cell
        if cell == acceptCell {
            acceptCell.accessoryType = .checkmark
            declineCell.accessoryType = .none
        } else if cell == declineCell {
            acceptCell.accessoryType = .none
            declineCell.accessoryType = .checkmark
        }
        
        // Deselect the row. Adding the checkmark was enough.
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func userButton_click(_ sender: Any) {
        
        // Go to the chat for the shown user
        let data = ["user" : otherUser]
        
        // Send a broadcast notification to let the inbox know which thread to show
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST), object: data)
    }
    
    @IBAction func sendButton_click(_ sender: Any) {
        // Mark the reservation as accepted / declined
        let accepted = acceptCell.accessoryType == .checkmark
        let newStatus = accepted ? Reservation.Status.accepted : Reservation.Status.declined
        
        if let reservation = reservation {
            ReservationManager.setStatus(for: reservation, status: newStatus)
            
            // send a message to the user notifying of the new status
            let includingMessage = message.text?.count == 0 ? "" : "with the following message "
            
            let text = "*** \(FirebaseManager.user!.displayName) \(newStatus.rawValue) your reservation for \(reservation.experience.title) on \(reservation.dateAsPrettyString) \(includingMessage)***"
            
            ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: reservation.user, completion: {thread in
                
                // Send the notice
                PostManager.addPost(threadId: (thread.threadId), text: text, toId: thread.user.uid, fromId: (FirebaseManager.user?.uid)!)
                
                // Also send the optional message if one was supplied
                PostManager.addPost(threadId: (thread.threadId), text: self.message.text!, toId: thread.user.uid, fromId: (FirebaseManager.user?.uid)!)
                
                // Go back to the reservations screen
                self.navigationController?.popViewController(animated: true)
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
