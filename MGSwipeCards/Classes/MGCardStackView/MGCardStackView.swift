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
    
    /**
     A reference to the previous card stack state.
    */
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
    
    public var options: MGCardStackViewOptions = .defaultOptions {
        didSet { layoutIfNeeded() }
    }
    
    public var currentCardIndex: Int {
        return currentState.remainingIndices.first ?? 0
    }
    
    private var visibleCards: [MGSwipeCard] = []

    private var topCard: MGSwipeCard? {
        return visibleCards.first ?? nil
    }
    
    private var currentState: CardStackState = .emptyState
    
    private lazy var cardAnimator = CardStackAnimator(cardStack: self)
    
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
        cardStack.frame = CGRect(x: options.cardStackInsets.left,
                                 y: options.cardStackInsets.top,
                                 width: bounds.width - options.cardStackInsets.left - options.cardStackInsets.right,
                                 height: bounds.height - options.cardStackInsets.top - options.cardStackInsets.bottom)
        
        for (index, card) in visibleCards.enumerated() {
            card.transform = .identity
            card.frame = cardStack.bounds
            applyTransformToCard(card, at: index)
        }
    }

    //Temporary functionality for testing
    open func transformForCard(at index: Int) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        if index == 0 { return transform }
        if index % 2 == 0 {
            transform = transform.translatedBy(x: -20 * CGFloat(index), y: 20 * CGFloat(index))
            transform = transform.rotated(by: -CGFloat(Double.pi/12))
        } else {
            transform = transform.translatedBy(x: 20 * CGFloat(index), y: 20 * CGFloat(index))
            transform = transform.rotated(by: CGFloat(Double.pi/12))
        }
        return transform.scaledBy(x: (1 - CGFloat(index) * 0.2), y: (1 - CGFloat(index) * 0.2))
    }
    
    private func applyTransformToCard(_ card: MGSwipeCard, at index: Int) {
        card.layer.setAffineTransform(transformForCard(at: index))
        if index == 0 {
            card.isUserInteractionEnabled = true
        } else {
            card.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection) {
        guard let topCard = topCard else { return }
        if !topCard.isUserInteractionEnabled || cardAnimator.isResettingCard { return }
        
        topCard.isUserInteractionEnabled = false
        cardAnimator.applySwipeAnimation(to: topCard, direction: direction, forced: true) { finished in
            if finished {
                topCard.removeFromSuperview()
            }
        }
        handleSwipe(direction: direction)
    }
    
    private func handleSwipe(direction: SwipeDirection) {
        delegate?.cardStack(self, didSwipeCardAt: currentCardIndex, with: direction)
        visibleCards.remove(at: 0)
        
        //set new state
        let newCurrentState = CardStackState(remainingIndices: Array(currentState.remainingIndices.dropFirst()), previousSwipe: (index: currentCardIndex, direction: direction), previousState: currentState)
        currentState = newCurrentState

        //no cards left
        if newCurrentState.remainingIndices.count == 0 {
            delegate?.didSwipeAllCards(self)
            return
        }

        //load new card (if needed)
        if newCurrentState.remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
            if let card = loadCard(at: bottomCardIndex) {
                insertCard(card, at: visibleCards.count)
            }
        }

        //animate background cards
        for (index, card) in visibleCards.enumerated() {
            POPAnimator.applyTransformAnimation(to: card, toValue: transformForCard(at: index), delay: options.cardOverlayFadeInOutDuration, duration: options.backgroundCardScaleAnimationDuration) { (_, finished) in
                if finished {
                    self.topCard?.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    //TODO: Animate this
    public func undoLastSwipe() {
        if currentState.previousState == nil || cardAnimator.isResettingCard { return }
        if topCard != nil && !topCard!.isUserInteractionEnabled { return }
        guard let lastSwipe = currentState.previousSwipe else { return }

        delegate?.cardStack(self, didUndoSwipeOnCardAt: lastSwipe.index, from: lastSwipe.direction)

        //set new state
        currentState = currentState.previousState!
        reloadCurrentState()

        //animate top card
        topCard?.isUserInteractionEnabled = false
        cardAnimator.applyReverseSwipeAnimation(to: topCard, from: lastSwipe.direction) { finished in
            if finished {
                self.topCard?.isUserInteractionEnabled = true
            }
        }
    }
    
    //TODO: Animate this
    public func shift(withDistance distance: Int = 1) {
        if distance == 0 || visibleCards.count <= 1 { return }
        if !topCard!.isUserInteractionEnabled || cardAnimator.isResettingCard { return }

        let newCurrentState = CardStackState(remainingIndices: currentState.remainingIndices.shift(withDistance: distance), previousSwipe: currentState.previousSwipe, previousState: currentState.previousState)
        currentState = newCurrentState
        reloadCurrentState()
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
        for index in 0..<min(currentState.remainingIndices.count, options.numberOfVisibleCards) {
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
    
    //Should only be called when adding new card to card stack
    private func insertCard(_ card: MGSwipeCard, at index: Int) {
        cardStack.insertSubview(card, at: visibleCards.count - index)
        card.frame =  cardStack.bounds
        applyTransformToCard(card, at: index)
        visibleCards.insert(card, at: index)
    }
}

//MARK: - MGSwipeCardDelegate

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
        visibleCards.forEach { card in
            cardAnimator.removeAllAnimations(on: card)
        }
    }
    
    /**
     Actively transforms each background card into its next position.
    */
    public func card(didContinueSwipe card: MGSwipeCard) {
        
        func alphaForOverlay(_ card: MGSwipeCard, with direction: SwipeDirection) -> CGFloat {
            if direction != card.activeDirection { return 0 }
            let totalPercentage = card.swipeDirections.reduce(0) { (percentage, direction) in
                return percentage + card.swipePercentage(on: direction)
            }
            return min((2 * card.swipePercentage(on: direction) - totalPercentage)/card.minimumSwipeMargin, 1)
        }
        
        //Apply new alpha to overlays on top card
        card.swipeDirections.forEach { direction in
            card.overlay(forDirection: direction)?.alpha = alphaForOverlay(card, with: direction)
        }
        
        //Apply transform to background cards
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
        card.isUserInteractionEnabled = false
        cardAnimator.applySwipeAnimation(to: card, direction: direction) { _ in
            card.removeFromSuperview()
        }
        handleSwipe(direction: direction)
    }
    
    public func card(didCancelSwipe card: MGSwipeCard) {
        cardAnimator.applyResetAnimation(to: card, completion: nil)
        for i in 1..<visibleCards.count {
            POPAnimator.applyTransformAnimation(to: visibleCards[i], toValue: transformForCard(at: i), duration: options.backgroundCardResetAnimationDuration, completionBlock: nil)
        }
    }
}
