//
//  MGDraggableSwipeView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

open class DraggableSwipeView: UIViewHelper {
    /// The swipe directions to be recognized by the view
    public var swipeDirections: [SwipeDirection] = SwipeDirection.allDirections
    
    /// The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1000.
    public var minimumSwipeSpeed: CGFloat = 1100
    
    /// The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2], where 2 represents the entire length or width of the card. Defaults to 0.5.
    public var minimumSwipeMargin: CGFloat = 0.5
    
    /// The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2]. Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10
    
    public private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    public private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))

    var touchPoint: CGPoint?
    
    //MARK: - Initialization
    
    override func initialize() {
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
    
    var activeDirection: SwipeDirection? {
        return swipeDirections.reduce((highestPercentage: 0, direction: nil), { (percentage, direction) -> (CGFloat, SwipeDirection?) in
            let swipePercent = dragPercentage(on: direction)
            if swipePercent > percentage.highestPercentage {
                return (swipePercent, direction)
            }
            return percentage
        }).direction
    }
    
    /// The velocity of the user's drag projected onto the specified direction.
    func dragSpeed(on direction: SwipeDirection) -> CGFloat {
        let velocity = panGestureRecognizer.velocity(in: superview)
        return abs(direction.point.dotProduct(with: velocity))
    }
    
    /// The proportion of the card's initial bounds that the user's drag attains in the specified direction.
    func dragPercentage(on direction: SwipeDirection) -> CGFloat {
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
    
    private func beginSwiping(on view: DraggableSwipeView, recognizer: UIPanGestureRecognizer) {
        touchPoint = recognizer.location(in: self)
        if let touchPoint = touchPoint {
            rotationDirectionY = (touchPoint.y < bounds.height / 2) ? 1 : -1
        }
        didBeginSwipe(on: self)
    }
    
    private func continueSwiping(on view: DraggableSwipeView, recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        let superviewTranslation = recognizer.translation(in: superview)
        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        let rotationAngle = max(-CGFloat.pi/2, min(rotationDirectionY * abs(maximumRotationAngle) * rotationStrength, CGFloat.pi/2))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        layer.setAffineTransform(transform)
        didContinueSwipe(on: self)
    }
    
    private func endSwiping(on view: DraggableSwipeView, recognizer: UIPanGestureRecognizer) {
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
    
    func didTap(on view: DraggableSwipeView) {}
    
    func didBeginSwipe(on view: DraggableSwipeView) {}
    
    func didContinueSwipe(on view: DraggableSwipeView) {}
    
    func didSwipe(on view: DraggableSwipeView, with direction: SwipeDirection) {}
    
    func didCancelSwipe(on view: DraggableSwipeView) {}
}
