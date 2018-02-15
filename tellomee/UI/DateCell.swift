//
//  DateCell.swift
//  tellomee
//
//  Created by Michael Miller on 1/24/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.selectedView.layer.cornerRadius = self.selectedView.bounds.size.width / 2.0;
//    }
}
