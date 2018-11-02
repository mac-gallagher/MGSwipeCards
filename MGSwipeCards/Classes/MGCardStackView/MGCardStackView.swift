//
//  MGCardStackView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import pop

/**
 A data structure used to represent the current state of the card stack.
 
 A new state is created each time a user *swipes*, *shifts*, or *undos* a card on the stack. Each state contains a reference to the state before it.
*/
private class CardStackState {
    static var emptyState = CardStackState(remainingIndices: [], previousSwipe: nil, previousState: nil)
    
    /**
     The indices of the data source which have yet to be swiped by the user.
     
     This array reflects the current order of the card stack, with the first element equal to the index of the top card. The order of this array accounts for both previously swiped cards and cards which may have been reordered in the stack.
    */
    var remainingIndices: [Int]
    
    /**
     The swipe which occured in the previous state.
     
     The `index` parameter refers to the index of the card which was swiped.
     */
    var previousSwipe: (index: Int, direction: SwipeDirection)?
    
    /// A reference to the previous card stack state.
    var previousState: CardStackState?
    
    init(remainingIndices: [Int], previousSwipe: (index: Int, direction: SwipeDirection)?, previousState: CardStackState?) {
        self.remainingIndices = remainingIndices
        self.previousSwipe = previousSwipe
        self.previousState = previousState
    }
}

open class MGCardStackView: UIView {
    
    public var delegate: MGCardStackViewDelegate?

    public var dataSource: MGCardStackViewDataSource? {
        didSet { reloadData() }
    }
    
    /// The maximum number of cards to be displayed on screen.
    open var numberOfVisibleCards: Int = 2
    
    open var cardStackInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    /// The amount of time it takes for the background cards to reset to their original position after a *cancelled swipe*.
    open var backgroundCardResetAnimationDuration: TimeInterval = 0.3
    
    /// The amount of time it takes for the background cards to reset to their original position after a *swipe*, *shift*, or *undo*.
    open var backgroundCardTransformAnimationDuration: TimeInterval = 0.4
    
    public var currentCardIndex: Int {
        return currentState.remainingIndices.first ?? 0
    }
    
    private var visibleCards: [MGSwipeCard] = []

    private var topCard: MGSwipeCard? {
        return visibleCards.first ?? nil
    }
    
    private var currentState: CardStackState = .emptyState
    
    private var cardStack = UIView()
    
    //MARK: - Initialization
    
    public init() {
        super.init(frame: .zero)
        sharedInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(cardStack)
    }
    
