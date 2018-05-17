//
//  BorderedTextView.swift
//  EscaPAID
//
//  Created by Michael Miller on 5/17/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class BorderedTextView: UITextView {
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        
        self.layer.borderColor = UIColor(named: "dark_grey")?.cgColor
    }
}
