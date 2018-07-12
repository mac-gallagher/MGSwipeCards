//
//  Utilities.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 6/2/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}

extension UIColor {
    
    static var sampleRed = UIColor(red: 252/255, green: 70/255, blue: 93/255, alpha: 1)
    
    static var sampleGreen = UIColor(red: 49/255, green: 193/255, blue: 109/255, alpha: 1)
    
    static var sampleBlue = UIColor(red: 52/255, green: 154/255, blue: 254/255, alpha: 1)
    
}
