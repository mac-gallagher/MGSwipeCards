//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

//MARK: - MGSwipeCardDelegate

protocol MGSwipeCardDelegate {
    func card(didTap card: MGSwipeCard)
    func card(didBeginSwipe card: MGSwipeCard)
    func card(didContinueSwipe card: MGSwipeCard)
    func card(willSwipe card: MGSwipeCard, with direction: SwipeDirection, forced: Bool)
    func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection, forced: Bool)
    func card(willUndo card: MGSwipeCard, from direction: SwipeDirection)
    func card(didUndo card: MGSwipeCard, from direction: SwipeDirection)
    func card(willCancelSwipe card: MGSwipeCard)
    func card(didCancelSwipe card: MGSwipeCard)
}

//MARK: - MGSwipeCardDelegate (non-implemented methods)

extension MGSwipeCardDelegate {
    func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection, forced: Bool) {}
    func card(willCancelSwipe card: MGSwipeCard) {}
}

//MARK: - MGSwipeCard

/**
 A wrapper around `MGDraggableSwipeView` which provides UI customization and swipe animations.
 */
open class MGSwipeCard: DraggableSwipeView {
    public var animationOptions: CardAnimationOptions = .defaultOptions
    
    public var isFooterTransparent: Bool = false
    public var footerHeight: CGFloat = 100
    
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
        layoutOverlays()
    }
    
    open override func rasterizedSubviews() -> [UIView?] {
        return [content, footer]
    }
    
    private func layoutFooterView() {
        footer = footerView()
        if let footer = footer {
            addSubview(footer)
            _ = footer.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: footerHeight)
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
    
    private func layoutOverlays() {
        addSubview(overlayContainer)
        if let footer = footer {
            _ = overlayContainer.anchor(top: topAnchor, left: leftAnchor, bottom: footer.topAnchor, right: rightAnchor)
        } else {
            _ = overlayContainer.anchorToSuperview()
        }
        bringSubviewToFront(overlayContainer)
        
        for direction in swipeDirections {
            layoutOverlay(forDirection: direction)
        }
    }
    
    private func layoutOverlay(forDirection direction: SwipeDirection) {
        if let overlayView = overlay(forDirection: direction) {
            overlays[direction] = overlayView
            overlayView.alpha = 0
            overlayContainer.addSubview(overlayView)
            _ = overlayView.anchorToSuperview()
        }
    }
    
    //MARK: - Main Methods
    
    public func swipe(direction: SwipeDirection) {
        swipeAction(direction: direction, forced: true)
    }
    
    private func swipeAction(direction: SwipeDirection, forced: Bool) {
        isUserInteractionEnabled = false
        delegate?.card(willSwipe: self, with: direction, forced: forced)
        CardAnimator.swipe(card: self, direction: direction, forced: forced) { (finished) in
            if finished {
                self.isUserInteractionEnabled = true
                self.removeFromSuperview()
                self.delegate?.card(didSwipe: self, with: direction, forced: forced)
            }
        }
    }
    
    public func undoSwipe(from direction: SwipeDirection) {
        isUserInteractionEnabled = false
        delegate?.card(willUndo: self, from: direction)
        CardAnimator.undo(card: self, from: direction) { (finished) in
            if finished {
                self.isUserInteractionEnabled = true
                self.delegate?.card(didUndo: self, from: direction)
            }
        }
    }
    
    //MARK: MGDraggableSwipeView Overrides
    
    override func didTap(on view: DraggableSwipeView) {
        delegate?.card(didTap: self)
    }
    
    override func didBeginSwipe(on view: DraggableSwipeView) {
        delegate?.card(didBeginSwipe: self)
        CardAnimator.removeAllAnimations(on: self)
    }
    
    override func didContinueSwipe(on view: DraggableSwipeView) {
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
    
    override func didSwipe(on view: DraggableSwipeView, with direction: SwipeDirection) {
        swipeAction(direction: direction, forced: false)
    }
    
    override func didCancelSwipe(on view: DraggableSwipeView) {
        delegate?.card(didCancelSwipe: self)
        CardAnimator.reset(card: self) { _ in
            self.delegate?.card(willCancelSwipe: self)
        }
    }
}
