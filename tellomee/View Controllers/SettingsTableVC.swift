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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let originVC: OriginScreenVC = self.storyboard?.instantiateViewController(withIdentifier: "originViewController") as! OriginScreenVC
            // Prevent auto-login once we log out or we'll immediately be logged back in
            originVC.autoLogin = false
            self.present(originVC, animated: true, completion: nil)

        } else {
            // All other cells are hooked up to "show" segues
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showReceipts" || segue.identifier == "showReservations") {
            
            let controller = segue.destination as! ReservationsTableVC
            
            controller.displayType = (segue.identifier == "showReceipts") ? .ReservationsAttended : .ReservationsCurated
        }
    }

}
