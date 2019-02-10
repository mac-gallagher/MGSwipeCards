//
//  CardAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/9/18.
//

protocol CardAnimator {
    func animateSwipe(_ card: SwipeCard, direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?)
    func swipe(_ card: SwipeCard, direction: SwipeDirection)
    func animateReverseSwipe(_ card: SwipeCard, from direction: SwipeDirection, completion: ((Bool) -> ())?)
    func reverseSwipe(_ card: SwipeCard)
    func animateReset(_ card: SwipeCard, completion: ((Bool) -> ())?)
    func reset(_ card: SwipeCard)
    func removeAllAnimations(on card: SwipeCard)
}

class DefaultCardAnimator: NSObject, CardAnimator {
    static let shared: DefaultCardAnimator = DefaultCardAnimator()
    
    func animateSwipe(_ card: SwipeCard, direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?) {
        guard let options = card.animationOptions as? DefaultCardAnimationOptions else { return }
        
        removeAllAnimations(on: card)
        
        for overlayDirection in card.swipeDirections {
            card.overlay(forDirection: overlayDirection)?.alpha = 0
        }
        
        let totalDuration: TimeInterval = options.totalSwipeDuration
        let relativeOverlayDuration: TimeInterval = relativeSwipeOverlayFadeDuration(card, direction: direction, forced: forced)
        
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyFrameAnimation(relativeDuration: relativeOverlayDuration, animations: {
                card.overlay(forDirection: direction)?.alpha = 1
            })
            
            UIView.addKeyFrameAnimation(withRelativeStartTime: relativeOverlayDuration, relativeDuration: 1.0, animations: {
                card.transform = self.swipeTransform(forCard: card, forDirection: direction, forced: forced)
            })
        }) { finished in
            completion?(finished)
        }
    }

    /// Performs the card swipe animation changes without animating them.
    func swipe(_ card: SwipeCard, direction: SwipeDirection) {
        removeAllAnimations(on: card)
        for overlayDirection in card.swipeDirections {
            card.overlay(forDirection: overlayDirection)?.alpha = overlayDirection == direction ? 1 : 0
        }
        card.transform = swipeTransform(forCard: card, forDirection: direction, forced: true)
    }
    
    func animateReset(_ card: SwipeCard, completion: ((Bool) -> ())?) {
        guard let options = card.animationOptions as? DefaultCardAnimationOptions else { return }
        
        removeAllAnimations(on: card)
        
        let totalDuration: TimeInterval = options.totalResetDuration
        let resetSpringDamping: CGFloat = options.resetSpringDamping
        
        UIView.addSpringAnimation(withDuration: totalDuration, usingSpringWithDamping: resetSpringDamping, animations: {
            if let direction = card.activeDirection, let overlay = card.overlay(forDirection: direction) {
                overlay.alpha = 0
            }
            card.transform = .identity
        }) { finished in
            completion?(finished)
        }
    }
    
    /// Performs the card reset animation changes without animating them.
    func reset(_ card: SwipeCard) {
        removeAllAnimations(on: card)
        if let direction = card.activeDirection, let overlay = card.overlay(forDirection: direction) {
            overlay.alpha = 0
        }
        card.transform = .identity
    }
    
    func animateReverseSwipe(_ card: SwipeCard, from direction: SwipeDirection, completion: ((Bool) -> ())?) {
        guard let options = card.animationOptions as? DefaultCardAnimationOptions else { return }
        
        removeAllAnimations(on: card)
        
        //recreate swipe
        card.transform = swipeTransform(forCard: card, forDirection: direction)
        for overlayDirection in card.swipeDirections {
            card.overlay(forDirection: overlayDirection)?.alpha = overlayDirection == direction ? 1 : 0
        }

        let totalDuration: TimeInterval = options.totalReverseSwipeDuration
        let relativeOverlayDuration: TimeInterval = relativeReverseSwipeOverlayFadeDuration(card, direction: direction)

        UIView.animateKeyframes(withDuration: totalDuration, delay: 0.0, options: [.calculationModeLinear], animations: {
            let relativeReverseSwipeDuration: TimeInterval = 1 - relativeOverlayDuration

            UIView.addKeyFrameAnimation(relativeDuration: relativeReverseSwipeDuration, animations: {
                card.transform = .identity
            })
            
            UIView.addKeyFrameAnimation(withRelativeStartTime: relativeReverseSwipeDuration, relativeDuration: 1.0, animations: {
                card.overlay(forDirection: direction)?.alpha = 0
            })
        }) { finished in
            completion?(finished)
        }
    }
    
    /// Performs the reverse swipe animation changes without animating them.
    func reverseSwipe(_ card: SwipeCard) {
        removeAllAnimations(on: card)
        for direction in card.swipeDirections {
            card.overlay(forDirection: direction)?.alpha = 0
        }
        card.transform = .identity
    }
    
    /// Removes all animations currently attached to the card and its overlays.
    func removeAllAnimations(on card: SwipeCard) {
        card.layer.removeAllAnimations()
        for direction in card.swipeDirections {
            card.overlay(forDirection: direction)?.layer.removeAllAnimations()
        }
    }
    
    //MARK: - Swipe Calculations
    
    func relativeSwipeOverlayFadeDuration(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> TimeInterval {
        guard let options = card.animationOptions as? DefaultCardAnimationOptions else { return 0 }
        let overlay: UIView? = card.overlay(forDirection: direction)
        let totalSwipeDuration: TimeInterval = options.totalSwipeDuration
        return (forced && overlay != nil) ? (options.relativeSwipeOverlayFadeDuration * totalSwipeDuration) : 0
    }
    
    func relativeReverseSwipeOverlayFadeDuration(_ card: SwipeCard, direction: SwipeDirection) -> TimeInterval {
        guard let options = card.animationOptions as? DefaultCardAnimationOptions else { return 0 }
        let overlay: UIView? = card.overlay(forDirection: direction)
        let totalSwipeDuration: TimeInterval = options.totalReverseSwipeDuration
        return (overlay != nil) ? (options.relativeReverseSwipeOverlayFadeDuration * totalSwipeDuration) : 0
    }
    
    /// Returns the end card transform for the swipe animation.
    func swipeTransform(forCard card: SwipeCard, forDirection direction: SwipeDirection, forced: Bool = true) -> CGAffineTransform {
        let transform = CGAffineTransform.identity.rotated(by: rotationForSwipe(card: card, direction: direction, forced: forced))
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = translationForSwipe(card: card, direction: direction, translation: dragTranslation)
        return transform.concatenating(CGAffineTransform(translationX: translation.x, y: translation.y))
    }
    
    /// Returns the end card translation for the swipe animation in points. Based on speed and direction.
    func translationForSwipe(card: SwipeCard, direction: SwipeDirection, translation: CGPoint) -> CGPoint {
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
    func rotationForSwipe(card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
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

//MARK: Testable Animation Helpers

extension UIView {
    static func addKeyFrameAnimation(withRelativeStartTime relativeStartTime: TimeInterval = 0.0, relativeDuration: TimeInterval, animations: @escaping () -> Void) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime, relativeDuration: relativeDuration, animations: animations)
    }
    
    static func addSpringAnimation(withDuration duration: TimeInterval, usingSpringWithDamping damping: CGFloat, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: [.curveLinear, .allowUserInteraction], animations: animations, completion: completion)
    }
}
