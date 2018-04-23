//
//  FavoritesTableVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 2/16/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class FavoritesVC: UIViewController {
    
    @IBOutlet var experienceTableView: ExperienceTableView!
    
    var selectedCard: ExperienceCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill the table once. New objects will appear here as they're added to the database (when the user favorites them) and removed when they're removed from the database (when the user unfavorites them)
        experienceTableView.displayType = DisplayType.Favorites(FirebaseManager.user!)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showExperience") {
            let controller = segue.destination as! ExperienceVC
            controller.experience = selectedCard?.experience
        }
    }
}


extension FavoritesVC: ExperienceTableViewDelegate {
    func isFiltering() -> Bool {
        // We don't filter favorites
        return false
    }
    
    func didSelectCard(_ card: ExperienceCard) {
        // Unset the hero id for the previously selected card
        selectedCard?.hero.id = nil
        
        // Store the selected card and set its hero id
        selectedCard = card
        selectedCard?.hero.id = "hero_card"
        
        self.performSegue(withIdentifier: "showExperience", sender: self)
    }
}
