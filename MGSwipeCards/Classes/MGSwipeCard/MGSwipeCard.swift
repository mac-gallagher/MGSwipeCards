//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class MGSwipeCard: MGSwipeView {
    
    public var delegate: MGSwipeCardDelegate?
    
    public private(set) var contentView: UIView?
    public private(set) var footerView: UIView?
    private var overlayContainer: UIView?
    private var overlays: [SwipeDirection: UIView?] = [:]
    
    public var footerHeight: CGFloat = 100 {
        didSet {
            layoutSubviews()
        }
    }
    
    private var contentViewConstraints: [NSLayoutConstraint] = []
    private var footerViewConstraints: [NSLayoutConstraint] = []
    private var overlayContainerConstraints: [NSLayoutConstraint] = []
    private var overlayConstraintsForDirection: [SwipeDirection: [NSLayoutConstraint]] = [:]
    
    ///The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1600.
    public var minimumSwipeSpeed: CGFloat = 1600
    
    ///The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2].
    ///Defaults to 0.5.
    public var minimumSwipeMargin: CGFloat = 0.5
    
    ///The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2]. Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10
    
    ///The minimum duration of the off-screen swipe animation. Measured in seconds. Defaults to 0.8.
    public var swipeAnimationMinimumDuration: TimeInterval = 0.8
    
    ///The effective bounciness of the swipe spring animation upon a cancelled swipe. Higher values increase spring movement range resulting in more oscillations and springiness.
    ///Defined as a value in the range [0, 20]. Defaults to 12.
    public var resetAnimationSpringBounciness: CGFloat = 12.0
    
    ///The effective speed of the spring animation upon a cancelled swipe. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20].
    ///Defaults to 20.
    public var resetAnimationSpringSpeed: CGFloat = 20.0
    
    //MARK: - Initialization
    
    public override init() {
        super.init()
        sharedInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = .black
        clipsToBounds = true
    }
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutFooterView()
        layoutOverlays()
    }
    
    private func layoutContentView() {
        guard let content = contentView else { return }
        NSLayoutConstraint.deactivate(contentViewConstraints)
        if footerView == nil {
            contentViewConstraints = content.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        } else {
            contentViewConstraints = content.anchor(top: topAnchor, left: leftAnchor, bottom: footerView!.topAnchor, right: rightAnchor)
        }
    }
    
    private func layoutFooterView() {
        guard let footer = footerView else { return }
        NSLayoutConstraint.deactivate(footerViewConstraints)
        footerViewConstraints = footer.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: footerHeight)
    }
    
    private func layoutOverlays() {
        guard let overlayContainer = overlayContainer else { return }
        NSLayoutConstraint.deactivate(overlayContainerConstraints)
        if footerView == nil {
            overlayContainerConstraints = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        } else {
            overlayContainerConstraints = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: footerView!.topAnchor, right: rightAnchor)
        }
        
        //MODIFY
        for direction in swipeDirections {
            if let overlayConstraints = overlayConstraintsForDirection[direction] {
                NSLayoutConstraint.deactivate(overlayConstraints)
            }
            overlayConstraintsForDirection[direction] = overlays[direction]??.anchor(top: overlayContainer.topAnchor, left: overlayContainer.leftAnchor, bottom: overlayContainer.bottomAnchor, right: overlayContainer.rightAnchor)
        }
    }
    
    //MARK: - Setters/Getters
    
    public func setContentView(_ content: UIView?) {
        guard let content = content else { return }
        contentView = content
        addSubview(contentView!)
        setNeedsLayout()
    }
    
    public func setFooterView(_ footer: UIView?) {
        guard let footer = footer else { return }
        footerView = footer
        addSubview(footerView!)
        setNeedsLayout()
    }
    
    public func setOverlay(forDirection direction: SwipeDirection, overlay: UIView?) {
        guard let overlay = overlay else { return }
        if overlayContainer == nil {
            overlayContainer = UIView()
            addSubview(overlayContainer!)
        }
        overlays[direction]??.removeFromSuperview()
        overlays[direction] = overlay
        overlays[direction]??.alpha = 0
        overlayContainer?.addSubview(overlay)
        setNeedsLayout()
    }
    
    public func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return overlays[direction] ?? nil
    }

    //MARK: - Swipe/Tap Handling
    
    open override func didTap(on view: MGSwipeView, recognizer: UITapGestureRecognizer) {
        delegate?.didTap(on: self, recognizer: recognizer)
    }
    
    private var rotationDirectionY: CGFloat = 1
    
    open override func beginSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        removeAllAnimations()
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        let touchPoint = recognizer.location(in: self)
        if touchPoint.y < bounds.height / 2 {
            rotationDirectionY = 1
        } else {
            rotationDirectionY = -1
        }
        delegate?.beginSwiping(on: self)
    }
    
    open override func continueSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        
        let superviewTranslation = recognizer.translation(in: superview)
        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        let rotationAngle = max(-CGFloat.pi/2, min(rotationDirectionY * abs(maximumRotationAngle) * rotationStrength, CGFloat.pi/2))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        
        layer.setAffineTransform(transform)
        
        for direction in swipeDirections {
            overlays[direction]??.alpha = alphaForOverlay(withDirection: direction)
        }
        delegate?.continueSwiping(on: self)
    }
    
    private func alphaForOverlay(withDirection direction: SwipeDirection) -> CGFloat {
        if direction != activeDirection { return 0 }
        let totalPercentage = swipeDirections.reduce(0) { (percentage, direction) in
            return percentage + (swipePercentage[direction] ?? 0)
        }
        return min((2 * (swipePercentage[direction] ?? 0) - totalPercentage)/minimumSwipeMargin, 1)
    }

    open override func endSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        guard let direction = activeDirection, let superview = superview else { return }
        if (swipeSpeed[direction] ?? 0) >= minimumSwipeSpeed {
            performSwipeAnimation(direction: direction, translation: panGestureRecognizer.translation(in: superview), didSwipeFast: true)
            delegate?.didSwipe(on: self, with: direction)
        } else if (swipePercentage[direction] ?? 0) >= minimumSwipeMargin {
            performSwipeAnimation(direction: direction, translation: panGestureRecognizer.translation(in: superview))
            delegate?.didSwipe(on: self, with: direction)
        } else {
            resetCardAnimation()
            delegate?.didCancelSwipe(on: self)
        }
    }
    
    //Move this to animator and card stack. Make private
    public func performSwipe(withDirection direction: SwipeDirection) {
        if !swipeDirections.contains(direction) { return }
        isUserInteractionEnabled = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.overlays[direction]??.alpha = 1
        }) { (_) in
            self.performSwipeAnimation(direction: direction, translation: direction.point, randomRotationDirection: true)
            self.delegate?.didSwipe(on: self, with: direction)
        }
    }
    
}









