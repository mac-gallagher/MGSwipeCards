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
    
    //MARK: - Public
    
    open func applySwipeAnimation(to card: MGSwipeCard, direction: SwipeDirection, forced: Bool = false, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations(on: card)
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        let overlayDuration = forced ? card.options.overlayFadeInOutDuration : 0
        let rotation = forced ? randomRotationForSwipe(card, direction: direction) : rotationForSwipe(card, direction: direction)
        let swipeDelay = forced ? card.options.overlayFadeInOutDuration : 0
        let translation = forced ? translationPoint(card, direction: direction, dragTranslation: direction.point) : translationPoint(card, direction: direction, dragTranslation: card.panGestureRecognizer.translation(in: card.superview))
        
        UIView.animate(withDuration: overlayDuration, delay: 0, options: .curveLinear, animations: {
            self.updateOverlays(on: card, direction: direction)
        }, completion: nil)
        
        applyRotationAnimation(to: card, toValue: rotation, beginTime: CACurrentMediaTime() + swipeDelay, duration: card.options.swipeAnimationMaximumDuration)
        applyTranslationAnimation(to: card, toValue: translation, beginTime: CACurrentMediaTime() + swipeDelay, duration: card.options.swipeAnimationMaximumDuration) { (_, finished) in
            card.layer.shouldRasterize = false
            completion?(finished)
        }
    }

    open func applyReverseSwipeAnimation(on card: MGSwipeCard, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations(on: card)
        isResettingCard = true
        
        applyRotationAnimation(to: card, toValue: 0, duration: card.options.undoSwipeAnimationDuration)
        applyTranslationAnimation(to: card, toValue: .zero, duration: card.options.undoSwipeAnimationDuration) { (_, finished) in
            card.layer.shouldRasterize = false
        }
        
        UIView.animate(withDuration: card.options.overlayFadeInOutDuration, delay: card.options.undoSwipeAnimationDuration, options: .curveLinear, animations: {
            self.updateOverlays(on: card, direction: nil)
        }) { finished in
            if finished {
                self.isResettingCard = false
            }
            completion?(finished)
        }
    }
    
    open func applyResetAnimation(to card: MGSwipeCard, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations(on: card)
        isResettingCard = true
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale

        if let resetTranslationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetTranslationAnimation.toValue = CGPoint.zero
            resetTranslationAnimation.springBounciness = card.options.resetAnimationSpringBounciness
            resetTranslationAnimation.springSpeed = card.options.resetAnimationSpringSpeed
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
            resetRotationAnimation.springBounciness = card.options.resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = card.options.resetAnimationSpringSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: CardStackAnimator.springRotationKey)
        }

        guard let direction = card.activeDirection else { return }
        if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            resetOverlayAnimation.toValue = 0
            resetOverlayAnimation.springBounciness = card.options.resetAnimationSpringBounciness
            resetOverlayAnimation.springSpeed = card.options.resetAnimationSpringSpeed
            card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: CardStackAnimator.springOverlayAlphaKey)
        }
    }
    
    open func removeAllSwipeAnimations(on card: MGSwipeCard) {
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
    
    private func applyTranslationAnimation(to card: MGSwipeCard, toValue: CGPoint, beginTime: CFTimeInterval = 0, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.beginTime = beginTime
            translationAnimation.toValue = toValue
            if completionBlock != nil {
                translationAnimation.completionBlock = completionBlock
            }
            card.layer.pop_add(translationAnimation, forKey: CardStackAnimator.translationKey)
        }
    }

    private func applyRotationAnimation(to card: MGSwipeCard, toValue: CGFloat, beginTime: CFTimeInterval = 0, duration: CFTimeInterval) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration
            rotationAnimation.beginTime = beginTime
            rotationAnimation.toValue = toValue
            card.layer.pop_add(rotationAnimation, forKey: CardStackAnimator.rotationKey)
        }
    }
    
    private func updateOverlays(on card: MGSwipeCard, direction: SwipeDirection?) {
        card.swipeDirections.forEach { swipeDirection in
            if swipeDirection == direction {
                card.overlay(forDirection: swipeDirection)?.alpha = 1
            } else {
                card.overlay(forDirection: swipeDirection)?.alpha = 0
            }
        }
    }

    //not totally precise with fast swipes. Becomes more accurate the smaller card.options.maximumSwipeDuration is
    private func translationPoint(_ card: MGSwipeCard, direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
        let velocityFactor = max(1, card.swipeSpeed(on: direction) / card.options.minimumSwipeSpeed)
        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
    }
    
    //not always accurate due to rotation
    private func rotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        if let location = card.touchPoint {
            if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) { return -1 }
        }
        return 1
    }
    
    private func randomRotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down: return 0
        case .left, .right: return 2 * Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * card.options.maximumRotationAngle
        }
    }
    
}

extension CardStackAnimator {
    
    public static var translationKey = "translationAnimation"
    public static var rotationKey = "rotationAnimation"
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
        springOverlayAlphaKey
    ]
}


