//
//  ExperienceCardCell.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/15/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceCardTableViewCell: UITableViewCell {

    @IBOutlet weak var card: ExperienceCard!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // We don't want to look any different when we're selected or highlighted, so intercept and don't call super for these methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Don't call super
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Don't call super
    }
    
}
