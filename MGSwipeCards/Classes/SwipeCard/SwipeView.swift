//
//  SwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

open class SwipeView: UIView {
    
    /// The swipe directions to be recognized by the view as a possible active direction
    public var swipeDirections: [SwipeDirection] = SwipeDirection.allDirections
    
    /// The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1100.
    public var minimumSwipeSpeed: CGFloat = 1100
    
    /// The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point.
    /// Defined as a value in the range [0, 2], where 2 represents the entire length/width of the card. Defaults to 0.5.
    public var minimumSwipeMargin: CGFloat = 0.5
    
    /// The pan gesture recognizer attached to the view.
    public var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    
    /// The tap gesture recognizer attached to the view.
    public var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    
    /// The location of the most recent `touchDown` event. Measured relative to the view's bounds.
    public var touchLocation: CGPoint? {
        return touchPoint
    }
    
    private var touchPoint: CGPoint?
    
    /// The member of `swipeDirections` with the highest drag percentage.
    public var activeDirection: SwipeDirection? {
        return swipeDirections.reduce((highestPercentage: 0, activeDirection: nil), { (lastResult, direction) -> (CGFloat, SwipeDirection?) in
            let swipePercent: CGFloat = dragPercentage(on: direction)
            if swipePercent > lastResult.highestPercentage {
                return (swipePercent, direction)
            }
            return lastResult
        }).activeDirection
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(tapRecognizer)
    }
    
    /// The speed of the user's drag projected onto the specified direction.
    public func dragSpeed(on direction: SwipeDirection) -> CGFloat {
        let velocity: CGPoint = panGestureRecognizer.velocity(in: superview)
        return abs(direction.point.dotProduct(with: velocity))
    }
    
    /// The percentage of the screen's bounds that the drag attains in the specified direction.
    public func dragPercentage(on direction: SwipeDirection) -> CGFloat {
        let translation: CGPoint = panGestureRecognizer.translation(in: superview)
        let normalizedTranslation: CGPoint = translation.normalizedDistance(forSize: UIScreen.main.bounds.size)
        let percentage: CGFloat = normalizedTranslation.dotProduct(with: direction.point)
        return percentage < 0 ? 0 : percentage
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
        didTap(recognizer: recognizer)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
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
    
    /// The default implementation does nothing
    open func didTap(recognizer: UITapGestureRecognizer) {}
    
    open func beginSwiping(recognizer: UIPanGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
    }
    
    /// The default implementation does nothing
    open func continueSwiping(recognizer: UIPanGestureRecognizer) {}
    
    open func endSwiping(recognizer: UIPanGestureRecognizer) {
        if let direction = activeDirection {
            if dragSpeed(on: direction) >= minimumSwipeSpeed || dragPercentage(on: direction) >= minimumSwipeMargin {
                didSwipe(recognizer: recognizer, with: direction)
                return
            }
        }
        didCancelSwipe(recognizer: recognizer)
    }
    
    /// The default implementation does nothing
    open func didSwipe(recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {}
    
    /// The default implementation does nothing
    open func didCancelSwipe(recognizer: UIPanGestureRecognizer) {}
}
