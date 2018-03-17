//
//  DaySelectorTableVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 1/21/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class DaySelectorTableVC: UITableViewController {
    
    var days: Days?
    
    @IBOutlet weak var mondaySwitch: UISwitch!
    @IBOutlet weak var tuesdaySwitch: UISwitch!
    @IBOutlet weak var wednesdaySwitch: UISwitch!
    @IBOutlet weak var thursdaySwitch: UISwitch!
    @IBOutlet weak var fridaySwitch: UISwitch!
    @IBOutlet weak var saturdaySwitch: UISwitch!
    @IBOutlet weak var sundaySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        mondaySwitch.isOn = days!.Monday
        tuesdaySwitch.isOn = days!.Tuesday
        wednesdaySwitch.isOn = days!.Wednesday
        thursdaySwitch.isOn = days!.Thursday
        fridaySwitch.isOn = days!.Friday
        saturdaySwitch.isOn = days!.Saturday
        sundaySwitch.isOn = days!.Sunday
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

// Return the selected days to the parent view controller
extension DaySelectorTableVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        days?.Monday = mondaySwitch.isOn
        days?.Tuesday = tuesdaySwitch.isOn
        days?.Wednesday = wednesdaySwitch.isOn
        days?.Thursday = thursdaySwitch.isOn
        days?.Friday = fridaySwitch.isOn
        days?.Saturday = saturdaySwitch.isOn
        days?.Sunday = sundaySwitch.isOn
        
        (viewController as? ExperienceEditorTableVC)?.experienceDays = days!
    }
}
