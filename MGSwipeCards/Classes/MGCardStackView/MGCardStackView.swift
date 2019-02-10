//
//  MGCardStackView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

//MARK: - MGCardStackViewDataSource

public protocol MGCardStackViewDataSource {
    func numberOfCards(in cardStack: MGCardStackView) -> Int
    func cardStack(_ cardStack: MGCardStackView, cardForIndexAt index: Int) -> SwipeCard
}

//MARK: - MGCardStackViewDelegate

public protocol MGCardStackViewDelegate {
    func didSwipeAllCards(_ cardStack: MGCardStackView)
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection)
    func cardStack(_ cardStack: MGCardStackView, didUndoCardAt index: Int, from direction: SwipeDirection)
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int)
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, tapCorner: UIRectCorner)
}

public extension MGCardStackViewDelegate {
    func didSwipeAllCards(_ cardStack: MGCardStackView) {}
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection) {}
    func cardStack(_ cardStack: MGCardStackView, didUndoCardAt index: Int, from direction: SwipeDirection) {}
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int) {}
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, tapCorner: UIRectCorner) {}
}

//MARK: - MGCardStackView

open class MGCardStackView: UIView {
    /// The maximum number of cards to be displayed on screen.
    public var numberOfVisibleCards: Int = 2
    
    /// The insets between the edge of the view and its cards.
    public var cardStackInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    public var delegate: MGCardStackViewDelegate?

    public var dataSource: MGCardStackViewDataSource? {
        didSet { reloadData() }
    }
    
    public var topCardIndex: Int {
        return currentState.remainingIndices.first ?? 0
    }
    
    var visibleCards: [SwipeCard] = []

    var topCard: SwipeCard? {
        return visibleCards.first ?? nil
    }
    
    var currentState: CardStackState = .emptyState
    
    var cardContainer = UIView()
    
    //MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(cardContainer)
    }
    
    //MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        cardContainer.frame = CGRect(x: cardStackInsets.left,
                                 y: cardStackInsets.top,
                                 width: bounds.width - cardStackInsets.left - cardStackInsets.right,
                                 height: bounds.height - cardStackInsets.top - cardStackInsets.bottom)
        
        for (index, card) in visibleCards.enumerated() {
            layoutCard(card, at: index)
        }
    }
    
    func layoutCard(_ card: SwipeCard, at index: Int) {
        card.transform = .identity
        card.frame = cardContainer.bounds
        card.layer.setAffineTransform(transformForCard(at: index))
        card.isUserInteractionEnabled = index == 0 ? true : false
        card.layoutIfNeeded()
    }

    /**
     Can be overridden for custom card stack layouts
    */
    open func transformForCard(at index: Int) -> CGAffineTransform {
        if index == 0 { return .identity }
        return CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
    }
    
    func insertCard(_ card: SwipeCard, at index: Int) {
        cardContainer.insertSubview(card, at: visibleCards.count - index)
        layoutCard(card, at: index)
        visibleCards.insert(card, at: index)
    }
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection, animated: Bool) {
//        if !isUserInteractionEnabled { return }
        topCard?.swipe(direction: direction, animated: animated)
    }
    
    public func undoLastSwipe(animated: Bool) {
        guard let lastSwipe = currentState.previousSwipe else { return }
//        if !isUserInteractionEnabled { return }
//        delegate?.cardStack(self, didUndoCardAt: lastSwipe.index, from: lastSwipe.direction)
//        loadState(currentState.previousState!)
        topCard?.reverseSwipe(from: lastSwipe.direction, animated: animated)
    }
    
    public func shift(withDistance distance: Int = 1, animated: Bool) {
//        if distance == 0 || visibleCards.count <= 1 { return }
//        if !isUserInteractionEnabled { return }
//        let newState = CardStackState(remainingIndices: currentState.remainingIndices.shift(withDistance: distance),
//                                             previousSwipe: currentState.previousSwipe,
//                                             previousState: currentState.previousState)
//        loadState(newState)
//        if animated {
//            BackgroundCardAnimator.shift(cardStack: self, withDistance: distance, completion: nil)
//        }
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards(in: self)
        loadState(CardStackState(remainingIndices: Array(0..<numberOfCards), previousSwipe: nil, previousState: nil))
    }
    
    func loadState(_ state: CardStackState) {
        currentState = state
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
    
    func loadCard(at index: Int) -> SwipeCard? {
        guard let dataSource = dataSource else { return nil }
        let card = dataSource.cardStack(self, cardForIndexAt: index)
        card.delegate = self
        return card
    }
}

