//
//  UICalendar.swift
//  tellomee
//
//  Created by Michael Miller on 1/31/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import JTAppleCalendar

@objc protocol UICalendarDelegate: class {
    func didSelectDate(_ date: Date)
}

class UICalendar: UIView {
    
    @IBOutlet var delegate: UICalendarDelegate?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthAndYear: UILabel!
    
    var enabledDays: Days = Days.All
    
    public private(set) var selectedDate: Date?
    
    let outsideMonthColor = UIColor.lightGray
    let monthEnabledColor = UIColor.black
    let monthDisabledColor = UIColor.gray
    let selectedMonthColor = UIColor.blue
    let currentDateSelectedViewColor = UIColor.yellow
    let todaysDateColor = UIColor.blue
    
    let formatter = DateFormatter()
    let todaysDate = Date()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("UICalendar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let nibName = UINib(nibName: "DateCell", bundle:nil)
        calendarView.register(nibName, forCellWithReuseIdentifier: "dateCell")

        setupCalendarView()
        
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? DateCell else { return }
        
        // Set visibility for the "selected view" (the yellow circle behind the date)
        validCell.selectedView.isHidden = !cellState.isSelected
        
        // Cache the selected date
        if (cellState.isSelected) {
            selectedDate = cellState.date
            delegate?.didSelectDate(selectedDate!)
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? DateCell else { return }
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            if cellState.dateBelongsTo != .thisMonth || dateIsPast(cellState.date) {
                
                validCell.dateLabel.textColor = outsideMonthColor
            } else {
                
                formatter.dateFormat = "yyyy MM dd"
                let todaysDateString = formatter.string(from: todaysDate)
                let monthDateString = formatter.string(from: cellState.date)
                
                if todaysDateString == monthDateString {
                    validCell.dateLabel.textColor = todaysDateColor
                } else {
    
                    if (cellIsEnabled(cellState: cellState)) {
                        validCell.dateLabel.textColor = monthEnabledColor
                    } else {
                        validCell.dateLabel.textColor = monthDisabledColor
                    }
                }
                
            }
        }
    }
    
    func cellIsEnabled(cellState: CellState) -> Bool {
        return ((enabledDays.Monday && cellState.day == DaysOfWeek.monday) ||
        (enabledDays.Tuesday && cellState.day == DaysOfWeek.tuesday) ||
        (enabledDays.Wednesday && cellState.day == DaysOfWeek.wednesday) ||
        (enabledDays.Thursday && cellState.day == DaysOfWeek.thursday) ||
        (enabledDays.Friday && cellState.day == DaysOfWeek.friday) ||
        (enabledDays.Saturday && cellState.day == DaysOfWeek.saturday) ||
        (enabledDays.Sunday && cellState.day == DaysOfWeek.sunday))
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
}


extension UICalendar : JTAppleCalendarViewDataSource {
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

extension UICalendar : JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        
        cell.dateLabel.text = cellState.text
        
        // Hide the cell if it's an in-date or out-date (only show cells from this month)
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
        
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
    
    private func dateIsPast(_ date: Date) -> Bool {
        // Subtract a day so we can leave today open to booking
        return date < Date().yesterday
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        // Don't allow selection of dates in the past
        if dateIsPast(cellState.date) {
            return false
        }
        
        // Only allow selection of dates with a day enabled in the "enabledDates" object
        return (cellState.day == DaysOfWeek.monday && enabledDays.Monday) ||
        (cellState.day == DaysOfWeek.tuesday && enabledDays.Tuesday) ||
        (cellState.day == DaysOfWeek.wednesday && enabledDays.Wednesday) ||
        (cellState.day == DaysOfWeek.thursday && enabledDays.Thursday) ||
        (cellState.day == DaysOfWeek.friday && enabledDays.Friday) ||
        (cellState.day == DaysOfWeek.saturday && enabledDays.Saturday) ||
        (cellState.day == DaysOfWeek.sunday && enabledDays.Sunday)
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

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
