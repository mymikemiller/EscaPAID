//
//  HexagonImageView.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/19/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//
//  An ImageView that clips its image into a hexagon
//
//  From http://sapandiwakar.in/make-hexagonal-view-on-ios/
//

import UIKit

class HexagonalImageView: UIImageView {
    
    let lineWidth: CGFloat = 3
    let cornerRadius: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    func sharedInit() {
        let path = Utils.roundedPolygonPath(rect: bounds, lineWidth: lineWidth, sides: 6, cornerRadius: cornerRadius, rotationOffset: CGFloat(Double.pi / 2.0))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.lineWidth = lineWidth
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        layer.mask = mask
        
        let border = CAShapeLayer()
        border.path = path.cgPath
        border.lineWidth = lineWidth
        border.strokeColor = UIColor.white.cgColor
        border.fillColor = UIColor.clear.cgColor
        layer.addSublayer(border)
    }

}