    //MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        cardStack.frame = CGRect(x: cardStackInsets.left,
                                 y: cardStackInsets.top,
                                 width: bounds.width - cardStackInsets.left - cardStackInsets.right,
                                 height: bounds.height - cardStackInsets.top - cardStackInsets.bottom)
        
        for (index, card) in visibleCards.enumerated() {
            card.transform = .identity
            card.frame = cardStack.bounds
            card.layer.setAffineTransform(transformForCard(at: index))
            card.isUserInteractionEnabled = index == 0 ? true : false
        }
    }

    /**
     Can be overriden for custom card stack layouts
    */
    open func transformForCard(at index: Int) -> CGAffineTransform {
        if index == 0 { return .identity }
        return CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
    }
    
    private func insertCard(_ card: MGSwipeCard, at index: Int) {
        cardStack.insertSubview(card, at: visibleCards.count - index)
        card.frame =  cardStack.bounds
        card.layer.setAffineTransform(transformForCard(at: index))
        card.isUserInteractionEnabled = index == 0 ? true : false
        visibleCards.insert(card, at: index)
    }
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection) {
        guard let topCard = topCard else { return }
        if !isUserInteractionEnabled { return }
        topCard.swipe(direction: direction, completion: nil)
    }
    
    public func undoLastSwipe() {
        guard let lastSwipe = currentState.previousSwipe else { return }
        if !isUserInteractionEnabled { return }
        isUserInteractionEnabled = false
        delegate?.cardStack(self, didUndoSwipeOnCardAt: lastSwipe.index, from: lastSwipe.direction)

        currentState = currentState.previousState!
        reloadCurrentState()

        topCard?.reverseSwipe(from: lastSwipe.direction) { _ in
            self.isUserInteractionEnabled = true
        }
    }
    
    public func shift(withDistance distance: Int = 1, animated: Bool) {
        if distance == 0 || visibleCards.count <= 1 { return }
        if !isUserInteractionEnabled { return }
        let newCurrentState = CardStackState(remainingIndices: currentState.remainingIndices.shift(withDistance: distance), previousSwipe: currentState.previousSwipe, previousState: currentState.previousState)
        currentState = newCurrentState
        reloadCurrentState()
        
        if !animated { return }
        
        //place background cards in old positions
        if distance > 0 {
            for i in 0..<visibleCards.count {
                visibleCards[i].transform = transformForCard(at: i + 1)
            }
        } else {
            for i in 1..<visibleCards.count {
                visibleCards[i].transform = transformForCard(at: i - 1)
            }
        }
        
        //animate background cards to new positions
        for i in 0..<visibleCards.count {
            POPAnimator.applyTransformAnimation(to: visibleCards[i], toValue: transformForCard(at: i), duration: backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards(in: self)
        currentState = CardStackState(remainingIndices: Array(0..<numberOfCards), previousSwipe: nil, previousState: nil)
        reloadCurrentState()
    }
    
    private func reloadCurrentState() {
        visibleCards.forEach { card in
            card.removeFromSuperview()
        }
        visibleCards.removeAll()
        for index in 0..<min(currentState.remainingIndices.count, numberOfVisibleCards) {
            if let card = loadCard(at: currentState.remainingIndices[index]) {
                insertCard(card, at: index)
            }
        }
    }
    
    private func loadCard(at index: Int) -> MGSwipeCard? {
        guard let dataSource = dataSource else { return nil }
        let card = dataSource.cardStack(self, cardForIndexAt: index)
        card.delegate = self
        return card
    }
}

//MARK: - MGSwipeCardDelegate

//TODO: Move code to external animator class?

extension MGCardStackView: MGSwipeCardDelegate {
    
    public func card(didTap card: MGSwipeCard) {
        delegate?.cardStack(self, didSelectCardAt: currentCardIndex)
        
        let location = card.tapGestureRecognizer.location(in: card.superview)
        let topCorner: UIRectCorner
        if location.x < card.bounds.width / 2 {
            topCorner = location.y < card.bounds.height / 2 ? .topLeft : .bottomLeft
        } else {
            topCorner = location.y < card.bounds.height / 2 ? .topRight : .bottomRight
        }
        delegate?.cardStack(self, didSelectCardAt: currentCardIndex, tapCorner: topCorner)
    }
    
    public func card(didBeginSwipe card: MGSwipeCard) {
        for i in 1..<visibleCards.count {
            POPAnimator.removeAllCardAnimations(on: visibleCards[i])
        }
    }
    
    /**
     Actively transforms each background card into its next position.
    */
    public func card(didContinueSwipe card: MGSwipeCard) {
        if visibleCards.count <= 1 { return }
        
        let panTranslation = card.panGestureRecognizer.translation(in: cardStack)
        let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
        let percentTranslation = max(min(1, 2 * abs(panTranslation.x)/minimumSideLength), min(1, 2 * abs(panTranslation.y)/minimumSideLength))
        
        for i in 1..<visibleCards.count {
            let backgroundCard = visibleCards[i]
            let originalTransform = transformForCard(at: i)
            let nextTransform = transformForCard(at: i - 1)
            backgroundCard.layer.setAffineTransform(originalTransform.percentTransform(with: nextTransform, percent: percentTranslation))
        }
    }
    
    public func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection) {
        delegate?.cardStack(self, didSwipeCardAt: currentCardIndex, with: direction)
        isUserInteractionEnabled = false
        
        //remove swiped card
        visibleCards.remove(at: 0)
        
        //set new state
        let newCurrentState = CardStackState(remainingIndices: Array(currentState.remainingIndices.dropFirst()), previousSwipe: (index: currentCardIndex, direction: direction), previousState: currentState)
        currentState = newCurrentState
        
        //no cards left
        if newCurrentState.remainingIndices.count == 0 {
            delegate?.didSwipeAllCards(self)
            self.isUserInteractionEnabled = true
            return
        }
        
        //load new card (if needed)
        if newCurrentState.remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
            if let card = loadCard(at: bottomCardIndex) {
                insertCard(card, at: visibleCards.count)
            }
        }
        
        //animate background cards to new positions
        for (index, card) in visibleCards.enumerated() {
            POPAnimator.applyTransformAnimation(to: card, toValue: transformForCard(at: index), delay: card.overlayFadeAnimationDuration, duration: backgroundCardTransformAnimationDuration) { (_, finished) in
                if finished {
                    self.topCard?.isUserInteractionEnabled = true
                    self.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    public func card(didUndo card: MGSwipeCard, from direction: SwipeDirection) {
        //place background cards in old positions
        for i in 1..<visibleCards.count {
            visibleCards[i].transform = transformForCard(at: i - 1)
        }
        
        //animate background cards to new positions
        for i in 1..<visibleCards.count {
            POPAnimator.applyTransformAnimation(to: visibleCards[i], toValue: transformForCard(at: i), duration: backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
    
    public func card(didCancelSwipe card: MGSwipeCard) {
        for i in 1..<visibleCards.count {
            POPAnimator.applyTransformAnimation(to: visibleCards[i], toValue: transformForCard(at: i), duration: backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
}
