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
    
    @IBOutlet weak var experienceCollectionView: ExperienceCollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var aboutMeLabel: ThemedLabel! {
        didSet {
            // This hack allows aboutMeLabel to size itself correctly, and not truncate
            aboutMeLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width
        }
    }

    
    override func viewDidLoad() {
        imageView.image = user.getProfileImage()
        nameLabel.text = user.fullName
        aboutMeLabel.text = user.aboutMe
        
        experienceCollectionView.displayType = .Curator(user)
        
        // For some reason, setting this via IB causes the background to be black. So we set it here.
        experienceCollectionView.backgroundColor = UIColor.clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // The following is necessary to get the header of the tableview (all the content of the page besides the reviews) to shrink to fit the content snugly. See https://useyourloaf.com/blog/variable-height-table-view-header/
        guard let header = tableView.tableHeaderView else {
            return
        }
        
        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        header.frame.size.height = height
        tableView.tableHeaderView = header
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExperience" {
            (segue.destination as! ExperienceVC).experience = selectedCard?.experience
        }
    }
}

extension ProfileVC: ExperienceCollectionViewDelegate {
    
    func didSelectCard(_ card: ExperienceCard) {
        // Unset the hero id for the previously selected card
        selectedCard?.hero.id = nil
        
        // Store the selected card and set its hero id
        selectedCard = card
        selectedCard?.hero.id = "hero_card"
        
        self.performSegue(withIdentifier: "showExperience", sender: self)
    }
}
