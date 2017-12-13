//
//  ThreadTableViewCell.swift
//  tellomee
//
//  Created by Michael Miller on 11/12/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ThreadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var cellName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Crop to a circle
        self.cellImage.layer.cornerRadius = self.cellImage.frame.width / 2
        self.cellImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
