//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

public protocol MGSwipeCardDelegate {

    func card(didTap card: MGSwipeCard, location: CGPoint)
    func card(didBeginSwipe card: MGSwipeCard)
    func card(didContinueSwipe card: MGSwipeCard)
    func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection)
    func card(didCancelSwipe card: MGSwipeCard)
}

open class MGSwipeCard: MGSwipeView {
    
    public var delegate: MGSwipeCardDelegate?
    
    private lazy var animator = CardAnimator(card: self)
    public var isSwipeAnimating: Bool {
        return animator.isSwipeAnimating
    }
    
    public var options = MGSwipeCardOptions()
    
    public private(set) var contentView: UIView?
    public private(set) var footerView: UIView?
    private var overlayContainer: UIView?
    private var overlays: [SwipeDirection: UIView?] = [:]
    
    public var footerIsTransparent = false {
        didSet { setNeedsLayout() }
    }
    
    public var footerHeight: CGFloat = 100 {
        didSet { setNeedsLayout() }
    }
    
    private var contentViewConstraints: [NSLayoutConstraint] = []
    private var footerViewConstraints: [NSLayoutConstraint] = []
    private var overlayContainerConstraints: [NSLayoutConstraint] = []
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutFooterView()
        layoutContentView()
        layoutOverlays()
        updateViewHierarchy()
    }
    
    private func layoutContentView() {
        guard let content = contentView else { return }
        NSLayoutConstraint.deactivate(contentViewConstraints)
        if footerView == nil || footerIsTransparent {
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
    }
    
    private func updateViewHierarchy() {
        if contentView != nil {
            sendSubview(toBack: contentView!)
        }
        if overlayContainer != nil {
            bringSubview(toFront: overlayContainer!)
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
        overlays[direction]??.layer.shouldRasterize = true
        overlays[direction]??.layer.rasterizationScale = UIScreen.main.scale
        overlays[direction]??.alpha = 0
        overlayContainer?.addSubview(overlay)
        _ = overlay.anchor(top: overlayContainer?.topAnchor, left: overlayContainer?.leftAnchor, bottom: overlayContainer?.bottomAnchor, right: overlayContainer?.rightAnchor)
        setNeedsLayout()
    }
    
    public func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return overlays[direction] ?? nil
    }

    //MARK: - Gesture Handling
    
    private var rotationDirectionY: CGFloat = 1
    
    private func alphaForOverlay(with direction: SwipeDirection) -> CGFloat {
        if direction != activeDirection { return 0 }
        let totalPercentage = swipeDirections.reduce(0) { (percentage, direction) in
            return percentage + swipePercentage(on: direction)
        }
        return min((2 * swipePercentage(on: direction) - totalPercentage)/options.minimumSwipeMargin, 1)
    }
    
    open override func didTap(on view: MGSwipeView, recognizer: UITapGestureRecognizer) {
        delegate?.card(didTap: self, location: recognizer.location(in: self))
    }
    
    open override func beginSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        animator.removeAllSwipeAnimations()
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        let touchPoint = recognizer.location(in: self)
        if touchPoint.y < bounds.height / 2 {
            rotationDirectionY = 1
        } else {
            rotationDirectionY = -1
        }
        delegate?.card(didBeginSwipe: self)
    }
    
    open override func continueSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        
        let superviewTranslation = recognizer.translation(in: superview)
        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        let rotationAngle = max(-CGFloat.pi/2, min(rotationDirectionY * abs(options.maximumRotationAngle) * rotationStrength, CGFloat.pi/2))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        
        layer.setAffineTransform(transform)

        swipeDirections.forEach { direction in
            overlays[direction]??.alpha = alphaForOverlay(with: direction)
        }
        
        delegate?.card(didContinueSwipe: self)
    }
    
    open override func endSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        guard let direction = activeDirection else { return }
        
        if swipeSpeed(on: direction) >= options.minimumSwipeSpeed {
            isUserInteractionEnabled = false
            delegate?.card(didSwipe: self, with: direction)
            animator.applySwipeAnimation(direction: direction, translation: recognizer.translation(in: superview), fast: true) { _ in
                self.removeFromSuperview()
            }
            return
        }
        
        if swipePercentage(on: direction) >= options.minimumSwipeMargin {
            isUserInteractionEnabled = false
            delegate?.card(didSwipe: self, with: direction)
            animator.applySwipeAnimation(direction: direction, translation: recognizer.translation(in: superview)) { _ in
                self.removeFromSuperview()
            }
            return
        }
        
        delegate?.card(didCancelSwipe: self)
        animator.applyResetAnimation { finished in
            if finished {
                self.layer.shouldRasterize = false
                self.layer.transform = CATransform3DIdentity
            }
        }
    }
    
    //MARK: - Actions
    
    public func swipe(withDirection direction: SwipeDirection) {
        if !swipeDirections.contains(direction) { return }
        isUserInteractionEnabled = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        delegate?.card(didSwipe: self, with: direction)
        
        animator.applyForcedSwipeAnimation(direction: direction) { _ in
            self.removeFromSuperview()
        }
    }
    
    public func removeAllSwipeAnimations() {
        animator.removeAllSwipeAnimations()
    }
        
}









