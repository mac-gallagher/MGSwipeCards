//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

public protocol MGSwipeCardDelegate {
    func card(didTap card: MGSwipeCard)
    func card(didBeginSwipe card: MGSwipeCard)
    func card(didContinueSwipe card: MGSwipeCard)
    func card(didCancelSwipe card: MGSwipeCard)
    func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection, forced: Bool)
    func card(didReverseSwipe card: MGSwipeCard, from direction: SwipeDirection)
}

/**
 A wrapper around `SwipeView` which provides UI customization and animations.
 */
open class MGSwipeCard: SwipeView {
    public var delegate: MGSwipeCardDelegate?
    
    public var animationOptions: MGCardAnimationOptions = .defaultOptions
    
    public var isFooterTransparent: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var footerHeight: CGFloat = 100 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var content: UIView? {
        didSet {
            if let content = content {
                oldValue?.removeFromSuperview()
                addSubview(content)
            }
        }
    }
    
    public var footer: UIView? {
        didSet {
            if let footer = footer {
                oldValue?.removeFromSuperview()
                addSubview(footer)
            }
        }
    }
    
    public var leftOverlay: UIView? {
        return overlays[.left]
    }
    
    public var upOverlay: UIView? {
        return overlays[.up]
    }
    
    public var rightOverlay: UIView? {
        return overlays[.right]
    }
    
    public var downOverlay: UIView? {
        return overlays[.down]
    }
    
    var rotationDirectionY: CGFloat {
        if let touchPoint = touchLocation {
            return (touchPoint.y < bounds.height / 2) ? 1 : -1
        }
        return 0
    }
    
    var overlayContainer = UIView()
    var overlays: [SwipeDirection: UIView] = [:]
    
    private var animator: CardAnimator = MGCardAnimator.shared
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(animator: CardAnimator) {
        self.init(frame: .zero)
        self.animator = animator
    }
    
    private func initialize() {
        addSubview(overlayContainer)
    }
    
    public func setOverlay(_ overlay: UIView?, forDirection direction: SwipeDirection) {
        overlays[direction]?.removeFromSuperview()
        overlays[direction] = overlay
        if let overlay = overlay {
            overlayContainer.addSubview(overlay)
            overlay.alpha = 0
        }
        setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        footer?.frame = CGRect(x: 0, y: bounds.height - footerHeight, width: bounds.width, height: footerHeight)
        layoutContentView()
        layoutOverlays()
    }
    
    private func layoutContentView() {
        guard let content = content else { return }
        if let _ = footer, !isFooterTransparent {
            content.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - footerHeight)
        } else {
            content.frame = bounds
        }
        sendSubviewToBack(content)
    }
    
    private func layoutOverlays() {
        if let _ = footer {
            overlayContainer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - footerHeight)
        } else {
            overlayContainer.frame = bounds
        }
        bringSubviewToFront(overlayContainer)
        
        for (_, overlay) in overlays {
            overlay.frame = overlayContainer.bounds
        }
    }
    
    //MARK: - Overrides
    
    override open func didTap(recognizer: UITapGestureRecognizer) {
        super.didTap(recognizer: recognizer)
        delegate?.card(didTap: self)
    }
    
    override open func beginSwiping(recognizer: UIPanGestureRecognizer) {
        super.beginSwiping(recognizer: recognizer)
        delegate?.card(didBeginSwipe: self)
        animator.removeAllAnimations(on: self)
    }
    
    override open func continueSwiping(recognizer: UIPanGestureRecognizer) {
        super.continueSwiping(recognizer: recognizer)
        delegate?.card(didContinueSwipe: self)
        
        layer.setAffineTransform(dragTransform(recognizer: recognizer))
        
        for (direction, overlay) in overlays {
            overlay.alpha = overlayPercentage(forDirection: direction)
        }
    }
    
    func dragTransform(recognizer: UIPanGestureRecognizer) -> CGAffineTransform {
        let dragTranslation: CGPoint = recognizer.translation(in: self)
        let translation: CGAffineTransform = CGAffineTransform(translationX: dragTranslation.x, y: dragTranslation.y)
        let rotation: CGAffineTransform = CGAffineTransform(rotationAngle: dragRotationAngle(recognizer: recognizer))
        return translation.concatenating(rotation)
    }
    
    func dragRotationAngle(recognizer: UIPanGestureRecognizer) -> CGFloat {
        let superviewTranslation: CGPoint = recognizer.translation(in: superview)
        let rotationStrength: CGFloat = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        return rotationDirectionY * rotationStrength * abs(animationOptions.maximumRotationAngle) 
    }
    
    func overlayPercentage(forDirection direction: SwipeDirection) -> CGFloat {
        if direction != activeDirection { return 0 }
        let totalPercentage: CGFloat = swipeDirections.reduce(0) { (percentage, direction) in
            return percentage + dragPercentage(on: direction)
        }
        return min((2 * dragPercentage(on: direction) - totalPercentage) / minimumSwipeMargin, 1)
    }
    
    override open func didSwipe(recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {
        super.didSwipe(recognizer: recognizer, with: direction)
        swipeAction(direction: direction, animated: true, forced: false)
    }
    
    override open func didCancelSwipe(recognizer: UIPanGestureRecognizer) {
        animator.animateReset(self) { _ in
            self.delegate?.card(didCancelSwipe: self)
        }
    }
    
    //MARK: - Main Methods
    
    public func swipe(direction: SwipeDirection, animated: Bool) {
        swipeAction(direction: direction, animated: animated, forced: true)
    }
    
    private func swipeAction(direction: SwipeDirection, animated: Bool, forced: Bool) {
        isUserInteractionEnabled = false
        if animated {
            animator.animateSwipe(self, direction: direction, forced: forced) { finished in
                if finished {
                    self.delegate?.card(didSwipe: self, with: direction, forced: forced)
                }
            }
        } else {
            animator.swipe(self, direction: direction)
            delegate?.card(didSwipe: self, with: direction, forced: forced)
        }
    }
    
    public func reverseSwipe(from direction: SwipeDirection, animated: Bool) {
        isUserInteractionEnabled = false
        if animated {
            animator.animateReverseSwipe(self, from: direction) { finished in
                if finished {
                    self.finishReverseSwipe(direction: direction)
                }
            }
        } else {
            animator.reverseSwipe(self)
            finishReverseSwipe(direction: direction)
        }
    }
    
    private func finishReverseSwipe(direction: SwipeDirection) {
        isUserInteractionEnabled = true
        delegate?.card(didReverseSwipe: self, from: direction)
    }
}
