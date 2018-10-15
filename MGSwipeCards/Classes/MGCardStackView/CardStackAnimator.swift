//
//  CardStackAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/13/18.
//

import pop

open class CardStackAnimator {

    public var isResettingCard: Bool = false
    
    private var cardStack: MGCardStackView
    
    init(cardStack: MGCardStackView) {
        self.cardStack = cardStack
    }
    
    //MARK: - Public
    
    open func applySwipeAnimation(to card: MGSwipeCard?, direction: SwipeDirection, forced: Bool = false, completion: ((Bool) -> Void)?) {
        guard let card = card else { return }
        removeAllAnimations(on: card)

        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale

        let overlayDuration = forced ? cardStack.options.cardOverlayFadeInOutDuration : 0
        let rotation = rotationForSwipe(card, direction: direction)
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = translationPoint(card, direction: direction, dragTranslation: dragTranslation)

        applyOverlayAnimations(to: card, showDirection: direction, duration: overlayDuration) { (_, finished) in
            if finished {
                POPAnimator.applyRotationAnimation(to: card, toValue: rotation, duration: self.cardStack.options.cardSwipeAnimationMaximumDuration, completionBlock: nil)
                POPAnimator.applyTranslationAnimation(to: card, toValue: translation, duration: self.cardStack.options.cardSwipeAnimationMaximumDuration) { _, finished in
                    if finished {
                        card.layer.shouldRasterize = false
                    }
                    completion?(finished)
                }
            }
        }
    }

    open func applyReverseSwipeAnimation(to card: MGSwipeCard?, from direction: SwipeDirection, completion: ((Bool) -> Void)?) {
        guard let card = card else { return }
        removeAllAnimations(on: card)
        isResettingCard = true

        //recreate swipe transform
        card.transform = CGAffineTransform.identity
        card.transform.tx = translationPoint(card, direction: direction, dragTranslation: direction.point).x
        card.transform.ty = translationPoint(card, direction: direction, dragTranslation: direction.point).y
        if direction == .left {
            card.transform = card.transform.rotated(by: -2 * card.maximumRotationAngle)
        } else if direction == .right {
            card.transform = card.transform.rotated(by: 2 * card.maximumRotationAngle)
        }
        applyOverlayAnimations(to: card, showDirection: direction, duration: 0, completionBlock: nil)

        POPAnimator.applyRotationAnimation(to: card, toValue: 0, duration: cardStack.options.cardUndoAnimationDuration, completionBlock: nil)
        POPAnimator.applyTranslationAnimation(to: card, toValue: .zero, duration: cardStack.options.cardUndoAnimationDuration) { _, finished in
            if finished {
                card.layer.shouldRasterize = false
                self.applyOverlayAnimations(to: card, showDirection: nil, duration: self.cardStack.options.cardOverlayFadeInOutDuration, completionBlock: { _, finished in
                    if finished {
                        self.isResettingCard = false
                    }
                    completion?(finished)
                })
            }
        }
    }
    
    open func applyResetAnimation(to card: MGSwipeCard?, completion: ((Bool) -> Void)?) {
        guard let card = card else { return }
        removeAllAnimations(on: card)
        isResettingCard = true
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale

        if let resetTranslationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetTranslationAnimation.toValue = CGPoint.zero
            resetTranslationAnimation.springBounciness = cardStack.options.cardResetAnimationSpringBounciness
            resetTranslationAnimation.springSpeed = cardStack.options.cardResetAnimationSpringSpeed
            resetTranslationAnimation.completionBlock = { _, finished in
                if finished {
                    card.layer.shouldRasterize = false
                    self.isResettingCard = false
                }
                completion?(finished)
            }
            card.layer.pop_add(resetTranslationAnimation, forKey: CardStackAnimator.springTranslationKey)
        }
        
        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = cardStack.options.cardResetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = cardStack.options.cardResetAnimationSpringSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: CardStackAnimator.springRotationKey)
        }

        card.swipeDirections.forEach { direction in
            if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
                resetOverlayAnimation.toValue = 0
                resetOverlayAnimation.springBounciness = cardStack.options.cardResetAnimationSpringBounciness
                resetOverlayAnimation.springSpeed = cardStack.options.cardResetAnimationSpringSpeed
                card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: CardStackAnimator.springOverlayAlphaKey)
            }
        }
    }
    
    open func removeAllAnimations(on card: MGSwipeCard?) {
        guard let card = card else { return }
        isResettingCard = false
        card.layer.pop_removeAllAnimations()
        card.pop_removeAllAnimations()
        card.swipeDirections.forEach { direction in
            card.overlay(forDirection: direction)?.pop_removeAllAnimations()
        }
        card.layer.shouldRasterize = false
    }

    //MARK: - Private
    
    //TODO: Does not exactly match user's swipe speed. Becomes more accurate the smaller card.options.maximumSwipeDuration is
    private func translationPoint(_ card: MGSwipeCard, direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
        let velocityFactor = max(1, card.swipeSpeed(on: direction) / card.minimumSwipeSpeed)
        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
    }
    
    private func rotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        let location = card.panGestureRecognizer.location(in: card)
        
        if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) {
            return -2 * card.maximumRotationAngle
        }
        return 2 * card.maximumRotationAngle
    }
    
    private func randomRotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down: return 0
        case .left, .right: return Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * (2 * card.maximumRotationAngle)
        }
    }
    
    //TODO: Clean this
    private func applyOverlayAnimations(to card: MGSwipeCard, showDirection: SwipeDirection?, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        var overlays = [UIView]()
        for direction in card.swipeDirections {
            if let overlay = card.overlay(forDirection: direction) {
                overlays.append(overlay)
            }
        }
        
        if overlays.isEmpty {
            completionBlock?(nil, true)
        } else {
            var completionCalled = false
            for direction in card.swipeDirections {
                let alpha: CGFloat = direction == showDirection ? 1 : 0
                let overlay = card.overlay(forDirection: direction)
                POPAnimator.applyAlphaAnimation(to: overlay, toValue: alpha, duration: duration) { (animation, finished) in
                    if !completionCalled {
                        completionBlock?(animation, finished)
                        completionCalled = true
                    }
                }
            }
        }
    }
}

extension CardStackAnimator {
    public static var springTranslationKey = "springTranslationAnimation"
    public static var springRotationKey = "springRotationAnimation"
    public static var springOverlayAlphaKey = "springOverlayAlphaAnimation"
    
    public static var cardAnimationKeys = [
        springTranslationKey,
        springRotationKey,
        springOverlayAlphaKey
    ]
}
