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
    
    public var isFooterTransparent: Bool = false {
        didSet { layoutIfNeeded() }
    }
    
    public var footerHeight: CGFloat = 100 {
        didSet { layoutIfNeeded() }
    }
    
    public var content: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            setNeedsLayout()
            if let content = content {
                addSubview(content)
            }
        }
    }

    public var footer: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            setNeedsLayout()
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
    
    open override func rasterizedSubviews() -> [UIView?] {
        return [content, footer]
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
        
        for (direction, overlay) in overlays {
            overlay.transform = .identity
            overlay.frame = overlayContainer.bounds
            overlay.transform = transformForOverlayBegin(forDirection: direction)
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
    
    open func alphaForOverlayBegin(forDirection direction: SwipeDirection) -> CGFloat {
        return 0
    }
    
    open func alphaForOverlayEnd(forDirection direction: SwipeDirection) -> CGFloat {
        return 1
    }
    
    open func transformForOverlayBegin(forDirection direction: SwipeDirection) -> CGAffineTransform {
        return CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    open func transformForOverlayEnd(forDirection direction: SwipeDirection) -> CGAffineTransform {
        return CGAffineTransform(scaleX: 1, y: 1)
    }
    
    //MARK: - MGDraggableSwipeView Overrides
    
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
            updateOverlay(overlay, direction: direction)
        }
    }
    
    private func updateOverlay(_ overlay: UIView, direction: SwipeDirection) {
        let totalSwipePercentage = swipeDirections.reduce(0) { (percentage, direction) in
            return percentage + dragPercentage(on: direction)
        }
        overlay.alpha = alphaForOverlay(with: direction, totalSwipePercentage: totalSwipePercentage)
        overlay.transform = transformForOverlay(with: direction, totalSwipePercentage: totalSwipePercentage)
    }

    private func transformForOverlay(with direction: SwipeDirection, totalSwipePercentage: CGFloat) -> CGAffineTransform {
        if direction != activeDirection { return .identity }
        let beginTransform = transformForOverlayBegin(forDirection: direction)
        let endTransform = transformForOverlayEnd(forDirection: direction)
        
        let factor = min((2 * dragPercentage(on: direction) - totalSwipePercentage) / minimumSwipeMargin, 1)
        
        let translation = beginTransform.translation() + factor * (endTransform.translation() - beginTransform.translation())
        let rotationAngle = beginTransform.rotationAngle() + factor * (endTransform.rotationAngle() - beginTransform.rotationAngle())
        let scaleFactor = beginTransform.scaleFactor() + factor * (endTransform.scaleFactor() - beginTransform.scaleFactor())
        
        return CGAffineTransform.identity.translatedBy(x: translation.x, y: translation.y).scaledBy(x: scaleFactor.x, y: scaleFactor.y).rotated(by: rotationAngle)
    }
    
    private func alphaForOverlay(with direction: SwipeDirection, totalSwipePercentage: CGFloat) -> CGFloat {
        if direction != activeDirection { return 0 }
        let beginAlpha = alphaForOverlayBegin(forDirection: direction)
        let endAlpha = alphaForOverlayEnd(forDirection: direction)
        let factor = (2 * dragPercentage(on: direction) - totalSwipePercentage) / minimumSwipeMargin
        return beginAlpha + factor * (endAlpha - beginAlpha)
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
