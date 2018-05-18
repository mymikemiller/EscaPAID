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
    
    var reviewManager: ReviewManager = ReviewManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var experiencesNumberLabel: ThemedLabel!
    @IBOutlet weak var reviewsNumberLabel: ThemedLabel!
    @IBOutlet weak var experiencesLabel: ThemedLabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var aboutMeLabel: ThemedLabel! {
        didSet {
            // This hack allows aboutMeLabel to size itself correctly, and not truncate
            aboutMeLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width
        }
    }
    
    @IBOutlet weak var reviewsLabel: ThemedLabel!
    
    override func viewDidLoad() {
        profilePhoto.image = user.getProfileImage()
        nameLabel.text = user.fullName
        aboutMeLabel.text = user.aboutMe
        
        // Configure the experience collection view
        experienceCollectionView.displayType = .Curator(user)
        
        // Register the cell for reviews
        tableView.register(UINib(nibName: "ReviewCell", bundle: Bundle.main), forCellReuseIdentifier: "reviewCell")
        
        // Set up the tableView to auto-fit reviews
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140 // arbitrary value
        
        // Set the text for the Experiences label
        experiencesLabel.text = Config.current.experiencesTitle
        
        // Fetch the reviews
        reviewManager.fillReviews(curator: user) {
            // Update the review labels now that we know how many reviews there are
            let count = self.reviewManager.reviews.count
            self.reviewsNumberLabel.text = String(count)
            self.reviewsLabel.text = "\(count) Review\(count == 1 ? "" : "s")"
            
            // Heavy hammer. Reload the entire table for every new review.
            self.tableView.reloadData()
        }
        
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
    
    @IBAction func messageButton_click(_ sender: Any) {
        guard self.user.uid != FirebaseManager.user!.uid else {
            present(UIAlertController(message: "You cannot send a message to yourself."), animated: true)
            return
        }
        
        let data = ["user" : self.user]
        
        // Send a broadcast notification to let the inbox know which thread to show
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ThreadsNavigationController.SHOW_THREAD_POST), object: data)
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
    
    func newExperienceAdded(total: Int) {
        experiencesNumberLabel.text = String(total)
    }
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewManager.reviews.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reviews in reverse order so the newest review is first
        let review = reviewManager.reviews.reversed()[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: review)
        return cell
    }
}

