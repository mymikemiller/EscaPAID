//
//  SettingsTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 12/2/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Alamofire

class SettingsTableVC: UITableViewController {

    @IBOutlet weak var editProfileCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    
    @IBOutlet weak var becomeACuratorCell: UITableViewCell!
    @IBOutlet weak var manageCuratedExperiencesCell: UITableViewCell!
    @IBOutlet weak var viewReservationsCell: UITableViewCell!
    @IBOutlet weak var addExperienceCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isCurator = FirebaseManager.user?.stripeUserId != nil
        setCuratorSettingsVisibility(isCurator: isCurator)
    }
    
    func setCuratorSettingsVisibility(isCurator: Bool) {
        becomeACuratorCell.enable(on: !isCurator)
        manageCuratedExperiencesCell.enable(on: isCurator)
        viewReservationsCell.enable(on: isCurator)
        addExperienceCell.enable(on: isCurator)
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell == editProfileCell) {
            // Edit Profile
            self.performSegue(withIdentifier: "showProfileEditor", sender: self)
        } else if (cell == becomeACuratorCell) {
            becomeCurator()
        }

        else if (cell == logOutCell) {
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
    
    func becomeCurator() {
        var components = URLComponents(string: "https://connect.stripe.com/express/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "api_version", value:Constants.stripeApiVersion),
            URLQueryItem(name: "client_id", value:Constants.stripeClientId),
            URLQueryItem(name: "stripe_user[email]", value:FirebaseManager.user?.email)]
        
        if let url = components.url {
            
            // Launch the browser to the Stripe account connect page. We'll return here via the redirect_uri, which will put us in AppDelegate application:continueUserActivity:restorationHandler
            UIApplication.shared.open(url)
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

// Allow enabling/disabling cells
extension UITableViewCell {
    func enable(on: Bool) {
        isUserInteractionEnabled = on
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}
