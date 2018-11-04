//
//  PopAnimation+CardAnimations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 10/13/18.
//

import pop

extension POPAnimator {
    
    static func applySwipeAnimation(to card: MGSwipeCard, direction: SwipeDirection, forced: Bool = false, completion: ((Bool) -> Void)?) {
        POPAnimator.removeAllCardAnimations(on: card)
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        let overlayDuration = forced ? card.animationOptions.overlayFadeAnimationDuration : 0
        let rotation = rotationForSwipe(card, direction: direction, forced: forced)
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = translationPoint(card, direction: direction, dragTranslation: dragTranslation)
        
        //apply rotation + translation + overlay fade animations
        applyOverlayFadeAnimations(to: card, showDirection: direction, duration: overlayDuration) { _, _ in
            POPAnimator.applyRotationAnimation(to: card, toValue: rotation, duration: card.animationOptions.cardSwipeAnimationDuration, completionBlock: nil)
            POPAnimator.applyTranslationAnimation(to: card, toValue: translation, duration: card.animationOptions.cardSwipeAnimationDuration) { _, finished in
                card.layer.shouldRasterize = false
                completion?(finished)
            }
        }
    }
    
    private static var cardResetTranslationKey = "cardResetTranslation"
    private static var cardResetRotationKey = "cardResetRotation"
    private static var cardResetOverlayAlphaKey = "cardResetOverlayAlpha"
    
    static func applyResetAnimation(to card: MGSwipeCard, completion: ((Bool) -> Void)?) {
        POPAnimator.removeAllCardAnimations(on: card)
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        //apply translation animation
        if let resetTranslationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetTranslationAnimation.toValue = CGPoint.zero
            resetTranslationAnimation.springBounciness = card.animationOptions.resetAnimationSpringBounciness
            resetTranslationAnimation.springSpeed = card.animationOptions.resetAnimationSpringSpeed
            resetTranslationAnimation.completionBlock = { _, finished in
                card.layer.shouldRasterize = false
                completion?(finished)
            }
            card.layer.pop_add(resetTranslationAnimation, forKey: POPAnimator.cardResetTranslationKey)
        }
        
        //apply rotation animation
        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = card.animationOptions.resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = card.animationOptions.resetAnimationSpringSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: POPAnimator.cardResetRotationKey)
        }
        
        //apply overlay fade animation
        card.swipeDirections.forEach { direction in
            if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
                resetOverlayAnimation.toValue = 0
                resetOverlayAnimation.springBounciness = card.animationOptions.resetAnimationSpringBounciness
                resetOverlayAnimation.springSpeed = card.animationOptions.resetAnimationSpringSpeed
                card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: POPAnimator.cardResetOverlayAlphaKey)
            }
        }
    }
    
    static func applyUndoAnimation(to card: MGSwipeCard, from direction: SwipeDirection, completion: ((Bool) -> Void)?) {
        POPAnimator.removeAllCardAnimations(on: card)
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        //recreate previous swipe transform
        var transform = CGAffineTransform.identity
        let translationPoint = POPAnimator.translationPoint(card, direction: direction, dragTranslation: direction.point)
        transform = transform.translatedBy(x: translationPoint.x, y: translationPoint.y)
        card.transform = transform.rotated(by: rotationForSwipe(card, direction: direction))
        for swipeDirection in card.swipeDirections {
            let overlay = card.overlay(forDirection: swipeDirection)
            overlay?.alpha = swipeDirection == direction ? 1 : 0
        }
        
        //animate back to original position
        POPAnimator.applyRotationAnimation(to: card, toValue: 0, duration: card.animationOptions.reverseSwipeAnimationDuration, completionBlock: nil)
        POPAnimator.applyTranslationAnimation(to: card, toValue: .zero, duration: card.animationOptions.reverseSwipeAnimationDuration) { _, finished in
            POPAnimator.applyOverlayFadeAnimations(to: card, showDirection: nil, duration: card.animationOptions.overlayFadeAnimationDuration, completionBlock: { _, finished in
                card.layer.shouldRasterize = false
                completion?(finished)
            })
        }
    }
    
    //TODO: Does not exactly match user's swipe speed. Becomes more accurate the smaller card.animationOptions.maximumSwipeDuration is
    private static func translationPoint(_ card: MGSwipeCard, direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
        let velocityFactor = max(1, card.dragSpeed(on: direction) / card.minimumSwipeSpeed)
        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
    }
    
    /**
     Returns the rotation for the swipe animation in radians.
    */
    private static func rotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection, forced: Bool = false) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        if forced {
            if direction == .left {
                return -2 * card.maximumRotationAngle
            } else {
                return 2 * card.maximumRotationAngle
            }
        }
        let location = card.panGestureRecognizer.location(in: card)
        if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) {
            return -2 * card.maximumRotationAngle
        }
        return 2 * card.maximumRotationAngle
    }
    
    private static func applyOverlayFadeAnimations(to card: MGSwipeCard, showDirection: SwipeDirection?, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        var hasOverlay = false
        for direction in card.swipeDirections {
            if card.overlay(forDirection: direction) != nil {
                hasOverlay = true
                break
            }
        }
        
        if !hasOverlay {
            completionBlock?(nil, true)
            return
        }
        
        var completionCalled  = false
        for direction in card.swipeDirections {
            let overlay = card.overlay(forDirection: direction)
            let alpha: CGFloat = direction == showDirection ? 1 : 0
            POPAnimator.applyFadeAnimation(to: overlay, toValue: alpha, duration: duration) { (animation, finished) in
                if !completionCalled {
                    completionBlock?(animation, finished)
                }
                completionCalled = true
            }
        }
    }
    
    static func removeAllCardAnimations(on card: MGSwipeCard) {
        card.pop_removeAllAnimations()
        card.layer.pop_removeAllAnimations()
        card.layer.shouldRasterize = false
        
        card.swipeDirections.forEach { direction in
            let overlay = card.overlay(forDirection: direction)
            overlay?.pop_removeAllAnimations()
            overlay?.layer.pop_removeAllAnimations()
        }
    }
}
