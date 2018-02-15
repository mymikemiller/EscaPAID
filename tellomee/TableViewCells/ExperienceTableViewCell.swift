//
//  ExperienceTableViewCell.swift
//  tellomee
//
//  Created by Michael Miller on 11/23/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import SDWebImage

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
            let placeholder = UIImage(named: "loading")
            let imageURL = URL(string: experience.imageUrls[0])
            
            theImage.sd_setImage(with: imageURL, placeholderImage:placeholder)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
