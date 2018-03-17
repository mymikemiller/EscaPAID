//
//  MyExperiencesTableVC
//  EscaPAID
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class MyExperiencesTableVC: UITableViewController {
    
    // This is set to the selected experience when the user selects a row. This is used to prepare for the segue.
    var selectedExperience: Experience?
    
    let experienceManager = ExperienceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ExperienceCell",bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "experienceCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Should this be happening every time we appear?
        experienceManager.fillExperiences(forCurator: FirebaseManager.user!) {
            () in
            DispatchQueue.main.async {
                // This is a bit of a heavy hammer
                self.tableView.reloadData()
            }
        }
        // Reload the table right away so it'll appear empty while wait to we fill it
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        selectedExperience = experienceManager.experiences[indexPath.row]
        self.performSegue(withIdentifier: "showExperienceEditor", sender: self)
    }
    @IBAction func addButton_click(_ sender: Any) {
        selectedExperience = nil
        self.performSegue(withIdentifier: "showExperienceEditor", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showExperienceEditor") {
            
            let navVC = segue.destination as? UINavigationController
            
            let editExperienceVC = navVC?.viewControllers.first as! ExperienceEditorTableVC
            
            editExperienceVC.experience = selectedExperience
        }
    }
    
    
}

