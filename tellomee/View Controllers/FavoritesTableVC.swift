//
//  FavoritesTableVC.swift
//  tellomee
//
//  Created by Michael Miller on 2/16/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class FavoritesTableVC: UITableViewController {
    
    let experienceManager = ExperienceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ExperienceCell",bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "experienceCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Should this be happening every time we appear?
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return experienceManager.experiences.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experienceCell", for: indexPath) as! ExperienceTableViewCell
        
        let experience = experienceManager.experiences[indexPath.row]
        cell.experience = experience
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showExperience", sender: self)
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


