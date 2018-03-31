//
//  RoundedButton.swift
//  EscaPAID
//
//  Created by Michael Miller on 3/30/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.textAlignment = .center
        layer.borderWidth = 3
        layer.borderColor = isEnabled ? tintColor.cgColor : UIColor.lightGray.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        if (currentImage != nil) {
            moveImageLeftTextCenter(imagePadding: 8)
        } else {
            contentHorizontalAlignment = .center
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func moveImageLeftTextCenter(imagePadding: CGFloat = 30.0){
        guard let imageViewWidth = self.imageView?.frame.width else{return}
        guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
        self.contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: imagePadding, left: imagePadding - imageViewWidth / 2, bottom: imagePadding, right: imagePadding)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
    }

}
