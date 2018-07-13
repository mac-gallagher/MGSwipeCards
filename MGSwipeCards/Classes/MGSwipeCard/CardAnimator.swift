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
    
    open func applySwipeAnimation(direction: SwipeDirection, translation: CGPoint, fast: Bool = false, randomRotation: Bool = false, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        updateOverlays(direction: direction)

        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = options.swipeAnimationMinimumDuration
            translationAnimation.toValue = translationForSwipeAnimation(translation: translation, fast: fast)
            translationAnimation.completionBlock = { (_, finished) in
                completion?(finished)
                self.isSwipeAnimating = false
            }
            card.layer.pop_add(translationAnimation, forKey: "swipeTranslationAnimation")
        }

        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration =  options.swipeAnimationMinimumDuration
            if randomRotation {
                rotationAnimation.toValue = randomRotationForAnimation(direction: direction) * (2 * options.maximumRotationAngle)
            } else {
                rotationAnimation.toValue = rotationForAnimation(direction: direction) * (2 * options.maximumRotationAngle)
            }
            card.layer.pop_add(rotationAnimation, forKey: "swipeRotationAnimation")
        }
    }
    
    open func applyForcedSwipeAnimation(direction: SwipeDirection, completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        UIView.animate(withDuration: 0.15, animations: {
            self.updateOverlays(direction: direction)
        }) { _ in
            self.applySwipeAnimation(direction: direction, translation: direction.point, randomRotation: true, completion: completion)
        }
    }
    
    private func updateOverlays(direction: SwipeDirection) {
        card.swipeDirections.forEach { swipeDirection in
            if swipeDirection == direction {
                card.overlay(forDirection: swipeDirection)?.alpha = 1
            } else {
                card.overlay(forDirection: swipeDirection)?.alpha = 0
            }
        }
    }
    
    private func rotationForAnimation(direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down {
            return 0
        }
        let location = card.panGestureRecognizer.location(in: card)
        if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) {
            return -1
        }
        return 1
    }
    
    private func randomRotationForAnimation(direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down:
            return 0
        case .left, .right:
            return 2 * Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * options.maximumRotationAngle
        }
    }
    
    private func translationForSwipeAnimation(translation: CGPoint, fast: Bool) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(translation.x), abs(translation.y))
        let directionVector = CGPoint(x: translation.x / maxLength, y: translation.y / maxLength)
        if fast {
            let velocityFactor = card.panGestureRecognizer.velocity(in: card.superview).norm / options.minimumSwipeSpeed
            return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
        }
        return CGPoint(x: directionVector.x * minimumOffscreenTranslation.x, y: directionVector.y * minimumOffscreenTranslation.y)
    }
    
    open func applyResetAnimation(completion: ((Bool) -> Void)?) {
        removeAllSwipeAnimations()
        isSwipeAnimating = true
        
        if let resetPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetPositionAnimation.toValue = CGPoint.zero
            resetPositionAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetPositionAnimation.springSpeed = options.resetAnimationSpringSpeed
            resetPositionAnimation.completionBlock = { _, finished in
                self.isSwipeAnimating = false
                completion?(finished)
            }
            card.layer.pop_add(resetPositionAnimation, forKey: "resetPositionAnimation")
        }

        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = options.resetAnimationSpringSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: "resetRotationAnimation")
        }

        guard let direction = card.activeDirection else { return }
        if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            resetOverlayAnimation.toValue = 0
            resetOverlayAnimation.springBounciness = options.resetAnimationSpringBounciness
            resetOverlayAnimation.springSpeed = options.resetAnimationSpringSpeed
            card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: "resetAlphaAnimation")
        }
    }
    
    open func removeAllSwipeAnimations() {
        isSwipeAnimating = false
        card.pop_removeAllAnimations()
        card.layer.pop_removeAllAnimations()
        card.swipeDirections.forEach { direction in
            card.overlay(forDirection: direction)?.pop_removeAllAnimations()
            card.overlay(forDirection: direction)?.layer.pop_removeAllAnimations()
        }
    }
    
}







