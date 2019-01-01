//
//  SwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

open class SwipeableView: UIViewable {
    /// The swipe directions to be recognized by the view
    public var swipeDirections: [SwipeDirection] = SwipeDirection.allDirections
    
    /// The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1100.
    public var minimumSwipeSpeed: CGFloat = 1100
    
    /// The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2], where 2 represents the entire length/width of the card. Defaults to 0.5.
    public var minimumSwipeMargin: CGFloat = 0.5
    
    /// The pan gesture recognizer attached to the view.
    public var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    /// The tap gesture recognizer attached to the view.
    public var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    /// The location of the most recent touch relative to the view's bounds. This value is set when the view recieves a tap or recogizes the beginning of a pan gesture.
    public var touchLocation: CGPoint? {
        return touchPoint
    }
    
    public var activeDirection: SwipeDirection? {
        return swipeDirections.reduce((highestPercentage: 0, activeDirection: nil), { (percentage, direction) -> (CGFloat, SwipeDirection?) in
            let swipePercent = dragPercentage(on: direction)
            if swipePercent > percentage.highestPercentage {
                return (swipePercent, direction)
            }
            return percentage
        }).activeDirection
    }
    
    private var touchPoint: CGPoint?
    private lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))

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
        didTap(on: self)
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
    
    //MARK: - Swipe Handling
    
    private func beginSwiping(on view: SwipeableView, recognizer: UIPanGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
//        if let touchPoint = touchLocation {
//            rotationDirectionY = (touchPoint.y < bounds.height / 2) ? 1 : -1
//        }
        didBeginSwipe(on: self)
    }
    
    private func continueSwiping(on view: SwipeableView, recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: self)
//        var transform = CGAffineTransform(translationX: translation.x, y: translation.y)
//        let superviewTranslation = recognizer.translation(in: superview)
//        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
//        let rotationAngle = max(-CGFloat.pi/2, min(rotationDirectionY * abs(maximumRotationAngle) * rotationStrength, CGFloat.pi/2))
//        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle))
//        layer.setAffineTransform(transform)
        didContinueSwipe(on: self)
    }
    
    private func endSwiping(on view: SwipeableView, recognizer: UIPanGestureRecognizer) {
        if let direction = activeDirection {
            if dragSpeed(on: direction) >= minimumSwipeSpeed || dragPercentage(on: direction) >= minimumSwipeMargin {
                didSwipe(on: self, with: direction)
            } else {
                didCancelSwipe(on: self)
            }
        } else {
            didCancelSwipe(on: self)
        }
    }
    
    func didTap(on view: SwipeableView) {}
    
    func didBeginSwipe(on view: SwipeableView) {}
    
    func didContinueSwipe(on view: SwipeableView) {}
    
    func didSwipe(on view: SwipeableView, with direction: SwipeDirection) {}
    
    func didCancelSwipe(on view: SwipeableView) {}
}
