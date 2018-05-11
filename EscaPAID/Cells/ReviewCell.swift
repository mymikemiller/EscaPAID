//
//  ReviewCell.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/26/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var experienceTitle: ThemedLabel!
    
    @IBOutlet weak var reviewTitle: ThemedLabel!
    
    @IBOutlet weak var reviewText: UILabel!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configure(with review: Review) {
        experienceTitle.text = review.experience.title
        reviewTitle.text = review.title
        reviewText.text = review.text
        
        print("URL:",  review.reviewer.profileImageUrl.suffix(3))

        if let profileImageURL = URL(string: review.reviewer.profileImageUrl) {
            profilePhoto.af_setImage(withURL: profileImageURL, placeholderImage: #imageLiteral(resourceName: "ic_account_circle"))
        } else {
            profilePhoto.image = #imageLiteral(resourceName: "ic_account_circle")
        }
    }
    
    func hideExperienceTitle() {
        stackView.removeArrangedSubview(experienceTitle)
        experienceTitle.removeFromSuperview()
    }
    
    // We don't want to look any different when we're selected or highlighted, so intercept and don't call super for these methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Don't call super
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Don't call super
    }
    
}
