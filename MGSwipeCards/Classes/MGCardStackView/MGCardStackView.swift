//
//  MGCardStackView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

/**
 A data structure is used to represent the current state of the card stack.
 
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
    
    private var currentState: CardStackState = .emptyState {
        didSet { loadCurrentState() }
    }
    
    private lazy var animator = CardStackAnimator(cardStack: self)
    
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
            layoutCard(card, at: index)
        }
    }

    //TODO: Allow user to set their own frame
    private func layoutCard(_ card: MGSwipeCard, at index: Int) {
        card.transform = CGAffineTransform.identity
        card.frame = cardStack.bounds
        if index == 0 {
            card.isUserInteractionEnabled = true
        } else {
            card.isUserInteractionEnabled = false
            card.transform = CGAffineTransform(scaleX: options.backgroundCardScaleFactor, y: options.backgroundCardScaleFactor)
        }
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards(in: self)
        currentState = CardStackState(remainingIndices: Array(0..<numberOfCards), previousSwipe: nil, previousState: nil)
    }
    
    private func loadCurrentState() {
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
    
    private func insertCard(_ card: MGSwipeCard, at index: Int) {
        cardStack.insertSubview(card, at: visibleCards.count - index)
        visibleCards.insert(card, at: index)
        layoutCard(card, at: index)
    }
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection) {
        guard let topCard = topCard else { return }
        
        if !topCard.isUserInteractionEnabled || animator.isResettingCard { return }
        topCard.isUserInteractionEnabled = false
        animator.applySwipeAnimation(to: topCard, direction: direction, forced: true) { finished in
            if finished {
                topCard.removeFromSuperview()
            }
        }
        handleSwipe(topCard, direction: direction)
    }
    
    private func handleSwipe(_ card: MGSwipeCard, direction: SwipeDirection) {
        delegate?.cardStack(self, didSwipeCardAt: currentCardIndex, with: direction)
        visibleCards.remove(at: 0)
        let newCurrentState = CardStackState(remainingIndices: Array(currentState.remainingIndices.dropFirst()), previousSwipe: (index: currentCardIndex, direction: direction), previousState: currentState)
        currentState = newCurrentState
        
        //no cards left
        if newCurrentState.remainingIndices.count == 0 {
            delegate?.didSwipeAllCards(self)
            return
        }

        //more cards to load
        if newCurrentState.remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
            if let card = loadCard(at: bottomCardIndex) {
                insertCard(card, at: visibleCards.count)
            }
        }

        for (index, card) in visibleCards.enumerated() {
            animator.applyScaleAnimation(to: card, at: index, duration: options.backgroundCardScaleAnimationDuration, delay: options.cardOverlayFadeInOutDuration) { _ in
                self.topCard?.isUserInteractionEnabled = true
            }
        }
    }
    
    public func undoLastSwipe() {
        if currentState.previousState == nil || animator.isResettingCard { return }
        if topCard != nil && !topCard!.isUserInteractionEnabled { return }
        guard let lastSwipe = currentState.previousSwipe else { return }

        delegate?.cardStack(self, didUndoSwipeOnCardAt: lastSwipe.index, from: lastSwipe.direction)
        
        currentState = currentState.previousState!
        
        topCard?.isUserInteractionEnabled = false
        animator.applyReverseSwipeAnimation(to: topCard, from: lastSwipe.direction) { finished in
            if finished {
                self.topCard?.isUserInteractionEnabled = true
            }
        }
        
        if visibleCards.count > 1 {
            visibleCards[1].transform = CGAffineTransform.identity
            for index in 1..<visibleCards.count {
                animator.applyScaleAnimation(to: visibleCards[index], at: index, duration: options.backgroundCardResetAnimationDuration, completion: nil)
            }
        }
    }
    
    public func shift(withDistance distance: Int = 1, animated: Bool) {
        if distance == 0 || visibleCards.count <= 1 { return }
        if !topCard!.isUserInteractionEnabled || animator.isResettingCard { return }
        
        let newCurrentState = CardStackState(remainingIndices: currentState.remainingIndices.shift(withDistance: distance), previousSwipe: currentState.previousSwipe, previousState: currentState.previousState)
        currentState = newCurrentState
        
        if !animated { return }
        if distance > 0 {
            let scaleFactor = options.forwardShiftAnimationInitialScaleFactor
            topCard?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        } else {
            let scaleFactor = options.backwardShiftAnimationInitialScaleFactor
            topCard?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        }
        
        topCard?.isUserInteractionEnabled = false
        animator.applyScaleAnimation(to: topCard, at: 0, duration: 0.1) { _ in
            self.topCard?.isUserInteractionEnabled = true
        }
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
            animator.removeAllAnimations(on: card)
        }
    }
    
    public func card(didContinueSwipe card: MGSwipeCard) {
       card.swipeDirections.forEach { direction in
            card.overlay(forDirection: direction)?.alpha = alphaForOverlay(card, with: direction)
        }
        
        if visibleCards.count <= 1 { return }
        let translation = card.panGestureRecognizer.translation(in: cardStack)
        let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
        let percentTranslation = max(min(1, 2 * abs(translation.x)/minimumSideLength), min(1, 2 * abs(translation.y)/minimumSideLength))
        let scaleFactor = options.backgroundCardScaleFactor + (1 - options.backgroundCardScaleFactor) * percentTranslation
        let nextCard = visibleCards[1]
        nextCard.layer.setAffineTransform(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        func alphaForOverlay(_ card: MGSwipeCard, with direction: SwipeDirection) -> CGFloat {
            if direction != card.activeDirection { return 0 }
            let totalPercentage = card.swipeDirections.reduce(0) { (percentage, direction) in
                return percentage + card.swipePercentage(on: direction)
            }
            return min((2 * card.swipePercentage(on: direction) - totalPercentage)/card.minimumSwipeMargin, 1)
        }
    }
    
    public func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection) {
        card.isUserInteractionEnabled = false
        animator.applySwipeAnimation(to: card, direction: direction) { _ in
            card.removeFromSuperview()
        }
        handleSwipe(card, direction: direction)
    }
    
    public func card(didCancelSwipe card: MGSwipeCard) {
        animator.applyResetAnimation(to: card, completion: nil)
        for index in 1..<visibleCards.count {
            animator.applyScaleAnimation(to: visibleCards[index], at: index, duration: options.backgroundCardResetAnimationDuration, completion: nil)
        }
    }
}
