//
//  SwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

protocol SwipeViewDelegate {
    func didTap(on view: SwipeView)
    func didBeginSwipe(on view: SwipeView)
    func didContinueSwipe(on view: SwipeView)
    func didSwipe(on view: SwipeView, with direction: SwipeDirection)
    func didCancelSwipe(on view: SwipeView)
}

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
    
    var swipeViewDelegate: SwipeViewDelegate?
    
    override func initialize() {
        addGestureRecognizer(panRecognizer)
        addGestureRecognizer(tapRecognizer)
    }
    
    /// The speed of the user's drag projected onto the specified direction.
    func dragSpeed(on direction: SwipeDirection) -> CGFloat {
        let velocity = panRecognizer.velocity(in: superview)
        return abs(direction.point.dotProduct(with: velocity))
    }
    
    /// The percentage of the card's bounds that the drag attains in the specified direction.
    func dragPercentage(on direction: SwipeDirection) -> CGFloat {
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
        swipeViewDelegate?.didTap(on: self)
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
    
    private func beginSwiping(recognizer: UIPanGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
        swipeViewDelegate?.didBeginSwipe(on: self)
    }
    
    private func continueSwiping(recognizer: UIPanGestureRecognizer) {
        swipeViewDelegate?.didContinueSwipe(on: self)
    }
    
    private func endSwiping(recognizer: UIPanGestureRecognizer) {
        if let direction = activeDirection {
            if dragSpeed(on: direction) >= minimumSwipeSpeed || dragPercentage(on: direction) >= minimumSwipeMargin {
                swipeViewDelegate?.didSwipe(on: self, with: direction)
            } else {
                swipeViewDelegate?.didCancelSwipe(on: self)
            }
        } else {
            swipeViewDelegate?.didCancelSwipe(on: self)
        }
    }
}
