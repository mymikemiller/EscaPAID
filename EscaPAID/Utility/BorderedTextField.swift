//
//  BorderedTextField.swift
//  EscaPAID
//
//  Created by Michael Miller on 5/17/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class BorderedTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.layer.borderWidth = 1
        
        self.layer.borderColor = UIColor(named: "dark_grey")?.cgColor
    }

}
