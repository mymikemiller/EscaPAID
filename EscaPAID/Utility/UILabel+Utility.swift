//
//  UILabel+Utility.swift
//  Tellomee
//
//  Created by Michael Miller on 4/1/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

extension UILabel {
    func drawLineOnBothSides(labelWidth: CGFloat, color: UIColor) {
        
        // Avoid drawing the lines for now - they're not showing up right.
        
//        let fontAttributes = [NSAttributedStringKey.font: self.font]
//        let size = self.text?.size(withAttributes: fontAttributes)
//        let widthOfString = size!.width
//
//        let width = CGFloat(1)
//
//        let leftLine = UIView(frame: CGRect(x: 0, y: self.frame.height/2 - width/2, width: labelWidth/2 - widthOfString/2 - 10, height: width))
//        leftLine.backgroundColor = color
//        self.addSubview(leftLine)
//
//        let rightLine = UIView(frame: CGRect(x: labelWidth/2 + widthOfString/2 + 10, y: self.frame.height/2 - width/2, width: labelWidth/2 - widthOfString/2 - 10, height: width))
//        rightLine.backgroundColor = color
//        self.addSubview(rightLine)
    }
}
