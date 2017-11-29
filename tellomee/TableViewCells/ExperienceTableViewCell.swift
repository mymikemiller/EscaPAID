//
//  ExperienceTableViewCell.swift
//  tellomee
//
//  Created by Michael Miller on 11/23/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceTableViewCell: UITableViewCell {
    
    var experience:Experience?
    
    @IBOutlet weak var theImage: UIImageView!
    
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        if let experience = experience {
            title?.text = experience.title
            theImage.image = experience.uiImages[0]
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
