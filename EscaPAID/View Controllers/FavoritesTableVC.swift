//
//  FavoritesTableVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 2/16/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class FavoritesTableVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    let experienceManager = ExperienceManager()
    
    var selectedCell: ExperienceCardCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ExperienceCardCell",bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "experienceCardCell")
        tableView.layoutMargins = UIEdgeInsetsMake(0, 37, 0, 37)
        tableView.rowHeight = tableView.contentSize.width / CGFloat(Constants.cardRatio)

        
        // Fill the table once. New objects will appear here as they're added to the database (when the user favorites them) and removed when they're removed from the database (when the user unfavorites them)
        experienceManager.fillExperiences(forFavoritesOf: FirebaseManager.user!) {
            () in
            DispatchQueue.main.async {
                // This is a bit of a heavy hammer
                self.tableView.reloadData()
            }
        }
        // Reload the table right away so it'll appear empty while wait to we fill it
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showExperience") {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let experience: Experience = experienceManager.experiences[indexPath.row]
                let controller = segue.destination as! ExperienceVC
                controller.experience = experience
            }
        }
    }
}


// MARK: - Table view data source

extension FavoritesTableVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return experienceManager.experiences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experienceCardCell", for: indexPath) as! ExperienceCardCell
        
        let experience = experienceManager.experiences[indexPath.row]
        cell.card.experience = experience
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Unset the hero id for the previously selected card
        selectedCell?.card.hero.id = nil
        
        // Store the selected card and set its hero id
        selectedCell = tableView.cellForRow(at: indexPath) as! ExperienceCardCell
        selectedCell?.card.hero.id = "hero_card"
        
        self.performSegue(withIdentifier: "showExperience", sender: self)
    }
}