//MARK: - MGSwipeCardDelegate

extension MGCardStackView: SwipeCardDelegate {
    public func card(didTap card: SwipeCard) {
        //        delegate?.cardStack(self, didSelectCardAt: topCardIndex)
        //        let location = card.tapGestureRecognizer.location(in: card.superview)
        //        let topCorner: UIRectCorner
        //        if location.x < card.bounds.width / 2 {
        //            topCorner = location.y < card.bounds.height / 2 ? .topLeft : .bottomLeft
        //        } else {
        //            topCorner = location.y < card.bounds.height / 2 ? .topRight : .bottomRight
        //        }
        //        delegate?.cardStack(self, didSelectCardAt: topCardIndex, tapCorner: topCorner)
    }
    
    public func card(didBeginSwipe card: SwipeCard) {}
    
    public func card(didContinueSwipe card: SwipeCard) {
        //        if visibleCards.count <= 1 { return }
        //
        //        let panTranslation = card.panGestureRecognizer.translation(in: superview)
        //        let minimumSideLength = min(bounds.width, bounds.height)
        //        let percentTranslation = max(min(1, 2 * abs(panTranslation.x)/minimumSideLength), min(1, 2 * abs(panTranslation.y)/minimumSideLength))
        //
        //        for i in 1..<visibleCards.count {
        //            let backgroundCard = visibleCards[i]
        //            let originalTransform = transformForCard(at: i)
        //            let nextTransform = transformForCard(at: i - 1)
        //            backgroundCard.layer.setAffineTransform(originalTransform.percentTransform(with: nextTransform, percent: percentTranslation))
        //        }
    }
    
    public func card(didCancelSwipe card: SwipeCard) {
        
    }
    
    public func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool) {
        delegate?.cardStack(self, didSwipeCardAt: topCardIndex, with: direction)
        //        isUserInteractionEnabled = false
        
        //remove swiped card
        //        visibleCards.remove(at: 0)
        
        //set new state
        let newCurrentState = CardStackState(remainingIndices: Array(currentState.remainingIndices.dropFirst()), previousSwipe: (index: topCardIndex, direction: direction), previousState: currentState)
        currentState = newCurrentState
        
        //        //no cards left
        //        if currentState.remainingIndices.count == 0 {
        //            delegate?.didSwipeAllCards(self)
        //            self.isUserInteractionEnabled = true
        //            return
        //        }
        //
        //        //insert new card (if needed)
        //        if currentState.remainingIndices.count - visibleCards.count > 0 {
        //            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
        //            if let card = loadCard(at: bottomCardIndex) {
        //                insertCard(card, at: visibleCards.count)
        //            }
        //        }
        //
        //        BackgroundCardAnimator.removeAllAnimations(cardStack: self)
        //
        //        //animate background cards, enable interaction once loaded
        //        BackgroundCardAnimator.swipe(cardStack: self, forced: forced) { (finished) in
        //            if finished {
        //                self.topCard?.isUserInteractionEnabled = true
        //                self.isUserInteractionEnabled = true
        //            }
        //        }
    }
    
    public func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection) {
        
    }
    
    //
    //    public func card(willUndo card: MGSwipeCard, from direction: SwipeDirection) {
    //        isUserInteractionEnabled = false
    //        BackgroundCardAnimator.undo(cardStack: self, completion: nil)
    //    }
    //
    //    public func card(didUndo card: MGSwipeCard, from direction: SwipeDirection) {
    //        isUserInteractionEnabled = true
    //    }
    //
    //    public func card(didCancelSwipe card: MGSwipeCard) {
    //        BackgroundCardAnimator.cancelSwipe(cardStack: self, completion: nil)
    //    }
}
