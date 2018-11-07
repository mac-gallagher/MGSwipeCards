//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import pop

protocol MGSwipeCardDelegate {
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

    open var isFooterTransparent: Bool { return false }
    open var footerHeight: CGFloat { return 100 }
    
    public private(set) var content: UIView?
    public private(set) var footer: UIView?
    public private(set) var overlays: [SwipeDirection: UIView] = [:]
    
    var delegate: MGSwipeCardDelegate?
    
    private var overlayContainer = UIView()
    
    //MARK: - Getters
    
    open func contentView() -> UIView? {
        return nil
    }
    
    open func footerView() -> UIView? {
        return nil
    }
    
    open func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return nil
    }
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutFooterView()
        layoutContentView()
        layoutOverlayContainer()
        layoutOverlays()
    }
    
    open override func rasterizedSubviews() -> [UIView?] {
        return [content, footer]
    }
    
    private func layoutFooterView() {
        footer = footerView()
        if let footer = footer {
            addSubview(footer)
            _ = footer.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: footerHeight)
        }
    }
    
    private func layoutContentView() {
        content = contentView()
        if let content = content {
            addSubview(content)
            if let footer = footer, !isFooterTransparent {
                _ = content.anchor(top: topAnchor, left: leftAnchor, bottom: footer.topAnchor, right: rightAnchor)
            } else {
                _ = content.anchorToSuperview()
            }
            sendSubviewToBack(content)
        }
    }
    
    private func layoutOverlayContainer() {
        addSubview(overlayContainer)
        if let footer = footer {
            _ = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: footer.topAnchor, right: rightAnchor)
        } else {
            _ = overlayContainer.anchorToSuperview()
        }
        bringSubviewToFront(overlayContainer)
    }
    
    private func layoutOverlays() {
        for direction in swipeDirections {
            if let overlayView = overlay(forDirection: direction) {
                overlays[direction] = overlayView
                overlayView.alpha = 0
                overlayContainer.addSubview(overlayView)
                _ = overlayView.anchorToSuperview()
            }
        }
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
        for (direction, overlay) in overlays {
            overlay.alpha = alphaForOverlay(with: direction)
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
