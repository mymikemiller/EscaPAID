//
//  ExperienceCard.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/9/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@IBDesignable class ExperienceCard: CardView {
    
    var experience:Experience! {
        didSet {
            skillLevel.text = experience.skillLevel
            title.text = experience.title
            
            // Set the size of the image so that it looks like it's being clipped by the card
            image.layer.cornerRadius = cornerRadius
            
            // Use AlamofireImage to fetch the image
            let imageURL = URL(string: experience.imageUrls[0])!
            let placeholder = UIImage(named: "loading")
            
            // Darken the image after fetching
            let filter = DynamicImageFilter("darken") {image in
                return image.darkened()!
            }
            
            image.af_setImage(
                withURL: imageURL,
                placeholderImage: placeholder,
                filter: filter,
                imageTransition: .crossDissolve(0.2)
            )
        }
    }

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var skillLevel: UILabel!
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
