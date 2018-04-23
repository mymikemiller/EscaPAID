//
//  MyExperiencesTableVC
//  EscaPAID
//
//  Created by Michael Miller on 11/22/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class MyExperiencesVC: UIViewController {
    
    // This is set to the selected experience when the user selects a row. This is used to prepare for the segue.
    var selectedCard: ExperienceCard?
    
    @IBOutlet weak var experienceTableView: ExperienceTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        experienceTableView.displayType = DisplayType.Curator(FirebaseManager.user!)
    }
    
    @IBAction func addButton_click(_ sender: Any) {
        // Setting selectedCard to nil will cause a new experience to be created when we segue
        selectedCard = nil
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
            
            editExperienceVC.experience = selectedCard?.experience
        }
    }
}

extension MyExperiencesVC: ExperienceTableViewDelegate {
    func didSelectCard(_ card: ExperienceCard) {
        // Store the selected card in for use in the segue
        selectedCard = card
        
        self.performSegue(withIdentifier: "showExperienceEditor", sender: self)
        
    }
    
    func isFiltering() -> Bool {
        // We don't need to filter as we're already displaying only our own experiences
        return false
    }
    
    
}
