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
            
            // Set the corner radius of the image so that it looks like it's being clipped by the card
            image.layer.cornerRadius = cornerRadius
            shadeView.layer.cornerRadius = cornerRadius
            
            
            // Use AlamofireImage to fetch the image
            let imageURL = URL(string: experience.imageUrls[0])!
            let placeholder = UIImage(named: "loading")
            
            // For now, don't darken the image after fetching. We darken it by having a semi-transparent view on top of it.
            let filter:DynamicImageFilter? = nil
            //let filter = DynamicImageFilter("darken") {image in return image.darkened()! }
            
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
    @IBOutlet weak var shadeView: UIView!
    
    // Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ExperienceCard", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }

}
