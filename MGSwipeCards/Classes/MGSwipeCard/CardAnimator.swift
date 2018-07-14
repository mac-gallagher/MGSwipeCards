//
//  CardAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/9/18.
//

import Foundation
import pop

open class CardAnimator {
    
    public private(set) var isSwipeAnimating = false
    
    private var card: MGSwipeCard
    private lazy var options = card.options
    
    public init(card: MGSwipeCard) {
        self.card = card
    }
    
    open func applySwipeAnimation(direction: SwipeDirection, directionVector: CGPoint, fast: Bool = false, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        setAlphaForOverlays(direction: direction)

        if let swipeTranslationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            swipeTranslationAnimation.duration = options.swipeAnimationMinimumDuration
            swipeTranslationAnimation.toValue = translationForSwipeAnimation(directionVector: directionVector, fast: fast)
            swipeTranslationAnimation.completionBlock = { (_, finished) in
                self.isSwipeAnimating = false
                completion?(finished)
            }
            card.layer.pop_add(swipeTranslationAnimation, forKey: CardAnimator.swipeTranslationKey)
        }

        if let swipeRotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            swipeRotationAnimation.duration = options.swipeAnimationMinimumDuration
            swipeRotationAnimation.toValue = rotationForSwipe(direction: direction) * (2 * options.maximumRotationAngle)
            card.layer.pop_add(swipeRotationAnimation, forKey: CardAnimator.swipeRotationKey)
        }
    }
    
    private func setAlphaForOverlays(direction: SwipeDirection?) {
        card.swipeDirections.forEach { swipeDirection in
            if swipeDirection == direction {
                card.overlay(forDirection: swipeDirection)?.alpha = 1
            } else {
                card.overlay(forDirection: swipeDirection)?.alpha = 0
            }
        }
    }
    
    private func rotationForSwipe(direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down {
            return 0
        }
        let location = card.panGestureRecognizer.location(in: card)
        if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) {
            return -1
        }
        return 1
    }
    
    private func translationForSwipeAnimation(directionVector: CGPoint, fast: Bool = false) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(directionVector.x), abs(directionVector.y))
        let directionVector = CGPoint(x: directionVector.x / maxLength, y: directionVector.y / maxLength)
        if fast {
            let velocityFactor = card.panGestureRecognizer.velocity(in: card.superview).norm / options.minimumSwipeSpeed
            return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
        }
        return CGPoint(x: directionVector.x * minimumOffscreenTranslation.x, y: directionVector.y * minimumOffscreenTranslation.y)
    }
    
    open func applyForcedSwipeAnimation(direction: SwipeDirection, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        UIView.animate(withDuration: options.overlayFadeInOutDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.setAlphaForOverlays(direction: direction)
        }, completion: nil)
        
        if let forcedtranslationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            forcedtranslationAnimation.duration = options.swipeAnimationMinimumDuration
            forcedtranslationAnimation.beginTime = CACurrentMediaTime() + options.overlayFadeInOutDuration
            forcedtranslationAnimation.toValue = translationForSwipeAnimation(directionVector: direction.point)
            forcedtranslationAnimation.completionBlock = { (_, finished) in
                self.isSwipeAnimating = false
                completion?(finished)
            }
            card.layer.pop_add(forcedtranslationAnimation, forKey: CardAnimator.forcedSwipeTranslationKey)
        }
        
        if let forcedRotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            forcedRotationAnimation.beginTime = CACurrentMediaTime() + options.overlayFadeInOutDuration
            forcedRotationAnimation.duration = options.swipeAnimationMinimumDuration
            forcedRotationAnimation.toValue = randomRotationForSwipe(direction: direction) * (2 * options.maximumRotationAngle)
            card.layer.pop_add(forcedRotationAnimation, forKey: CardAnimator.forcedSwipeRotationKey)
        }
    }
    
    private func randomRotationForSwipe(direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down:
            return 0
        case .left, .right:
            return 2 * Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * options.maximumRotationAngle
        }
    }
    
    open func applyReverseSwipeAnimation(completion: ((Bool) -> Void)?) {
        guard let swipedDirection = card.swipedDirection else { return }
        
        removeAllSwipeAnimations()
        isSwipeAnimating = true
    
        card.transform.tx = translationForSwipeAnimation(directionVector: swipedDirection.point).x
        card.transform.ty = translationForSwipeAnimation(directionVector: swipedDirection.point).y
        
        if let reverseTranslationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            reverseTranslationAnimation.duration = options.undoSwipeAnimationDuration
            reverseTranslationAnimation.toValue = CGPoint.zero
            card.layer.pop_add(reverseTranslationAnimation, forKey: CardAnimator.reverseSwipeTranslationKey)
        }

        if let reverseRotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            reverseRotationAnimation.duration = options.undoSwipeAnimationDuration
            reverseRotationAnimation.toValue = 0
            card.layer.pop_add(reverseRotationAnimation, forKey: CardAnimator.reverseSwipeRotationKey)
        }
        
        UIView.animate(withDuration: options.overlayFadeInOutDuration, delay: options.undoSwipeAnimationDuration, options: .curveEaseInOut, animations: {
            self.setAlphaForOverlays(direction: nil)
        }) { finished in
            self.isSwipeAnimating = false
            completion?(finished)
        }
        
    }
    
    open func applyResetAnimation(completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        if let resetTranslationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetTranslationAnimation.toValue = CGPoint.zero
            resetTranslationAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetTranslationAnimation.springSpeed = options.resetAnimationSpringSpeed
            resetTranslationAnimation.completionBlock = { _, finished in
                self.isSwipeAnimating = false
                completion?(finished)
            }
            card.layer.pop_add(resetTranslationAnimation, forKey: CardAnimator.resetTranslationKey)
        }

        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = options.resetAnimationSpringSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: CardAnimator.resetRotationKey)
        }

        guard let direction = card.activeDirection else { return }
        if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            resetOverlayAnimation.toValue = 0
            resetOverlayAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetOverlayAnimation.springSpeed = options.resetAnimationSpringSpeed
            card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: CardAnimator.resetOverlayAlphaKey)
        }
    }
    
    open func removeAllSwipeAnimations() {
        isSwipeAnimating = false
        for key in CardAnimator.cardLayerPopAnimationKeys {
            card.layer.pop_removeAnimation(forKey: key)
        }
        for key in CardAnimator.overlayViewPopAnimationKeys {
            card.swipeDirections.forEach { direction in
                card.overlay(forDirection: direction)?.pop_removeAnimation(forKey: key)
            }
        }
    }
    
}

extension CardAnimator {
    
    public static var swipeTranslationKey = "swipeTranslationAnimation"
    public static var swipeRotationKey = "swipeRotationAnimation"
    public static var forcedSwipeTranslationKey = "forcedSwipeTranslationAnimation"
    public static var forcedSwipeRotationKey = "forcedSwipeRotationAnimation"
    public static var reverseSwipeTranslationKey = "reverseSwipeTranslationAnimation"
    public static var reverseSwipeRotationKey = "reverseSwipeRotationAnimation"
    public static var reverseSwipeOverlayAlphaKey = "reverseSwipeOverlayAlphaAnimation"
    public static var resetTranslationKey = "resetTranslationAnimation"
    public static var resetRotationKey = "resetRotationAnimation"
    public static var resetOverlayAlphaKey = "resetOverlayAlphaAnimation"
    
    public static var cardLayerPopAnimationKeys = [
        swipeTranslationKey,
        swipeRotationKey,
        forcedSwipeTranslationKey,
        forcedSwipeRotationKey,
        reverseSwipeTranslationKey,
        reverseSwipeRotationKey,
        resetTranslationKey,
        resetRotationKey
    ]
    
    public static var overlayViewPopAnimationKeys = [
        resetOverlayAlphaKey
    ]
}







