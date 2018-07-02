//
//  MGCardStackView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class MGCardStackView: UIView {
    
    //MARK: - Variables
    
    open var delegate: MGCardStackViewDelegate?
    
    open var horizontalInset: CGFloat = 10.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var verticalInset: CGFloat = 10.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var dataSource: MGCardStackViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    private var visibleCards: [MGSwipeCard] = []
    
    private var remainingIndices: [Int] = [] //non-swiped card indices from data source
    
    private var cardStack = UIView()
    
    private static var numberOfVisibleCards: Int = 3
    
    private static var cardScaleFactor: CGFloat = 0.95
    
    //MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(cardStack)
    }
    
    //MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        cardStack.frame = CGRect(x: horizontalInset, y: verticalInset, width: frame.width - 2 * horizontalInset, height: frame.height - 2 * verticalInset)
        reloadData()
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        for card in visibleCards {
            card.removeFromSuperview()
        }
        visibleCards = []
        let numberOfCards = dataSource.numberOfCards()
        remainingIndices = Array(0..<numberOfCards)
        for index in 0..<min(numberOfCards, MGCardStackView.numberOfVisibleCards) {
            let card = dataSource.card(forItemAtIndex: index)
            card.delegate = self
            insertCard(card: card, at: index)
        }
    }
    
    private func insertCard(card: MGSwipeCard, at index: Int) {
        cardStack.insertSubview(card, at: visibleCards.count - index)
        visibleCards.insert(card, at: index)
        card.transform = CGAffineTransform.identity
        card.frame = cardStack.bounds
        card.delegate = self
        resetTransform(card: card, at: index)
    }
    
    private func resetTransform(card: MGSwipeCard, at index: Int) {
        if index == 0 {
            card.transform = CGAffineTransform.identity
            card.isUserInteractionEnabled = true
        } else {
            card.transform = CGAffineTransform(scaleX: MGCardStackView.cardScaleFactor, y: MGCardStackView.cardScaleFactor)
            card.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - Main Methods
    
    public func shift(withDistance distance: Int = 1) {
        if distance == 0 || visibleCards.count <= 1 { return }
        
        guard let dataSource = dataSource else { return }
        
        if distance > 0 {
            visibleCards.first?.removeFromSuperview()
            visibleCards.removeFirst()
            remainingIndices.shiftInPlace()
            let bottomCardIndex = remainingIndices[visibleCards.count]
            let card = dataSource.card(forItemAtIndex: bottomCardIndex)
            insertCard(card: card, at: visibleCards.count)
            resetTransform(card: visibleCards[0], at: 0)
        } else {
            visibleCards.last?.removeFromSuperview()
            visibleCards.removeLast()
            remainingIndices.shiftInPlace(withDistance: -1)
            let card = dataSource.card(forItemAtIndex: remainingIndices[0])
            insertCard(card: card, at: 0)
            resetTransform(card: visibleCards[1], at: 1)
        }
    }
    
    public func swipe(withDirection direction: SwipeDirection) {
        if visibleCards.count <= 0 { return }
        let topCard = visibleCards[0]
        if topCard.isUserInteractionEnabled {
            topCard.performSwipe(withDirection: direction)
        }
    }
    
}

//MARK: - MGSwipeCardDelegate

extension MGCardStackView: MGSwipeCardDelegate {
    
    public func beginSwiping(on card: MGSwipeCard) {
    }
    
    public func continueSwiping(on card: MGSwipeCard) {
        if visibleCards.count <= 1 { return }
        let topCard = visibleCards[0]
        let translation = topCard.panGestureRecognizer.translation(in: cardStack)
        let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
        let percentTranslation = max(min(1, 2 * abs(translation.x)/minimumSideLength), min(1, 2 * abs(translation.y)/minimumSideLength))
        let scaleFactor = MGCardStackView.cardScaleFactor + (1 - MGCardStackView.cardScaleFactor) * percentTranslation
        let nextCard = visibleCards[1]
        nextCard.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    }
    
    public func didSwipe(on card: MGSwipeCard, withDirection direction: SwipeDirection) {
        remainingIndices.removeFirst()
        let swipedCard = visibleCards.remove(at: 0)
        delegate?.didEndSwipe(on: swipedCard, withDirection: direction)

        if remainingIndices.count == 0 {
            delegate?.didSwipeAllCards()
            return
        }

        //load next card
        guard let dataSource = dataSource else { return }
        if remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = remainingIndices[visibleCards.count]
            let card = dataSource.card(forItemAtIndex: bottomCardIndex)
            insertCard(card: card, at: visibleCards.count)
        }

        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
            self.visibleCards[0].transform = CGAffineTransform.identity
        }) { _ in
            self.visibleCards[0].isUserInteractionEnabled = true
        }

    }
    
    public func didCancelSwipe(on card: MGSwipeCard) {
        if visibleCards.count <= 1 { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.resetTransform(card: self.visibleCards[1], at: 1)
        }, completion: nil)
    }
    
}



