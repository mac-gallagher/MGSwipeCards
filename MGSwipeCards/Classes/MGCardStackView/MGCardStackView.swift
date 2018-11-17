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
    func cardStack(_ cardStack: MGCardStackView, cardForIndexAt index: Int) -> MGSwipeCard
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

open class MGCardStackView: UIViewHelper {
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
    
    var visibleCards: [MGSwipeCard] = []

    var topCard: MGSwipeCard? {
        return visibleCards.first ?? nil
    }
    
    var currentState: CardStackState = .emptyState
    
    var cardContainer = UIView()
    
    //MARK: - Initialization
    
    override open func initialize() {
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
    
    func layoutCard(_ card: MGSwipeCard, at index: Int) {
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
    
    func insertCard(_ card: MGSwipeCard, at index: Int) {
        cardContainer.insertSubview(card, at: visibleCards.count - index)
        layoutCard(card, at: index)
        visibleCards.insert(card, at: index)
    }
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection) {
        guard let topCard = topCard else { return }
        if !isUserInteractionEnabled { return }
        topCard.swipe(direction: direction)
    }
    
    public func undoLastSwipe() {
        guard let lastSwipe = currentState.previousSwipe else { return }
        if !isUserInteractionEnabled { return }
        delegate?.cardStack(self, didUndoCardAt: lastSwipe.index, from: lastSwipe.direction)
        loadState(currentState.previousState!)
        topCard?.undoSwipe(from: lastSwipe.direction)
    }
    
    public func shift(withDistance distance: Int = 1, animated: Bool) {
        if distance == 0 || visibleCards.count <= 1 { return }
        if !isUserInteractionEnabled { return }
        let newState = CardStackState(remainingIndices: currentState.remainingIndices.shift(withDistance: distance),
                                             previousSwipe: currentState.previousSwipe,
                                             previousState: currentState.previousState)
        loadState(newState)
        if animated {
            BackgroundCardAnimator.shift(cardStack: self, withDistance: distance, completion: nil)
        }
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
    
    func loadCard(at index: Int) -> MGSwipeCard? {
        guard let dataSource = dataSource else { return nil }
        let card = dataSource.cardStack(self, cardForIndexAt: index)
        card.delegate = self
        return card
    }
}

