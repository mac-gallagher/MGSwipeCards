//
//  CardAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/9/18.
//

import pop

//MARK: - CardAnimator

class CardAnimator: NSObject {
    var card: MGSwipeCard!
    var options: CardAnimationOptions = .defaultOptions
    
    required init(card: MGSwipeCard) {
        self.card = card
    }
    
    init(card: MGSwipeCard, options: CardAnimationOptions) {
        self.card = card
        self.options = options
    }
    
    func swipe(direction: SwipeDirection, forced: Bool) {
        removeAllCardAnimations()
        card.isUserInteractionEnabled = false
        
        for (swipeDirection, overlay) in card.overlays {
            if swipeDirection != direction {
                overlay.alpha = 0
            }
        }
        
        let overlayDuration = forced ? card.animationOptions.overlayFadeAnimationDuration : 0
        POPAnimator.applyFadeAnimation(to: card.overlays[direction], toValue: 1, duration: overlayDuration) { _, _ in
            
            let swipeDuration = self.options.cardSwipeAnimationDuration
            let transform = self.swipeTransform(forDirection: direction, forced: forced)
            POPAnimator.applyTransformAnimation(to: self.card, transform: transform, duration: swipeDuration, completionBlock: { _, _ in
                self.card.isUserInteractionEnabled = true
                self.card.removeFromSuperview()
            })
        }
    }
    
    private func swipeTransform(forDirection direction: SwipeDirection, forced: Bool) -> CGAffineTransform {
        var transform = CGAffineTransform.identity.rotated(by: rotationForSwipe(direction: direction, forced: forced))
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = offScreenTranslation(direction: direction, dragTranslation: dragTranslation)
        transform = transform.concatenating(CGAffineTransform(translationX: translation.x, y: translation.y))
        return transform
    }
    
    func reset() {
        removeAllCardAnimations()
        
        POPAnimator.applySpringTransformAnimation(to: card, transform: .identity, springBounciness: options.resetAnimationSpringBounciness, springSpeed: options.resetAnimationSpringSpeed, completionBlock: nil)

        for (_, overlay) in card.overlays {
            POPAnimator.applySpringFadeAnimation(to: overlay, toValue: .zero, springBounciness: options.resetAnimationSpringBounciness, springSpeed: options.resetAnimationSpringSpeed, completionBlock: nil)
        }
    }
    
    func undo(from direction: SwipeDirection) {
        removeAllCardAnimations()
        card.isUserInteractionEnabled = false
        
        //recreate swipe
        card.transform = swipeTransform(forDirection: direction, forced: true)
        for (swipeDirection, overlay) in card.overlays {
            overlay.alpha = swipeDirection == direction ? 1 : 0
        }
        
        POPAnimator.applyTransformAnimation(to: card, transform: .identity, duration: options.reverseSwipeAnimationDuration) {  _, _ in
            POPAnimator.applyFadeAnimation(to: self.card.overlays[direction], toValue: 0, duration: self.options.overlayFadeAnimationDuration, completionBlock: { _, _ in
                self.card.isUserInteractionEnabled = true
            })
        }
    }
    
    func removeAllCardAnimations() {
        card.pop_removeAllAnimations()
        card.layer.pop_removeAllAnimations()
        
        for (_, overlay) in card.overlays {
            overlay.pop_removeAllAnimations()
            overlay.layer.pop_removeAllAnimations()
        }
    }
    
    //TODO: Does not exactly match user's swipe speed. Becomes more accurate the smaller card.animationOptions.maximumSwipeDuration is
    
    ///Returns the translation for the swipe animation in points
    private func offScreenTranslation(direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
        let velocityFactor = max(1, card.dragSpeed(on: direction) / card.minimumSwipeSpeed)
        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
    }
    
    ///Returns the rotation for the swipe animation in radians.
    private func rotationForSwipe(direction: SwipeDirection, forced: Bool = false) -> CGFloat {
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
}
