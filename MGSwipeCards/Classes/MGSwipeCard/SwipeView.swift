//
//  SwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

open class SwipeView: UIViewable {
    /// The swipe directions to be recognized by the view
    public var swipeDirections: [SwipeDirection] = SwipeDirection.allDirections
    
    /// The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1100.
    public var minimumSwipeSpeed: CGFloat = 1100
    
    /// The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2], where 2 represents the entire length/width of the card. Defaults to 0.5.
    public var minimumSwipeMargin: CGFloat = 0.5
    
    /// The pan gesture recognizer attached to the view.
    public var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer as UIPanGestureRecognizer
    }
    
    private lazy var panRecognizer: TestablePanGestureRecognizer = TestablePanGestureRecognizer(target: self, action: #selector(handlePan))
    
    /// The tap gesture recognizer attached to the view.
    public var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer as UITapGestureRecognizer
    }
    
    private lazy var tapRecognizer: TestableTapGestureRecognizer = TestableTapGestureRecognizer(target: self, action: #selector(handleTap))
    
    /// The location of the most recent `touchDown` event relative to the view's bounds.
    public var touchLocation: CGPoint? {
        return touchPoint
    }
    
    private var touchPoint: CGPoint?

    public var activeDirection: SwipeDirection? {
        return swipeDirections.reduce((highestPercentage: 0, activeDirection: nil), { (lastResult, direction) -> (CGFloat, SwipeDirection?) in
            let swipePercent = dragPercentage(on: direction)
            if swipePercent > lastResult.highestPercentage {
                return (swipePercent, direction)
            }
            return lastResult
        }).activeDirection
    }
    
    override func initialize() {
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(tapRecognizer)
    }
    
    /// The speed of the user's drag projected onto the specified direction.
    public func dragSpeed(on direction: SwipeDirection) -> CGFloat {
        let velocity = panRecognizer.velocity(in: superview)
        return abs(direction.point.dotProduct(with: velocity))
    }
    
    /// The percentage of the card's bounds that the drag attains in the specified direction.
    public func dragPercentage(on direction: SwipeDirection) -> CGFloat {
        let translation = panRecognizer.translation(in: superview)
        let normalizedTranslation = translation.normalizedDistance(forSize: UIScreen.main.bounds.size)
        let percentage = normalizedTranslation.dotProduct(with: direction.point)
        if percentage < 0 {
            return 0
        }
        return percentage
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
        didTap(recognizer: recognizer)
    }
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            beginSwiping(recognizer: recognizer)
        case .changed:
            continueSwiping(recognizer: recognizer)
        case .ended:
            endSwiping(recognizer: recognizer)
        default:
            break
        }
    }
    
    func didTap(recognizer: UITapGestureRecognizer) {}
    
    func beginSwiping(recognizer: UIPanGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
    }
    
    func continueSwiping(recognizer: UIPanGestureRecognizer) {}
    
    func endSwiping(recognizer: UIPanGestureRecognizer) {
        if let direction = activeDirection {
            if dragSpeed(on: direction) >= minimumSwipeSpeed || dragPercentage(on: direction) >= minimumSwipeMargin {
                didSwipe(recognizer: recognizer, with: direction)
            } else {
                didCancelSwipe(recognizer: recognizer)
            }
        } else {
            didCancelSwipe(recognizer: recognizer)
        }
    }
    
    func didSwipe(recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {}
    
    func didCancelSwipe(recognizer: UIPanGestureRecognizer) {}
}
