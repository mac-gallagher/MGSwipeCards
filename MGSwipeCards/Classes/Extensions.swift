//
//  Extensions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 10/8/18.
//

import UIKit

extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
    
    // Returns the point in the coordinate system -1 <= x,y <= 1 with the same relative position as in the provided frame
    func normalizedDistance(forSize size: CGSize) -> CGPoint {
        let x = 2 * (self.x / size.width)
        let y = 2 * (self.y / size.height)
        return CGPoint(x: x, y: y)
    }
    
    func dotProduct(with point: CGPoint) -> CGFloat {
        return (self.x * point.x) + (self.y * point.y)
    }
}

extension Array {
    
    func shift(withDistance distance: Int = 1) -> Array<Element> {
        let offsetIndex = distance >= 0 ? self.index(startIndex, offsetBy: distance, limitedBy: endIndex) : self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
        guard let index = offsetIndex else { return self }
        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    func anchorToSuperview() -> [NSLayoutConstraint] {
        return anchor(top: superview?.topAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, right: superview?.rightAnchor)
    }
}

extension CGAffineTransform {
    
    func scaleFactor() -> CGPoint {
        return CGPoint(x: sqrt(a * a + b * b), y: sqrt(c * c + d * d))
    }
    
    func translation() -> CGPoint {
        return CGPoint(x: tx, y: ty)
    }
    
    func rotationAngle() -> CGFloat {
        let s = sqrt(c * c + d * d)
        return CGFloat(Double.pi) / 2 - (d > 0 ? acos(-c / s) : -acos(c / s));
    }
    
    func percentTransform(with transform: CGAffineTransform, percent: CGFloat) -> CGAffineTransform {
        let a2 = (1 - percent) * a + percent * transform.a
        let b2 = (1 - percent) * b + percent * transform.b
        let c2 = (1 - percent) * c + percent * transform.c
        let d2 = (1 - percent) * d + percent * transform.d
        let tx2 = (1 - percent) * tx + percent * transform.tx
        let ty2 = (1 - percent) * ty + percent * transform.ty
        return CGAffineTransform(a: a2, b: b2, c: c2, d: d2, tx: tx2, ty: ty2)
    }
}
