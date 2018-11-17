//
//  MGCardStackView+Delegates.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

//MARK: - MGSwipeCardDelegate

extension MGCardStackView: MGSwipeCardDelegate {
    func card(didTap card: MGSwipeCard) {
        delegate?.cardStack(self, didSelectCardAt: topCardIndex)
        let location = card.tapGestureRecognizer.location(in: card.superview)
        let topCorner: UIRectCorner
        if location.x < card.bounds.width / 2 {
            topCorner = location.y < card.bounds.height / 2 ? .topLeft : .bottomLeft
        } else {
            topCorner = location.y < card.bounds.height / 2 ? .topRight : .bottomRight
        }
        delegate?.cardStack(self, didSelectCardAt: topCardIndex, tapCorner: topCorner)
    }
    
    func card(didBeginSwipe card: MGSwipeCard) {
        BackgroundCardAnimator.removeAllAnimations(cardStack: self)
    }
    
    func card(didContinueSwipe card: MGSwipeCard) {
        if visibleCards.count <= 1 { return }
        
        let panTranslation = card.panGestureRecognizer.translation(in: superview)
        let minimumSideLength = min(bounds.width, bounds.height)
        let percentTranslation = max(min(1, 2 * abs(panTranslation.x)/minimumSideLength), min(1, 2 * abs(panTranslation.y)/minimumSideLength))
        
        for i in 1..<visibleCards.count {
            let backgroundCard = visibleCards[i]
            let originalTransform = transformForCard(at: i)
            let nextTransform = transformForCard(at: i - 1)
            backgroundCard.layer.setAffineTransform(originalTransform.percentTransform(with: nextTransform, percent: percentTranslation))
        }
    }
    
    func card(willSwipe card: MGSwipeCard, with direction: SwipeDirection, forced: Bool) {
        delegate?.cardStack(self, didSwipeCardAt: topCardIndex, with: direction)
        isUserInteractionEnabled = false
        
        //remove swiped card
        visibleCards.remove(at: 0)
        
        //set new state
        let newCurrentState = CardStackState(remainingIndices: Array(currentState.remainingIndices.dropFirst()), previousSwipe: (index: topCardIndex, direction: direction), previousState: currentState)
        currentState = newCurrentState
        
        //no cards left
        if currentState.remainingIndices.count == 0 {
            delegate?.didSwipeAllCards(self)
            self.isUserInteractionEnabled = true
            return
        }
        
        //insert new card (if needed)
        if currentState.remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
            if let card = loadCard(at: bottomCardIndex) {
                insertCard(card, at: visibleCards.count)
            }
        }
        
        //animate background cards, enable interaction once loaded
        BackgroundCardAnimator.swipe(cardStack: self, forced: forced) { (finished) in
            if finished {
                self.topCard?.isUserInteractionEnabled = true
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    func card(willUndo card: MGSwipeCard, from direction: SwipeDirection) {
        isUserInteractionEnabled = false
        BackgroundCardAnimator.undo(cardStack: self, completion: nil)
    }
    
    func card(didUndo card: MGSwipeCard, from direction: SwipeDirection) {
        isUserInteractionEnabled = true
    }
    
    func card(didCancelSwipe card: MGSwipeCard) {
        BackgroundCardAnimator.cancelSwipe(cardStack: self, completion: nil)
    }
}
