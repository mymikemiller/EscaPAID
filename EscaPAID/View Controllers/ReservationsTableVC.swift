//
//  ReservationsTableVC.swift
//  EscaPAID
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
    
    var selectedReservation: Reservation?
    
    let reservationManager = ReservationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reservationManager.clear()
        
        if (displayType == .ReservationsAttended) {
            reservationManager.fillReservations(forUser: FirebaseManager.user!, completion: {
                
                self.tableView.reloadData()
            })
        } else if (displayType == .ReservationsCurated) {
            reservationManager.fillReservations(forCurator: FirebaseManager.user!, completion: {
                
                self.tableView.reloadData()
            })
        }
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
        cell.with.text = "With \(getWhoWith(reservation: reservation).displayName)"
        
        switch reservation.status {
        case .pending:
            cell.status.text = "Pending Acceptance"
            cell.status.textColor = UIColor.blue
        case .accepted:
            cell.status.text = "Accepted!"
            cell.status.textColor = UIColor.green
        case .declined:
            cell.status.text = "Declined"
            cell.status.textColor = UIColor.red
        default:
            cell.status.text = ""
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedReservation = reservationManager.reservations[indexPath.row]
        
        self.performSegue(withIdentifier: "showReceipt", sender: self)
    }
    
    
    
    // Show the curator when we're displaying the reservations we attend, otherwise show the user who booked the reservation
    private func getWhoWith(reservation: Reservation) -> User {
        return (displayType == ReservationsDisplayed.ReservationsAttended) ? reservation.experience.curator : reservation.user

    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showReceipt") {
            (segue.destination as! ReceiptTableVC).reservation = selectedReservation
        }
    }

}
