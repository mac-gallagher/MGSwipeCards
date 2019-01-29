//
//  CardAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/9/18.
//

protocol CardAnimatable {
    func animateSwipe(_ card: MGSwipeCard, direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?)
    func swipe(_ card: MGSwipeCard, direction: SwipeDirection)
    func animateReverseSwipe(_ card: MGSwipeCard, from direction: SwipeDirection, completion: ((Bool) -> ())?)
    func reverseSwipe(_ card: MGSwipeCard)
    func animateReset(_ card: MGSwipeCard, completion: ((Bool) -> ())?)
    func reset(_ card: MGSwipeCard)
    func removeAllAnimations(on card: MGSwipeCard)
}

class CardAnimator: CardAnimatable {
    static let shared = CardAnimator()
    
    func animateSwipe(_ card: MGSwipeCard, direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?) {
        removeAllAnimations(on: card)
        
        for (overlayDirection, overlay) in card.overlays {
            if overlayDirection != direction {
                overlay.alpha = 0
            }
        }
        
        let overlayDuration: TimeInterval = overlayFadeDuration(card, direction: direction, forced: forced)
        let swipeDuration: TimeInterval = card.animationOptions.cardSwipeAnimationDuration
        let totalDuration: TimeInterval = overlayDuration + swipeDuration
        
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0.0, options: .calculationModeLinear, animations: {
            let relativeOverlayDuration: TimeInterval = overlayDuration / totalDuration
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: relativeOverlayDuration, animations: {
                card.overlays[direction]?.alpha = 1
            })
            
            UIView.addKeyframe(withRelativeStartTime: relativeOverlayDuration, relativeDuration: 1.0, animations: {
                card.transform = self.swipeTransform(forCard: card, forDirection: direction, forced: forced)
            })
        }) { finished in
            completion?(finished)
        }
    }
    
    /// Performs the card swipe animation changes without animating them.
    func swipe(_ card: MGSwipeCard, direction: SwipeDirection) {
        removeAllAnimations(on: card)
        for (overlayDirection, overlay) in card.overlays {
            overlay.alpha = overlayDirection == direction ? 1 : 0
        }
        card.transform = swipeTransform(forCard: card, forDirection: direction, forced: true)
    }
    
    func animateReset(_ card: MGSwipeCard, completion: ((Bool) -> ())?) {
        removeAllAnimations(on: card)
        
        let resetDuration: TimeInterval = card.animationOptions.resetAnimationSpringDuration
        let resetSpringDamping: CGFloat = card.animationOptions.resetAnimationSpringDamping
        
        UIView.animate(withDuration: resetDuration, delay: 0.0, usingSpringWithDamping: resetSpringDamping, initialSpringVelocity: 0.0, options: [.curveLinear, .allowUserInteraction], animations: {
            if let direction = card.activeDirection, let overlay = card.overlays[direction] {
                overlay.alpha = 0
            }
            card.transform = .identity
        }) { finished in
            completion?(finished)
        }
    }
    
    /// Performs the card reset animation changes without animating them.
    func reset(_ card: MGSwipeCard) {
        removeAllAnimations(on: card)
        if let direction = card.activeDirection, let overlay = card.overlays[direction] {
            overlay.alpha = 0
        }
        card.transform = .identity
    }
    
    func animateReverseSwipe(_ card: MGSwipeCard, from direction: SwipeDirection, completion: ((Bool) -> ())?) {
        removeAllAnimations(on: card)
        
        //recreate swipe
        card.transform = swipeTransform(forCard: card, forDirection: direction)
        for (overlayDirection, overlay) in card.overlays {
            overlay.alpha = overlayDirection == direction ? 1 : 0
        }
        
        let overlayDuration: TimeInterval = overlayFadeDuration(card, direction: direction, forced: true)
        let reverseSwipeDuration: TimeInterval = card.animationOptions.reverseSwipeAnimationDuration
        let totalDuration: TimeInterval = overlayDuration + reverseSwipeDuration
            
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0.0, options: [.calculationModeLinear], animations: {
            let relativeReverseSwipeDuration: TimeInterval = reverseSwipeDuration / totalDuration
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: relativeReverseSwipeDuration, animations: {
                card.transform = .identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: relativeReverseSwipeDuration, relativeDuration: 1.0, animations: {
                card.overlays[direction]?.alpha = 0
            })
        }) { finished in
            completion?(finished)
        }
    }
    
    /// Performs the reverse swipe animation changes without animating them.
    func reverseSwipe(_ card: MGSwipeCard) {
        removeAllAnimations(on: card)
        for overlay in card.overlays.values {
            overlay.alpha = 0
        }
        card.transform = .identity
    }
    
    /// Removes all animations currently attached to the card and its overlays.
    func removeAllAnimations(on card: MGSwipeCard) {
        card.layer.removeAllAnimations()
        for overlay in card.overlays.values {
            overlay.layer.removeAllAnimations()
        }
    }
    
    //MARK: - Swipe Calculations
    
    func overlayFadeDuration(_ card: MGSwipeCard, direction: SwipeDirection, forced: Bool) -> TimeInterval {
        let overlay: UIView? = card.overlays[direction]
        return (forced && overlay != nil) ? card.animationOptions.overlayFadeAnimationDuration : 0
    }
    
    /// Returns the end card transform for the swipe animation.
    func swipeTransform(forCard card: MGSwipeCard, forDirection direction: SwipeDirection, forced: Bool = true) -> CGAffineTransform {
        let transform = CGAffineTransform.identity.rotated(by: rotationForSwipe(card: card, direction: direction, forced: forced))
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = translationForSwipe(card: card, direction: direction, translation: dragTranslation)
        return transform.concatenating(CGAffineTransform(translationX: translation.x, y: translation.y))
    }
    
    /// Returns the end card translation for the swipe animation in points. Based on speed and direction.
    func translationForSwipe(card: MGSwipeCard, direction: SwipeDirection, translation: CGPoint) -> CGPoint {
        let cardDiagonalLength: CGFloat = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation: CGPoint = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength,
                                                           y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength: CGFloat = max(abs(translation.x), abs(translation.y))
        let directionVector: CGPoint = (1 / maxLength) * translation
        let velocityFactor: CGFloat = max(1, card.dragSpeed(on: direction) / card.minimumSwipeSpeed)
        return velocityFactor * CGPoint(x: directionVector.x * minimumOffscreenTranslation.x,
                                        y: directionVector.y * minimumOffscreenTranslation.y)
    }
    
    /// Returns the end card rotation angle for the swipe animation in radians.
    func rotationForSwipe(card: MGSwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        if forced {
            let rotationDirectionY: CGFloat = direction == .left ? -1 : 1
            return 2 * rotationDirectionY * card.animationOptions.maximumRotationAngle
        }
        let touchPoint: CGPoint = card.touchLocation ?? .zero
        if (direction == .left && touchPoint.y < card.bounds.height / 2) || (direction == .right && touchPoint.y >= card.bounds.height / 2) {
            return -2 * card.animationOptions.maximumRotationAngle
        }
        return 2 * card.animationOptions.maximumRotationAngle
    }
}
