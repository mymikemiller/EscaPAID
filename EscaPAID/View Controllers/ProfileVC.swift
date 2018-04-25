//
//  ProfileVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/17/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    var user: User!
    
    var selectedCard: ExperienceCard?
    
    @IBOutlet weak var experiencesTableView: ExperienceTableView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var aboutMeLabel: ThemedLabel!
    
    override func viewDidLoad() {
        imageView.image = user.getProfileImage()
        nameLabel.text = user.fullName
        aboutMeLabel.text = user.aboutMe
        
        experiencesTableView.displayType = DisplayType.Curator(user)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExperience" {
            (segue.destination as! ExperienceVC).experience = selectedCard?.experience
        }
    }
}

extension ProfileVC: ExperienceTableViewDelegate {
    func isFiltering() -> Bool {
        // We don't filter as we're already showing only the curator's experiences
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
