//
//  MGSwipeCard+Animations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 6/30/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import pop

extension MGSwipeCard {
    
    func swipeOffScreenAnimation(didSwipeFast: Bool) {
        removeAllAnimations()
        isUserInteractionEnabled = false
        guard let direction = activeDirection else { return }
        overlays[direction]??.alpha = 1
        
        //reset anchor to center of card?
        
        let duration = swipeAnimationMinimumDuration
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.toValue = translationForSwipeAnimation(didSwipeFast: didSwipeFast)
            translationAnimation.completionBlock = { (_, _) in
                self.removeFromSuperview()
            }
            animationLayer.pop_add(translationAnimation, forKey: "swipeTranslationAnimation")
        }
        
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration =  duration
            rotationAnimation.toValue = 2 * rotationForSwipeAnimation * maximumRotationAngle
            animationLayer.pop_add(rotationAnimation, forKey: "swipeRotationAnimation")
        }
    }
    
    var rotationForSwipeAnimation: CGFloat {
        if activeDirection == SwipeDirection.up || activeDirection == SwipeDirection.down {
            return 0
        }
        let location = panGestureRecognizer.location(in: self)
        if (activeDirection == .left && location.y < bounds.height / 2) || (activeDirection == .right && location.y >= bounds.height / 2) {
            return -1
        }
        return 1
    }
    
    func translationForSwipeAnimation(didSwipeFast: Bool) -> CGPoint {
        guard let superview = superview else { return CGPoint.zero }
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: bounds.width, y: bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let translation = panGestureRecognizer.translation(in: superview)
        let maxLength = max(abs(translation.x), abs(translation.y))
        let directionVector = CGPoint(x: translation.x / maxLength, y: translation.y / maxLength)
        if didSwipeFast {
            let velocityFactor = panGestureRecognizer.velocity(in: superview).norm / minimumSwipeSpeed
            return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
        }
        return CGPoint(x: directionVector.x * minimumOffscreenTranslation.x, y: directionVector.y * minimumOffscreenTranslation.y)
    }
    
    func resetCardAnimation() {
        removeAllAnimations()
        
        if let resetPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetPositionAnimation.toValue = CGPoint.zero
            resetPositionAnimation.springBounciness = resetAnimationSpringBounciness
            resetPositionAnimation.springSpeed = resetAnimationSpringSpeed
            resetPositionAnimation.completionBlock = { _, _ in
                self.animationLayer.transform = CATransform3DIdentity
                self.animationLayer.shouldRasterize = false
            }
            animationLayer.pop_add(resetPositionAnimation, forKey: "resetPositionAnimation")
        }
        
        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = resetAnimationSpringSpeed
            animationLayer.pop_add(resetRotationAnimation, forKey: "resetRotationAnimation")
        }
        
        guard let direction = activeDirection else { return }
        if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            resetOverlayAnimation.toValue = 0
            resetOverlayAnimation.springBounciness = resetAnimationSpringBounciness
            resetOverlayAnimation.springSpeed = resetAnimationSpringSpeed
            overlays[direction]??.pop_add(resetOverlayAnimation, forKey: "resetAlphaAnimation")
        }
    }
    
    func removeAllAnimations() {
        animationLayer.pop_removeAllAnimations()
        for overlay in overlays.values {
            overlay?.pop_removeAllAnimations()
        }
    }
}
