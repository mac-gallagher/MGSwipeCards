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
    
    //MARK: - Public
    
    open func applySwipeAnimation(direction: SwipeDirection, directionVector: CGPoint, fast: Bool = false, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        setAlphaForOverlays(direction: direction)

        applyRotationAnimation(toValue: rotationForSwipe(direction: direction) * (2 * options.maximumRotationAngle), duration: options.swipeAnimationMinimumDuration)
        applyTranslationAnimation(toValue: translationPoint(directionVector: directionVector, fast: fast),duration: options.swipeAnimationMinimumDuration) { (_, finished) in
            self.isSwipeAnimating = false
            completion?(finished)
        }
    }
    
    open func applyForcedSwipeAnimation(direction: SwipeDirection, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        UIView.animate(withDuration: options.overlayFadeInOutDuration, delay: 0, options: .curveLinear, animations: {
            self.setAlphaForOverlays(direction: direction)
        }, completion: nil)
        
        applyRotationAnimation(toValue: randomRotationForSwipe(direction: direction) * (2 * options.maximumRotationAngle), beginTime: CACurrentMediaTime() + options.overlayFadeInOutDuration, duration: options.swipeAnimationMinimumDuration)
        applyTranslationAnimation(toValue: translationPoint(directionVector: direction.point), beginTime: CACurrentMediaTime() + options.overlayFadeInOutDuration, duration: options.swipeAnimationMinimumDuration) { (_, finished) in
            self.isSwipeAnimating = false
            completion?(finished)
        }
    }
    
    open func applyReverseSwipeAnimation(completion: ((Bool) -> Void)?) {
        guard let swipedDirection = card.swipedDirection else { return }
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        card.transform.tx = translationPoint(directionVector: swipedDirection.point).x
        card.transform.ty = translationPoint(directionVector: swipedDirection.point).y
        
        applyRotationAnimation(toValue: 0, duration: options.undoSwipeAnimationDuration)
        applyTranslationAnimation(toValue: CGPoint.zero, duration: options.undoSwipeAnimationDuration, completionBlock: nil)
        
        UIView.animate(withDuration: options.overlayFadeInOutDuration, delay: options.undoSwipeAnimationDuration, options: .curveLinear, animations: {
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
            card.layer.pop_add(resetTranslationAnimation, forKey: CardAnimator.springTranslationKey)
        }
        
        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = options.resetAnimationSpringSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: CardAnimator.springRotationKey)
        }
        
        guard let direction = card.activeDirection else { return }
        if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            resetOverlayAnimation.toValue = 0
            resetOverlayAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetOverlayAnimation.springSpeed = options.resetAnimationSpringSpeed
            card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: CardAnimator.springOverlayAlphaKey)
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
    
    //MARK: - Private
    
    private func applyTranslationAnimation(toValue: CGPoint, beginTime: CFTimeInterval = 0, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.beginTime = beginTime
            translationAnimation.toValue = toValue
            if completionBlock != nil {
                translationAnimation.completionBlock = completionBlock
            }
            card.layer.pop_add(translationAnimation, forKey: CardAnimator.translationKey)
        }
    }
    
    private func applyRotationAnimation(toValue: CGFloat, beginTime: CFTimeInterval = 0, duration: CFTimeInterval) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration
            rotationAnimation.beginTime = beginTime
            rotationAnimation.toValue = toValue
            card.layer.pop_add(rotationAnimation, forKey: CardAnimator.rotationKey)
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
    
    private func translationPoint(directionVector: CGPoint, fast: Bool = false) -> CGPoint {
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
    
    private func rotationForSwipe(direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        let location = card.panGestureRecognizer.location(in: card)
        if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) { return -1 }
        return 1
    }
    
    private func randomRotationForSwipe(direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down: return 0
        case .left, .right: return 2 * Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * options.maximumRotationAngle
        }
    }
    
}

extension CardAnimator {
    
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







