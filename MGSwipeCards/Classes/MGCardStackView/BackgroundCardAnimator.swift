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
class BackgroundCardAnimator: NSObject {
    var cardStack: MGCardStackView!
    
    var visibleCards: [MGSwipeCard] { return cardStack.visibleCards }
    
    required init(cardStack: MGCardStackView) {
        self.cardStack = cardStack
    }
    
    func swipe(forced: Bool, completion: ((Bool) -> ())?) {
        for (index, card) in visibleCards.enumerated() {
            let delay = forced ? card.animationOptions.overlayFadeAnimationDuration : 0
            let duration = card.animationOptions.cardSwipeAnimationDuration / 2
            POPAnimator.applyTransformAnimation(to: card, transform: cardStack.transformForCard(at: index), delay: delay, duration: duration) { (_, finished) in
                completion?(finished)
            }
        }
    }
    
    func shift(withDistance distance: Int = 1) {
        //place background cards in old positions
        if distance > 0 {
            for i in 0..<cardStack.visibleCards.count {
                visibleCards[i].transform = cardStack.transformForCard(at: i + distance)
            }
        } else {
            for i in 1..<cardStack.visibleCards.count {
                visibleCards[i].transform = cardStack.transformForCard(at: i - distance)
            }
        }
        
        //animate background cards to new positions
        for i in 0..<cardStack.visibleCards.count {
            let duration = 0.1
            POPAnimator.applyTransformAnimation(to: visibleCards[i], transform: cardStack.transformForCard(at: i), duration: duration, completionBlock: nil)
        }
    }
    
    func cancelSwipe() {
        for i in 1..<cardStack.visibleCards.count {
            let resetDuration: TimeInterval = 0.2
            POPAnimator.applyTransformAnimation(to: visibleCards[i], transform: cardStack.transformForCard(at: i), duration: resetDuration, completionBlock: nil)
        }
    }
    
    func undo() {
        //place background cards in old positions
        for i in 1..<cardStack.visibleCards.count {
            visibleCards[i].transform = cardStack.transformForCard(at: i - 1)
        }
        
        //animate background cards to new positions
        for i in 1..<cardStack.visibleCards.count {
            let duration = visibleCards[i].animationOptions.reverseSwipeAnimationDuration
            POPAnimator.applyTransformAnimation(to: visibleCards[i], transform: cardStack.transformForCard(at: i), duration: duration, completionBlock: nil)
        }
    }
    
    func removeAllAnimations() {
        for i in 1..<visibleCards.count {
            CardAnimator.removeAllAnimations(on: visibleCards[i])
        }
    }
}
