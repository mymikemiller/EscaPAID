//
//  ExperienceCard.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/9/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class ExperienceCard: CardView {
    
    var experience:Experience! {
        didSet {
            title.text = experience.title
            
            // Set the size of the image so that it looks like it's being clipped by the card
            image.layer.cornerRadius = cornerRadius
            
            let placeholder = UIImage(named: "loading")
            let imageURL = URL(string: experience.imageUrls[0])
            
            image.sd_setImage(with: imageURL, placeholderImage:placeholder)
        }
    }

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ExperienceCard", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
