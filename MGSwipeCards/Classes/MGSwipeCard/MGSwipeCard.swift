//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import pop

public protocol MGSwipeCardDelegate {
    func card(didTap card: MGSwipeCard)
    func card(didBeginSwipe card: MGSwipeCard)
    func card(didContinueSwipe card: MGSwipeCard)
    func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection)
    func card(didUndo card: MGSwipeCard, from direction: SwipeDirection)
    func card(didCancelSwipe card: MGSwipeCard)
}

/**
 A wrapper around `MGDraggableSwipeView` which provides UI options for the user and swipe animations.
*/
open class MGSwipeCard: MGDraggableSwipeView {
    
    public var delegate: MGSwipeCardDelegate?
    
    /**
    The minimum duration of the off-screen swipe animation. Measured in seconds. Defaults to 0.8.
    */
    open var cardSwipeAnimationDuration: TimeInterval = 0.8
    
    open var overlayFadeAnimationDuration: TimeInterval = 0.15
    
    open var undoAnimationDuration: TimeInterval = 0.2
    
    /**
     The effective bounciness of the swipe spring animation upon a cancelled swipe. Higher values increase spring movement range resulting in more oscillations and springiness. Defined as a value in the range [0, 20]. Defaults to 12.
    */
    open var resetAnimationSpringBounciness: CGFloat = 12.0
    
    /**
     The effective speed of the spring animation upon a cancelled swipe. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20]. Defaults to 20.
     */
    open var resetAnimationSpringSpeed: CGFloat = 20.0
    
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
        
        if contentView != nil {
            sendSubviewToBack(contentView!)
        }
        if overlayContainer != nil {
            bringSubviewToFront(overlayContainer!)
        }
    }
    
    private func layoutFooterView() {
        guard let footer = footerView else { return }
        NSLayoutConstraint.deactivate(footerViewConstraints)
        footerViewConstraints = footer.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: footerHeight)
    }
    
    private func layoutContentView() {
        guard let content = contentView else { return }
        NSLayoutConstraint.deactivate(contentViewConstraints)
        
        if let footer = footerView, !footerIsTransparent {
            contentViewConstraints = content.anchor(top: topAnchor, left: leftAnchor, bottom: footer.topAnchor, right: rightAnchor)
        } else {
            contentViewConstraints = content.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        }
    }
    
    private func layoutOverlays() {
        guard let overlayContainer = overlayContainer else { return }
        NSLayoutConstraint.deactivate(overlayContainerConstraints)
        if let footer = footerView {
            overlayContainerConstraints = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: footer.topAnchor, right: rightAnchor)
        } else {
            overlayContainerConstraints = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        }
    }
    
    //MARK: - Setters/Getters
    
    open func setContentView(_ content: UIView?) {
        guard let content = content else { return }
        contentView = content
        addSubview(content)
        setNeedsLayout()
    }
    
    open func setFooterView(_ footer: UIView?) {
        guard let footer = footer else { return }
        footerView = footer
        addSubview(footer)
        setNeedsLayout()
    }
    
    open func setOverlay(forDirection direction: SwipeDirection, overlay: UIView?) {
        guard let overlay = overlay else { return }
        if overlayContainer == nil {
            overlayContainer = UIView()
            addSubview(overlayContainer!)
        }
        overlays[direction]??.removeFromSuperview()
        overlays[direction] = overlay
        overlays[direction]??.alpha = 0
        overlayContainer?.addSubview(overlay)
        _ = overlay.anchor(top: overlayContainer?.topAnchor, left: overlayContainer?.leftAnchor, bottom: overlayContainer?.bottomAnchor, right: overlayContainer?.rightAnchor)
        setNeedsLayout()
    }
    
    public func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return overlays[direction] ?? nil
    }
    
    //MARK: - Main Methods
    
    public func swipe(direction: SwipeDirection, completion: (() ->())? = nil) {
        delegate?.card(didSwipe: self, with: direction)
        isUserInteractionEnabled = false
        POPAnimator.applySwipeAnimation(to: self, direction: direction, forced: true) { finished in
            if finished {
                self.removeFromSuperview()
                completion?()
            }
        }
    }
    
    public func undo(from direction: SwipeDirection, completion: (() ->())? = nil) {
        delegate?.card(didUndo: self, from: direction)
        isUserInteractionEnabled = false
        POPAnimator.applyUndoAnimation(to: self, from: direction) { finished in
            if finished {
                self.isUserInteractionEnabled = true
                completion?()
            }
        }
    }
    
    //MARK: MGDraggableSwipeView Overrides
    
    open override func didTap(on view: MGDraggableSwipeView) {
        delegate?.card(didTap: self)
    }
    
    open override func didBeginSwipe(on view: MGDraggableSwipeView) {
        delegate?.card(didBeginSwipe: self)
        POPAnimator.removeAllCardAnimations(on: self)
    }
    
    open override func didContinueSwipe(on view: MGDraggableSwipeView) {
        delegate?.card(didContinueSwipe: self)
        swipeDirections.forEach { direction in
            overlay(forDirection: direction)?.alpha = alphaForOverlay(with: direction)
        }
    }
    
    private func alphaForOverlay(with direction: SwipeDirection) -> CGFloat {
        if direction != activeDirection { return 0 }
        let totalPercentage = swipeDirections.reduce(0) { (percentage, direction) in
            return percentage + swipePercentage(on: direction)
        }
        return min((2 * swipePercentage(on: direction) - totalPercentage)/minimumSwipeMargin, 1)
    }
    
    open override func didSwipe(on view: MGDraggableSwipeView, with direction: SwipeDirection) {
        delegate?.card(didSwipe: self, with: direction)
        isUserInteractionEnabled = false
        POPAnimator.applySwipeAnimation(to: self, direction: direction, forced: false) { finished in
            if finished {
                self.removeFromSuperview()
            }
        }
    }
    
    open override func didCancelSwipe(on view: MGDraggableSwipeView) {
        delegate?.card(didCancelSwipe: self)
        POPAnimator.applyResetAnimation(to: self, completion: nil)
    }
}
