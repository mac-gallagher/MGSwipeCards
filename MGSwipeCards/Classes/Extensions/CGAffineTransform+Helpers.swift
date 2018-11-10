//
//  CGAffineTransform+Helpers.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 10/8/18.
//

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
