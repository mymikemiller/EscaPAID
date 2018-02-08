//
//  ReservationVC.swift
//  tellomee
//
//  Created by Michael Miller on 1/24/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ReservationVC: UIViewController {
    
    @IBOutlet weak var calendarView: UICalendar!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var guestsSlider: UISlider!
    @IBOutlet weak var reserveButton: UIButton!
    
    var experience:Experience?
    
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.enabledDays = (experience?.days)!
        refreshGuestsLabel()
        guestsLabel.text = "1 guest"
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
    }
    
    func refreshGuestsLabel() {
        let val = Int(guestsSlider.value)
        guestsLabel.text = String(val) + (val == 1 ? " guest" : " guests")
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showConfirmationVC") {
            let confirmationVC = (segue.destination as! ConfirmationTableVC)
            
            // Create a new, pending reservation with the specified information
            let numGuests = Double(self.guestsSlider.value)
            let totalCharge = numGuests * experience!.price
            let fee = totalCharge * Constants.feePercent
            
            confirmationVC.reservation =
                Reservation(experience: experience!,
                            user: FirebaseManager.user!,
                            date: calendarView.selectedDate!,
                            numGuests: Int(numGuests),
                            totalCharge: totalCharge,
                            fee: fee,
                            status: "pending")
        }
    }
    

    @IBAction func guestsSlider_valueChanged(_ sender: Any) {
        
        let val = Int(guestsSlider.value)
        // Snap the slider to the selected integer
        guestsSlider.value = Float(val)
        refreshGuestsLabel()
    }
}

extension ReservationVC : UICalendarDelegate {
    func didSelectDate(_ date: Date) {
        dateAndTimeLabel.text = dateFormatter.string(from: date) + " at " + (experience?.startTime)!
        
        // We've selected a date so we're ready to reserve
        reserveButton.isEnabled = true
    }
}
