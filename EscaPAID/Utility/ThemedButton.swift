//
//  ThemedButton.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/25/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class ThemedButton: UIButton {
    
    // Normally, the button's text color becomes the main color. If the button is inverted, the background color becomes the main color.
    @IBInspectable var inverted: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    
    
    func sharedInit() {
        if (inverted) {
            self.backgroundColor = Config.current.mainColor
        } else {
            self.setTitleColor(Config.current.mainColor, for: .normal)
        }
    }
}
