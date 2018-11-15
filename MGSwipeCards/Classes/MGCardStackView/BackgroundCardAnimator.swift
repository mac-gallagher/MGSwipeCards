//
//  CardStackAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

import pop

/**
 This class is reponsible for animating the background cards in response to a *swipe*, *shift*, *undo*, or a *cancelled swipe*. It is assumed that the card stack is in its desired state at the time of any method calls.
 */
class BackgroundCardAnimator {
    static func swipe(cardStack: MGCardStackView, forced: Bool, completion: ((Bool) -> ())?) {
        for (index, card) in cardStack.visibleCards.enumerated() {
            let delay = forced ? card.animationOptions.overlayFadeAnimationDuration : 0
            let duration = card.animationOptions.cardSwipeAnimationDuration / 2
            POPAnimator.applyTransformAnimation(to: card, transform: cardStack.transformForCard(at: index), delay: delay, duration: duration) { _, finished in
                completion?(finished)
            }
        }
    }
    
    static func shift(cardStack: MGCardStackView, withDistance distance: Int = 1, completion: ((Bool) -> ())?) {
        //place background cards in old positions
        if distance > 0 {
            for i in 0..<cardStack.visibleCards.count {
                cardStack.visibleCards[i].transform = cardStack.transformForCard(at: i + distance)
            }
        } else {
            for i in 1..<cardStack.visibleCards.count {
                cardStack.visibleCards[i].transform = cardStack.transformForCard(at: i - distance)
            }
        }
        
        //animate background cards to new positions
        for i in 0..<cardStack.visibleCards.count {
            let duration = 0.1
            POPAnimator.applyTransformAnimation(to: cardStack.visibleCards[i], transform: cardStack.transformForCard(at: i), duration: duration, completionBlock: nil)
            POPAnimator.applyTransformAnimation(to: cardStack.visibleCards[i], transform: cardStack.transformForCard(at: i), duration: duration) { _, finished in
                completion?(finished)
            }
        }
    }
    
    static func cancelSwipe(cardStack: MGCardStackView, completion: ((Bool) -> ())?) {
        for i in 1..<cardStack.visibleCards.count {
            let resetDuration: TimeInterval = 0.2
            POPAnimator.applyTransformAnimation(to: cardStack.visibleCards[i], transform: cardStack.transformForCard(at: i), duration: resetDuration, completionBlock: nil)
            POPAnimator.applyTransformAnimation(to: cardStack.visibleCards[i], transform: cardStack.transformForCard(at: i), duration: resetDuration) { _, finished in
                completion?(finished)
            }
        }
    }
    
    static func undo(cardStack: MGCardStackView, completion: ((Bool) -> ())?) {
        if cardStack.visibleCards.count == 1 {
            completion?(true)
            return
        }
        
        //place background cards in old positions
        for i in 1..<cardStack.visibleCards.count {
            cardStack.visibleCards[i].transform = cardStack.transformForCard(at: i - 1)
        }
        
        
        //animate background cards to new positions
        for i in 1..<cardStack.visibleCards.count {
            let duration = cardStack.visibleCards[i].animationOptions.reverseSwipeAnimationDuration
            POPAnimator.applyTransformAnimation(to: cardStack.visibleCards[i], transform: cardStack.transformForCard(at: i), duration: duration, completionBlock: nil)
            POPAnimator.applyTransformAnimation(to: cardStack.visibleCards[i], transform: cardStack.transformForCard(at: i), duration: duration) { _, finished in
                completion?(finished)
            }
        }
    }
    
    static func removeAllAnimations(cardStack: MGCardStackView) {
        for i in 1..<cardStack.visibleCards.count {
            CardAnimator.removeAllAnimations(on: cardStack.visibleCards[i])
        }
    }
}
