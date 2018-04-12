//
//  UIImage+Utility.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/12/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Foundation

public extension UIImage {
    func darkened() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return nil
        }
        
        // flip the image, or result appears flipped
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.translateBy(x: 0, y: -size.height)
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.draw(cgImage, in: rect)
        UIColor(white: 0, alpha: 0.5).setFill()
        ctx.fill(rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
