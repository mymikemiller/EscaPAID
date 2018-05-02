//
//  ReviewCell.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/26/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTitle: UILabel!
    
    @IBOutlet weak var reviewText: UILabel!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with review: Review) {
        reviewTitle.text = review.title
        reviewText.text = review.text
        
        
        if let profileImageURL = URL(string: review.reviewer.profileImageUrl) {
            profilePhoto.af_setImage(withURL: profileImageURL)
        }        
    }
    
    // We don't want to look any different when we're selected or highlighted, so intercept and don't call super for these methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Don't call super
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Don't call super
    }
    
}
