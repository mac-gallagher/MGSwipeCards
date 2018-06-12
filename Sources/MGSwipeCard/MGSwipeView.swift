//
//  MGSwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class MGSwipeView: UIView {
    
    open var swipeDirections = SwipeDirection.allDirections
    
    public var activeDirection: SwipeDirection? {
        let translation = panGestureRecognizer.translation(in: superview)
        let normalizedTranslation = translation.normalizedDistance(forSize: UIScreen.main.bounds.size)
        return swipeDirections.reduce((distance: CGFloat.infinity, direction: nil), { closest, direction -> (CGFloat, SwipeDirection?) in
            let distance = direction.point.distance(to: normalizedTranslation)
            if distance < closest.distance {
                return (distance, direction)
            }
            return closest
        }).direction
    }
    
    public lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))

    public init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            beginSwiping(on: self, recognizer: recognizer)
        case .changed:
            continueSwiping(on: self, recognizer: recognizer)
        case .ended:
            endSwiping(on: self, recognizer: recognizer)
        default:
            break
        }
    }
    
    public func swipeSpeed(onDirection direction: SwipeDirection) -> CGFloat {
        let velocity = panGestureRecognizer.velocity(in: superview)
        if !swipeDirections.contains(direction) { return 0 }
        return abs(direction.point.dotProduct(with: velocity))
    }
    
    public func swipePercentage(onDirection direction: SwipeDirection) -> CGFloat {
        let translation = panGestureRecognizer.translation(in: superview)
        if !swipeDirections.contains(direction) { return 0 }
        let normalizedDragVector = translation.normalizedDistance(forSize: UIScreen.main.bounds.size)
        let percentage = normalizedDragVector.dotProduct(with: direction.point)
        if percentage < 0 {
            return 0
        }
        return percentage
    }
    
    open func beginSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
    }
    
    open func continueSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
    }
    
    open func endSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
    }
    
}
