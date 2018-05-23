//
//  ReservationVC.swift
//  EscaPAID
//
//  Created by Michael Miller on 1/24/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ReservationVC: UIViewController {
    
    @IBOutlet weak var calendarView: UICalendar!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var totalGuests: UITextField!
    @IBOutlet weak var reserveButton: UIButton!
    
    var experience:Experience?
    
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.enabledDays = (experience?.days)!
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let picker = SelfContainedPickerView()
        picker.setUp(textField: totalGuests, strings: Constants.numGuests)
        totalGuests.inputView = picker
    }
    
    @IBAction func totalGuestsValueChanged(_ sender: Any) {
        setInfoText()
    }
    
    func setInfoText() {
        let date = calendarView.selectedDate
        if (date != nil) {
            dateAndTimeLabel.text = "\(self.totalGuests.text!) Ticket\(self.totalGuests.text == "1" ? "" : "s") for \(self.experience!.title)\n\(dateFormatter.string(from: date!)) @ \((experience?.startTime)!)"
        } else {
            dateAndTimeLabel.text = "Please select a date"
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showConfirmationVC") {
            let confirmationVC = (segue.destination as! ConfirmationTableVC)
            
            // Create a new, pending reservation with the specified information
            let numGuests = Int(self.totalGuests.text!)!
            let totalCharge = numGuests * experience!.price
            // Round the fee down so the curator gets that extra penny
            let fee = Int((Double(totalCharge) * Config.current.feePercent).rounded(.down))
            
            confirmationVC.reservation =
                Reservation(experience: experience!,
                            user: FirebaseManager.user!,
                            date: calendarView.selectedDate!,
                            numGuests: Int(numGuests),
                            totalCharge: totalCharge,
                            fee: fee,
                            status: .pending)
        }
    }
}

extension ReservationVC : UICalendarDelegate {
    func didSelectDate(_ date: Date) {
        setInfoText()
        
        // We've selected a date so we're ready to reserve
        reserveButton.isEnabled = true
    }
}
