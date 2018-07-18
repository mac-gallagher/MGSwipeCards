//
//  CardStackAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/13/18.
//

import Foundation
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
        removeAllSwipeAnimations(on: card)

        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        let overlayDuration = forced ? cardStack.options.cardOverlayFadeInOutDuration : 0
        let rotation = forced ? randomRotationForSwipe(card, direction: direction) : rotationForSwipe(card, direction: direction)
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = translationPoint(card, direction: direction, dragTranslation: dragTranslation)
        
        applyOverlayAnimations(to: card, showDirection: direction, duration: overlayDuration) { (_, finished) in
            if finished {
                self.applyRotationAnimation(to: card, toValue: rotation, duration: self.cardStack.options.cardSwipeAnimationMaximumDuration)
                self.applyTranslationAnimation(to: card, toValue: translation, duration: self.cardStack.options.cardSwipeAnimationMaximumDuration) { _, finished in
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
        removeAllSwipeAnimations(on: card)
        isResettingCard = true
        
        //recreate swipe transform
        card.transform = CGAffineTransform.identity
        card.transform.tx = translationPoint(card, direction: direction, dragTranslation: direction.point).x
        card.transform.ty = translationPoint(card, direction: direction, dragTranslation: direction.point).y
        if direction == .left {
            card.transform = card.transform.rotated(by: -cardStack.options.cardUndoAnimationMaximumRotationAngle )
        } else if direction == .right {
            card.transform = card.transform.rotated(by: cardStack.options.cardUndoAnimationMaximumRotationAngle)
        }
        card.overlay(forDirection: direction)?.alpha = 1
        
        applyRotationAnimation(to: card, toValue: 0, duration: cardStack.options.cardUndoAnimationDuration)
        applyTranslationAnimation(to: card, toValue: .zero, duration: cardStack.options.cardUndoAnimationDuration) { _, finished in
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
        removeAllSwipeAnimations(on: card)
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
    
    open func removeAllSwipeAnimations(on card: MGSwipeCard?) {
        guard let card = card else { return }
        isResettingCard = false
        for key in CardStackAnimator.cardLayerPopAnimationKeys {
            card.layer.pop_removeAnimation(forKey: key)
        }
        for key in CardStackAnimator.overlayViewPopAnimationKeys {
            card.swipeDirections.forEach { direction in
                card.overlay(forDirection: direction)?.pop_removeAnimation(forKey: key)
            }
        }
        card.layer.shouldRasterize = false
    }
    

    //MARK: - Private
    
    //not totally precise with fast swipes. Becomes more accurate the smaller card.options.maximumSwipeDuration is
    private func translationPoint(_ card: MGSwipeCard, direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
        let velocityFactor = max(1, card.swipeSpeed(on: direction) / card.options.minimumSwipeSpeed)
        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
    }
    
    private func rotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        if let location = card.touchPoint {
            if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) { return -card.options.maximumRotationAngle }
        }
        return card.options.maximumRotationAngle
    }
    
    private func randomRotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down: return 0
        case .left, .right: return 2 * Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * card.options.maximumRotationAngle
        }
    }
    
    private func applyTranslationAnimation(to card: MGSwipeCard, toValue: CGPoint, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.toValue = toValue
            if completionBlock != nil {
                translationAnimation.completionBlock = completionBlock
            }
            card.layer.pop_add(translationAnimation, forKey: CardStackAnimator.translationKey)
        }
    }

    private func applyRotationAnimation(to card: MGSwipeCard, toValue: CGFloat, duration: CFTimeInterval) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration
            rotationAnimation.toValue = toValue
            card.layer.pop_add(rotationAnimation, forKey: CardStackAnimator.rotationKey)
        }
    }
    
    private func applyOverlayAnimations(to card: MGSwipeCard, showDirection: SwipeDirection?, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        var completionCalled = false
        for direction in card.swipeDirections {
            if direction == showDirection {
                if let keepOverlayAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha) {
                    keepOverlayAnimation.duration = duration
                    keepOverlayAnimation.toValue = 1
                    keepOverlayAnimation.completionBlock = { animation, finished in
                        if !completionCalled {
                            completionBlock?(animation, finished)
                            completionCalled = true
                        }
                    }
                    card.overlay(forDirection: direction)?.pop_add(keepOverlayAnimation, forKey: CardStackAnimator.overlayAlphaKey)
                }
            } else {
                if let hideOverlayAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha) {
                    hideOverlayAnimation.duration = duration
                    hideOverlayAnimation.toValue = 0
                    hideOverlayAnimation.completionBlock = { animation, finished in
                        if !completionCalled {
                            completionBlock?(animation, finished)
                            completionCalled = true
                        }
                    }
                    card.overlay(forDirection: direction)?.pop_add(hideOverlayAnimation, forKey: CardStackAnimator.overlayAlphaKey)
                }
            }
        }
    }

}

extension CardStackAnimator {
    
    public static var translationKey = "translationAnimation"
    public static var rotationKey = "rotationAnimation"
    public static var overlayAlphaKey = "overlayAlphaAnimation"
    public static var springTranslationKey = "springTranslationAnimation"
    public static var springRotationKey = "springRotationAnimation"
    public static var springOverlayAlphaKey = "springOverlayAlphaAnimation"
    
    public static var cardLayerPopAnimationKeys = [
        translationKey,
        rotationKey,
        springTranslationKey,
        springRotationKey
    ]
    
    public static var overlayViewPopAnimationKeys = [
        overlayAlphaKey,
        springOverlayAlphaKey
    ]
}


