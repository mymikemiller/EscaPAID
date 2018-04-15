//
//  ExperienceCardCell.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/15/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceCardCell: UITableViewCell {

    @IBOutlet weak var card: ExperienceCard!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
