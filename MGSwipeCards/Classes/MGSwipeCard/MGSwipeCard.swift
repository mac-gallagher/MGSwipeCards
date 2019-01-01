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
    func card(willSwipe card: MGSwipeCard, with direction: SwipeDirection, animated: Bool, forced: Bool)
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
open class MGSwipeCard: SwipeableView {
    public var animationOptions: CardAnimationOptions = .defaultOptions
    
    /// The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2]. Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10
    
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
            oldValue?.removeFromSuperview()
            if let content = content {
                addSubview(content)
            }
        }
    }
    
    public var footer: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let footer = footer {
                addSubview(footer)
            }
        }
    }
    
    public var leftOverlay: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            addOverlay(leftOverlay, forDirection: .left)
        }
    }
    
    public var upOverlay: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            addOverlay(upOverlay, forDirection: .up)
        }
    }
    
    public var rightOverlay: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            addOverlay(rightOverlay, forDirection: .right)
        }
    }
    
    public var downOverlay: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            addOverlay(downOverlay, forDirection: .down)
        }
    }
    
    var delegate: MGSwipeCardDelegate?
    
    var overlays: [SwipeDirection: UIView] = [:]
    private var overlayContainer = UIView()
    
    //MARK: - Initialization
    
    override func initialize() {
        super.initialize()
        addSubview(overlayContainer)
    }
    
    private func addOverlay(_ overlay: UIView?, forDirection direction: SwipeDirection) {
        overlays.removeValue(forKey: direction)
        if let overlay = overlay {
            overlayContainer.addSubview(overlay)
            overlays[direction] = overlay
            overlay.alpha = 0
        }
    }
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        footer?.frame = CGRect(x: 0, y: bounds.height - footerHeight, width: bounds.width, height: footerHeight)
        layoutContentView()
        layoutOverlays()
    }
    
//    open override func rasterizedSubviews() -> [UIView?] {
//        return [content, footer]
//    }
    
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
    
    //MARK: - Main Methods
    
    public func swipe(direction: SwipeDirection, animated: Bool) {
        swipeAction(direction: direction, animated: animated, forced: true)
    }
    
    private func swipeAction(direction: SwipeDirection, animated: Bool, forced: Bool) {
        isUserInteractionEnabled = false
        delegate?.card(willSwipe: self, with: direction, animated: animated, forced: forced)
        if animated {
            CardAnimator.swipe(card: self, direction: direction, forced: forced) { (finished) in
                if finished {
                    self.finishSwipe(direction: direction, forced: forced)
                }
            }
        } else {
            finishSwipe(direction: direction, forced: forced)
        }
    }
    
    private func finishSwipe(direction: SwipeDirection, forced: Bool) {
        isUserInteractionEnabled = false
        removeFromSuperview()
        delegate?.card(didSwipe: self, with: direction, forced: forced)
    }
    
    public func undoSwipe(from direction: SwipeDirection, animated: Bool) {
        isUserInteractionEnabled = false
        delegate?.card(willUndo: self, from: direction)
        
        if animated {
            CardAnimator.undo(card: self, from: direction) { (finished) in
                if finished {
                    self.finishUndo(direction: direction)
                }
            }
        } else {
            finishUndo(direction: direction)
        }
    }
    
    private func finishUndo(direction: SwipeDirection) {
        isUserInteractionEnabled = true
        delegate?.card(didUndo: self, from: direction)
    }
    
    //MARK: MGDraggableSwipeView Overrides
    
    override func didTap(on view: SwipeableView) {
        delegate?.card(didTap: self)
    }
    
    override func didBeginSwipe(on view: SwipeableView) {
        delegate?.card(didBeginSwipe: self)
        CardAnimator.removeAllAnimations(on: self)
    }
    
    override func didContinueSwipe(on view: SwipeableView) {
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
    
    override func didSwipe(on view: SwipeableView, with direction: SwipeDirection) {
        swipeAction(direction: direction, animated: true, forced: false)
    }
    
    override func didCancelSwipe(on view: SwipeableView) {
        delegate?.card(didCancelSwipe: self)
        CardAnimator.reset(card: self) { _ in
            self.delegate?.card(willCancelSwipe: self)
        }
    }
}
