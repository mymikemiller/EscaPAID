//
//  ThemedLabel.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/18/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ThemedLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.textColor = Config.current.mainColor
    }
}