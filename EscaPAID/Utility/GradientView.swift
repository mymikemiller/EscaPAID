//
//  GradientView.swift
//  Tellomee
//
//  Created by Michael Miller on 3/28/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

final class GradientView: UIView {
    var startColor: UIColor = Config.current.gradientStartColor
    var endColor: UIColor = Config.current.gradientEndColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
        
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    

    func setup() {
        
        let didRotate: (Notification) -> Void = { notification in
            self.setNeedsDisplay()
        }
        
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange,
                                               object: nil,
                                               queue: .main,
                                               using: didRotate)
    }


    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: superview!.frame.size.width,
                                height: superview!.frame.size.height)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.zPosition = -1
        layer.addSublayer(gradient)
    }
    
    
    
    
}

