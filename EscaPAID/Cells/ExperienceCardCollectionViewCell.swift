//
//  ExperienceCardCollectionViewCell.swift
//  EscaPAID
//
//  Created by Michael Miller on 5/4/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ExperienceCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var card: ExperienceCard!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Use small fonts for cards in collectionviews
        card.fontSize = .Small
    }

}
