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
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthAndYear: UILabel!
    
    let outsideMonthColor = UIColor.lightGray
    let monthColor = UIColor.black
    let selectedMonthColor = UIColor.blue
    let currentDateSelectedViewColor = UIColor.yellow
    let todaysDateColor = UIColor.blue
    
    var experience:Experience?
    
    let formatter = DateFormatter()
    let todaysDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
        
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
    }
    
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? DateCell else { return }

        validCell.selectedView.isHidden = !cellState.isSelected
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? DateCell else { return }
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            if cellState.dateBelongsTo ==  .thisMonth {
                
                formatter.dateFormat = "yyyy MM dd"
                let todaysDateString = formatter.string(from: todaysDate)
                let monthDateString = formatter.string(from: cellState.date)
                
                validCell.dateLabel.textColor = todaysDateString == monthDateString ? todaysDateColor : monthColor
                
            } else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
        }
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "MMMM yyyy"
        monthAndYear.text = formatter.string(from: date)
    }
    
    func setupCalendarView() {
        // Set up calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Set up labels
        calendarView.visibleDates { visibleDates in
            self.setupViewsOfCalendar(from: visibleDates)
        }
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

extension ReservationVC : JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        let startDate = Date()
        
        // Only show this month plus the next 2
        let endDate = Calendar.current.date(byAdding: .month, value: 2, to: Date())!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
}

extension ReservationVC : JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = cellState.text
        
        configureCell(cell: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        cell?.bounce()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setupViewsOfCalendar(from: visibleDates)
    }
}

extension UIView {
    func bounce() {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options:UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}
