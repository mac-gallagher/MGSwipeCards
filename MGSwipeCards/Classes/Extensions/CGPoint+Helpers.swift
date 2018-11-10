//
//  CGPoint+Helpers.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

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
