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
    func card(didReverseSwipe card: MGSwipeCard, from direction: SwipeDirection)
    func card(didCancelSwipe card: MGSwipeCard)
}

/**
 A wrapper around `MGDraggableSwipeView` which provides UI customization and swipe animations.
*/
open class MGSwipeCard: MGDraggableSwipeView {
    
    open var animationOptions: CardAnimationOptions { return .defaultOptions }

    open var footerIsTransparent: Bool { return false }
    open var footerHeight: CGFloat { return 100 }
    
    public private(set) var contentView: UIView?
    public private(set) var footerView: UIView?
    
    var delegate: MGSwipeCardDelegate?
    
    private var overlayContainer: UIView?
    private var overlays: [SwipeDirection: UIView?] = [:]
    
    private var contentViewConstraints: [NSLayoutConstraint] = []
    private var footerViewConstraints: [NSLayoutConstraint] = []
    private var overlayContainerConstraints: [NSLayoutConstraint] = []
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutFooterView()
        layoutContentView()
        layoutOverlays()
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
            contentViewConstraints = content.anchorToSuperview()
        }
        sendSubviewToBack(content)
    }
    
    private func layoutOverlays() {
        guard let overlayContainer = overlayContainer else { return }
        NSLayoutConstraint.deactivate(overlayContainerConstraints)
        if let footer = footerView {
            overlayContainerConstraints = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: footer.topAnchor, right: rightAnchor)
        } else {
            overlayContainerConstraints = overlayContainer.anchorToSuperview()
        }
        bringSubviewToFront(overlayContainer)
    }
    
    //MARK: - Setters/Getters
    
    open func setContentView(_ content: UIView?) {
        guard let content = content else { return }
        contentView?.removeFromSuperview()
        contentView = content
        addSubview(content)
        setNeedsLayout()
    }
    
    open func setFooterView(_ footer: UIView?) {
        guard let footer = footer else { return }
        footerView?.removeFromSuperview()
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
        _ = overlay.anchorToSuperview()
        setNeedsLayout()
    }
    
    public func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return overlays[direction] ?? nil
    }
    
    //MARK: - Main Methods
    
    public func swipe(direction: SwipeDirection, completion: ((Bool) ->())?) {
        delegate?.card(didSwipe: self, with: direction)
        isUserInteractionEnabled = false
        POPAnimator.applySwipeAnimation(to: self, direction: direction, forced: true) { finished in
            if finished {
                self.removeFromSuperview()
            }
            completion?(finished)
        }
    }
    
    public func reverseSwipe(from direction: SwipeDirection, completion: ((Bool) ->())?) {
        delegate?.card(didReverseSwipe: self, from: direction)
        isUserInteractionEnabled = false
        POPAnimator.applyUndoAnimation(to: self, from: direction) { finished in
            if finished {
                self.isUserInteractionEnabled = true
            }
            completion?(finished)
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
            return percentage + dragPercentage(on: direction)
        }
        return min((2 * dragPercentage(on: direction) - totalPercentage)/minimumSwipeMargin, 1)
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
