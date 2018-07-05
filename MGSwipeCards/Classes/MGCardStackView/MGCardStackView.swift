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
    
    private var stateArray: [[Int]] = []
    
    private var cardStack = UIView()
    
    private static var numberOfVisibleCards: Int = 2
    
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
        cardStack.frame = CGRect(x: horizontalInset, y: verticalInset, width: bounds.width - 2 * horizontalInset, height: bounds.height - 2 * verticalInset)
        for (index, card) in visibleCards.enumerated() {
            setFrame(forCard: card, at: index)
        }
    }
    
    private func setFrame(forCard card: MGSwipeCard, at index: Int) {
        card.transform = CGAffineTransform.identity
        card.frame = cardStack.bounds
        if index == 0 {
            card.isUserInteractionEnabled = true
        } else {
            card.transform = CGAffineTransform(scaleX: MGCardStackView.cardScaleFactor, y: MGCardStackView.cardScaleFactor)
            card.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards()
        stateArray = []
        let freshState = Array(0..<numberOfCards)
        loadState(freshState)
    }
    
    private func loadState(_ state: [Int]) {
        guard let dataSource = dataSource else { return }
        for card in visibleCards {
            card.removeFromSuperview()
        }
        visibleCards = []
        remainingIndices = state
        for index in 0..<min(remainingIndices.count, MGCardStackView.numberOfVisibleCards) {
            let card = dataSource.card(forItemAtIndex: remainingIndices[index])
            insertCard(card: card, at: index)
        }
    }
    
    private func insertCard(card: MGSwipeCard, at index: Int) {
        card.removeAllAnimations()
        card.delegate = self
        cardStack.insertSubview(card, at: visibleCards.count - index)
        visibleCards.insert(card, at: index)
        setFrame(forCard: card, at: index)
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
            setFrame(forCard: visibleCards[0], at: 0)
        } else {
            visibleCards.last?.removeFromSuperview()
            visibleCards.removeLast()
            remainingIndices.shiftInPlace(withDistance: -1)
            let card = dataSource.card(forItemAtIndex: remainingIndices[0])
            insertCard(card: card, at: 0)
            setFrame(forCard: visibleCards[1], at: 1)
        }
    }
    
    public func swipe(withDirection direction: SwipeDirection) {
        if visibleCards.count <= 0 { return }
        let topCard = visibleCards[0]
        if topCard.isUserInteractionEnabled {
            topCard.performSwipe(withDirection: direction)
        }
    }
    
    private var undoAnimationIsActive = false
    
    public func undoLastSwipe() -> MGSwipeCard? {
        if stateArray.count <= 0 { return nil }
        if undoAnimationIsActive { return nil }
        
        undoAnimationIsActive = true
        
        for card in visibleCards {
            card.transform = CGAffineTransform.identity
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.loadState(self.stateArray.removeLast())
        }) { (_) in

            self.undoAnimationIsActive = false

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                for direction in self.visibleCards[0].swipeDirections {
                    self.visibleCards[0].overlays[direction]??.alpha = 0
                }
            }, completion: nil)
        }
        return visibleCards[0]
    }
    
}

//MARK: - MGSwipeCardDelegate

extension MGCardStackView: MGSwipeCardDelegate {
    
    public func didTap(on card: MGSwipeCard, recognizer: UITapGestureRecognizer) {
        delegate?.didTap(on: card, recognizer: recognizer)
    }
    
    public func beginSwiping(on card: MGSwipeCard) {
    }
    
    //continuously animate loading of next card
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
        stateArray.append(remainingIndices)
        remainingIndices.removeFirst()
        visibleCards.remove(at: 0)
        delegate?.didEndSwipe(on: card, withDirection: direction)

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
            self.setFrame(forCard: self.visibleCards[1], at: 1)
        }, completion: nil)
    }
    
}



