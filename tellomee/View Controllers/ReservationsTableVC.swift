//
//  ReservationsTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 2/6/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ReservationsTableVC: UITableViewController {
    
    enum ReservationsDisplayed {
        case ReservationsAttended
        case ReservationsCurated
    }
    
    var displayType: ReservationsDisplayed = .ReservationsAttended
    
    let reservationManager = ReservationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (displayType == .ReservationsAttended) {
            reservationManager.fillReservations(forUser: FirebaseManager.user!, completion: {
                
                self.tableView.reloadData()
            })
        } else if (displayType == .ReservationsCurated) {
            reservationManager.fillReservations(forCurator: FirebaseManager.user!, completion: {
                
                self.tableView.reloadData()
            })
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reservationManager.reservations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell", for: indexPath) as! ReservationTableViewCell

        let reservation = reservationManager.reservations[indexPath.row]
        
        // Configure the cell...
        cell.title.text = reservation.experience.title
        cell.date.text = reservation.dateAsPrettyString
        cell.with.setTitle("With \(getWhoWith(reservation: reservation).displayName)", for: .normal)
        
        switch reservation.status {
        case "pending":
            cell.status.text = "Pending Acceptance"
            cell.status.textColor = UIColor.blue
        case "accepted":
            cell.status.text = "Accepted!"
            cell.status.textColor = UIColor.green
        case "declined":
            cell.status.text = "Declined"
            cell.status.textColor = UIColor.red
        default:
            cell.status.text = ""
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let reservation = reservationManager.reservations[indexPath.row]
        
        // Go to the chat for the shown user
        ThreadManager.getOrCreateThread(between: FirebaseManager.user!, and: getWhoWith(reservation: reservation), completion: {thread in
            
            let threadsNavigationController: ThreadsNavigationController = self.tabBarController?.viewControllers![2] as! ThreadsNavigationController
            threadsNavigationController.threadToShowOnLoad = thread
            self.tabBarController?.selectedViewController = threadsNavigationController
        })

    }
    
    // Show the curator when we're displaying the reservations we attend, otherwise show the user who booked the reservation
    private func getWhoWith(reservation: Reservation) -> User {
        return (displayType == ReservationsDisplayed.ReservationsAttended) ? reservation.experience.curator : reservation.user

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
