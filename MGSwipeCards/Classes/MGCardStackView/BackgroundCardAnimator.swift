//
//  CardStackAnimator.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

import pop

/**
 This class is reponsible for animating the background cards in response to a *swipe*, *shift*, *undo*, or a *cancelled swipe*.
 */
class BackgroundCardAnimator: NSObject {
    
    var cardStack: MGCardStackView!
    
    var options: CardStackAnimationOptions { return cardStack.animationOptions }
    var visibleCards: [MGSwipeCard] { return cardStack.visibleCards }
    
    required init(cardStack: MGCardStackView) {
        self.cardStack = cardStack
    }
    
    func animateSwipe(completion: ((Bool) -> ())?) {
        for (index, card) in visibleCards.enumerated() {
            POPAnimator.applyTransformAnimation(to: card, transform: cardStack.transformForCard(at: index), delay: card.animationOptions.overlayFadeAnimationDuration, duration: options.backgroundCardTransformAnimationDuration) { (_, finished) in
                completion?(finished)
            }
        }
    }
    
    func animateShift(withDistance distance: Int = 1) {
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
            POPAnimator.applyTransformAnimation(to: visibleCards[i], transform: cardStack.transformForCard(at: i), duration: options.backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
    
    func animateCancelledSwipe() {
        for i in 1..<cardStack.visibleCards.count {
            POPAnimator.applyTransformAnimation(to: visibleCards[i], transform: cardStack.transformForCard(at: i), duration: options.backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
    
    func animateUndo() {
        //place background cards in old positions
        for i in 1..<cardStack.visibleCards.count {
            visibleCards[i].transform = cardStack.transformForCard(at: i - 1)
        }
        
        //animate background cards to new positions
        for i in 1..<cardStack.visibleCards.count {
            POPAnimator.applyTransformAnimation(to: visibleCards[i], transform: cardStack.transformForCard(at: i), duration: options.backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
    
    func removeAllBackgroundCardAnimations() {
        for i in 1..<visibleCards.count {
            POPAnimator.removeAllCardAnimations(on: visibleCards[i])
        }
    }
}
