//
//  CardAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/9/18.
//

import pop

protocol CardAnimatable {
    func swipe(direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?)
    func reverseSwipe(from direction: SwipeDirection, completion: ((Bool) -> ())?)
    func reset(completion: ((Bool) -> ())?)
    func removeAllAnimations()
}

class CardAnimator: CardAnimatable {
    private let card: MGSwipeCard
    
    private var options: CardAnimationOptions {
        return card.animationOptions
    }
    
    init(card: MGSwipeCard) {
        self.card = card
    }
    
    func swipe(direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?) {
//        removeAllAnimations()
//
//        for (swipeDirection, overlay) in card.overlays {
//            if swipeDirection != direction {
//                overlay.alpha = 0
//            }
//        }
//
//        let overlay = card.overlays[direction]
//        let overlayDuration = forced && !(overlay == nil) ? options.overlayFadeAnimationDuration : 0
//        let transform = CardAnimator.swipeTransform(forCard: card, forDirection: direction, forced: forced)
//
//        POPAnimator.applyFadeAnimation(to: overlay, toValue: 1, duration: overlayDuration, timingFunction: CAMediaTimingFunction(name: .easeOut), completionBlock: nil)
//
//        let swipeDuration = options.cardSwipeAnimationDuration
//        POPAnimator.applyTransformAnimation(to: card, transform: transform, delay: overlayDuration, duration: swipeDuration) { _, finished in
//            completion?(finished)
//        }
    }
    
    func reset(completion: ((Bool) -> ())?) {
        removeAllAnimations()
        
        for (direction, overlay) in card.overlays {
            if direction != card.activeDirection {
                overlay.alpha = 0
            }
        }
        
        let springBounciness = options.resetAnimationSpringBounciness
        let springSpeed = options.resetAnimationSpringSpeed
        
        if let activeDirection = card.activeDirection {
            POPAnimator.applySpringFadeAnimation(to: card.overlays[activeDirection], toValue: 0, springBounciness: springBounciness, springSpeed: springSpeed, completionBlock: nil)
        }
        
        POPAnimator.applySpringTransformAnimation(to: card, transform: .identity, springBounciness: springBounciness, springSpeed: springSpeed) { _, finished in
            completion?(finished)
        }
    }
    
    func reverseSwipe(from direction: SwipeDirection, completion: ((Bool) -> ())?) {
//        removeAllAnimations()
//
//        //recreate swipe
//        card.transform = CardAnimator.swipeTransform(forCard: card, forDirection: direction, forced: true)
//        for (swipeDirection, overlay) in card.overlays {
//            overlay.alpha = swipeDirection == direction ? 1 : 0
//        }
//
//        let swipeDuration = options.reverseSwipeAnimationDuration
//        POPAnimator.applyTransformAnimation(to: card, transform: .identity, duration: swipeDuration, completionBlock: nil)
//
//        guard let overlay = card.overlays[direction] else {
//            completion?(true)
//            return
//        }
//
//        let fadeDuration = options.overlayFadeAnimationDuration
//        POPAnimator.applyFadeAnimation(to: overlay, toValue: 0, delay: swipeDuration, duration: fadeDuration, timingFunction: CAMediaTimingFunction(name: .easeIn)) { _, finished in
//            completion?(finished)
//        }
    }
    
    func removeAllAnimations() {
        card.pop_removeAllAnimations()
        card.layer.pop_removeAllAnimations()
        
        for (_, overlay) in card.overlays {
            overlay.pop_removeAllAnimations()
            overlay.layer.pop_removeAllAnimations()
        }
    }
    
//    private static func swipeTransform(forCard card: MGSwipeCard, forDirection direction: SwipeDirection, forced: Bool) -> CGAffineTransform {
//        var transform = CGAffineTransform.identity.rotated(by: CardAnimator.rotationForSwipe(card: card, direction: direction, forced: forced))
//        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
//        let translation = CardAnimator.offScreenTranslation(forCard: card, direction: direction, dragTranslation: dragTranslation)
//        transform = transform.concatenating(CGAffineTransform(translationX: translation.x, y: translation.y))
//        return transform
//    }
    
    ///Returns the translation for the swipe animation in points
//    private static func offScreenTranslation(forCard card: MGSwipeCard, direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
//        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
//        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
//        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
//        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
//        let velocityFactor = max(1, card.dragSpeed(on: direction) / card.minimumSwipeSpeed)
//        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
//    }
    
    ///Returns the rotation for the swipe animation in radians.
//    private static func rotationForSwipe(card: MGSwipeCard, direction: SwipeDirection, forced: Bool = false) -> CGFloat {
//        if direction == .up || direction == .down { return 0 }
//        if forced {
//            if direction == .left {
//                return -2 * options.maximumRotationAngle
//            } else {
//                return 2 * options.maximumRotationAngle
//            }
//        }
//        let touchPoint = card.touchLocation ?? .zero
//        if (direction == .left && touchPoint.y < card.bounds.height / 2) || (direction == .right && touchPoint.y >= card.bounds.height / 2) {
//            return -2 * options.maximumRotationAngle
//        }
//        return 2 * options.maximumRotationAngle
//    }
}
