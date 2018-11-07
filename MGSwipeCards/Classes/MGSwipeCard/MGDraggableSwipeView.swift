//
//  MGDraggableSwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

open class MGDraggableSwipeView: UIViewHelper {
    
    /// The swipe directions to be recognized by the view
    open var swipeDirections: [SwipeDirection] { return SwipeDirection.allDirections }
    
    /// The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1600.
    open var minimumSwipeSpeed: CGFloat { return 1600 }
    
    /// The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2], where 2 represents the entire length or width of the card. Defaults to 0.5.
    open var minimumSwipeMargin: CGFloat { return 0.5 }
    
    /// The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2]. Defaults to `CGFloat.pi`/10.
    open var maximumRotationAngle: CGFloat { return CGFloat.pi / 10 }
    
    public private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    public private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    
    //MARK: - Initialization
    
    open override func initialize() {
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
        applySubviewRasterization()
    }
    
    ///Should return all static subviews of the card to improve performance.
    open func rasterizedSubviews() -> [UIView?] {
        return [self]
    }
    
    private func applySubviewRasterization() {
        for subview in rasterizedSubviews() {
            subview?.layer.rasterizationScale = UIScreen.main.scale
            subview?.layer.shouldRasterize = true
        }
    }
    
    //MARK: - Swipe Calculations
    
    public var activeDirection: SwipeDirection? {
        return swipeDirections.reduce((highestPercentage: 0, direction: nil), { (percentage, direction) -> (CGFloat, SwipeDirection?) in
            let swipePercent = dragPercentage(on: direction)
            if swipePercent > percentage.highestPercentage {
                return (swipePercent, direction)
            }
            return percentage
        }).direction
    }
    
    /// The velocity of the user's drag projected onto the specified direction.
    public func dragSpeed(on direction: SwipeDirection) -> CGFloat {
        let velocity = panGestureRecognizer.velocity(in: superview)
        return abs(direction.point.dotProduct(with: velocity))
    }
    
    /// The proportion of the card's initial bounds that the user's drag attains in the specified direction.
    public func dragPercentage(on direction: SwipeDirection) -> CGFloat {
        let translation = panGestureRecognizer.translation(in: superview)
        let normalizedTranslation = translation.normalizedDistance(forSize: UIScreen.main.bounds.size)
        let percentage = normalizedTranslation.dotProduct(with: direction.point)
        if percentage < 0 {
            return 0
        }
        return percentage
    }
    
    //MARK: - Gesture Recognition
    
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
    
    //MARK: - Swipe Handling & View Transformations
    
    private var rotationDirectionY: CGFloat = 1
    
    private func beginSwiping(on view: MGDraggableSwipeView, recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: self)
        if touchPoint.y < bounds.height / 2 {
            rotationDirectionY = 1
        } else {
            rotationDirectionY = -1
        }
        didBeginSwipe(on: self)
    }
    
    private func continueSwiping(on view: MGDraggableSwipeView, recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        let superviewTranslation = recognizer.translation(in: superview)
        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        let rotationAngle = max(-CGFloat.pi/2, min(rotationDirectionY * abs(maximumRotationAngle) * rotationStrength, CGFloat.pi/2))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        layer.setAffineTransform(transform)
        didContinueSwipe(on: self)
    }
    
    private func endSwiping(on view: MGDraggableSwipeView, recognizer: UIPanGestureRecognizer) {
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
    
    open func didTap(on view: MGDraggableSwipeView) {}
    
    open func didBeginSwipe(on view: MGDraggableSwipeView) {}
    
    open func didContinueSwipe(on view: MGDraggableSwipeView) {}
    
    open func didSwipe(on view: MGDraggableSwipeView, with direction: SwipeDirection) {}
    
    open func didCancelSwipe(on view: MGDraggableSwipeView) {}
}
