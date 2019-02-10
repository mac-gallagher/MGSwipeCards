//
//  CGPoint+Extensions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
    
    /// Rename this (distance doesn't make sense here)
    /// Returns the point in the coordinate system -1 <= x,y <= 1 with the same relative position as in the provided frame
    func normalizedDistance(forSize size: CGSize) -> CGPoint {
        let x = 2 * (self.x / size.width)
        let y = 2 * (self.y / size.height)
        return CGPoint(x: x, y: y)
    }
    
    func dotProduct(with point: CGPoint) -> CGFloat {
        return (self.x * point.x) + (self.y * point.y)
    }
}

//MARK: - Additional Operators

extension CGPoint {
    static func + (p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
    }
    
    static func - (p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
    }
    
    static func * (c: CGFloat, point: CGPoint) -> CGPoint {
        return CGPoint(x: c * point.x, y: c * point.y)
    }
    
    static func * (point: CGPoint, c: CGFloat) -> CGPoint {
        return CGPoint(x: c * point.x, y: c * point.y)
    }
}
