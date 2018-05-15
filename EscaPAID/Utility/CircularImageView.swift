//
//  CircularImageView.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/20/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class CircularImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    func sharedInit() {
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true
    }
}

