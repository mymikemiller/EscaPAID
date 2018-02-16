//
//  SettingsTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 12/2/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {

    @IBOutlet weak var editProfileCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell == editProfileCell) {
            // Edit Profile
            self.performSegue(withIdentifier: "showProfileEditor", sender: self)
        } else if (cell == logOutCell) {
            // Log Out
            
            FirebaseManager.logOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let originVC: OriginScreenVC = storyboard.instantiateViewController(withIdentifier: "originViewController") as! OriginScreenVC
            // Prevent auto-login once we log out or we'll immediately be logged back in
            originVC.autoLogin = false
            self.present(originVC, animated: true, completion: nil)

        } else {
            // All other cells are hooked up to "show" segues
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showReceipts" || segue.identifier == "showReservations") {
            
            let controller = segue.destination as! ReservationsTableVC
            
            controller.displayType = (segue.identifier == "showReceipts") ? .ReservationsAttended : .ReservationsCurated
        }
    }

}
