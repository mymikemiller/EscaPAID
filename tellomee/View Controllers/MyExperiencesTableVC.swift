//
//  ExperiencesTableViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class MyExperiencesTableVC: UITableViewController {
    
    // This is set to the selected experience when the user selects a row. This is used to prepare for the segue.
    var selectedExperience: Experience?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ExperienceCell",bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "experienceCell")

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MyExperienceManager.fillExperiences {
            () in
            DispatchQueue.main.async {
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
        return MyExperienceManager.experiences.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experienceCell", for: indexPath) as! ExperienceTableViewCell
        
        let experience = MyExperienceManager.experiences[indexPath.row]
        cell.experience = experience
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExperience = MyExperienceManager.experiences[indexPath.row]
        self.performSegue(withIdentifier: "showExperienceEditor", sender: self)
    }
    
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
            
            let editExperienceVC = navVC?.viewControllers.first as! ExperienceEditorVC
            
            editExperienceVC.experience = selectedExperience
        }
    }
    
    
}

