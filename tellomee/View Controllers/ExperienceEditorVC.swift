//
//  ExperienceEditorVC.swift
//  tellomee
//
//  Created by Michael Miller on 11/28/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceEditorVC: UIViewController {

    var experience:Experience?
    
    @IBOutlet weak var experienceTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        if let experience = experience {
            experienceTitle.text = experience.title
        }
    }
    @IBAction func cancelButton_click(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func saveButton_click(_ sender: Any) {
        experience?.title = (experienceTitle?.text)!
        experience?.save()
        self.dismiss(animated: true, completion:nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
