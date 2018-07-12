//
//  MGCardStackView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class MGCardStackView: UIView {
    
    open var delegate: MGCardStackViewDelegate?
    
    public var dataSource: MGCardStackViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
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
    
    public private(set) var currentCardIndex = 0
    private var numberOfCards = 0
    private var visibleCards: [MGSwipeCard] = []
    private var remainingIndices: [Int] = [] //non-swiped card indices from data source
    private var stateArray: [[Int]] = []
    private var cardStack = UIView()
    
    private static var numberOfVisibleCards: Int = 3
    private static var cardScaleFactor: CGFloat = 0.95
    
    //MARK: - Initialization
    
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
        numberOfCards = dataSource.numberOfCards(in: self)
        currentCardIndex = 0
        stateArray = []
        let freshState = Array(0..<numberOfCards)
        loadState(freshState)
    }
    
    private func loadState(_ state: [Int]) {
        for card in visibleCards {
            card.removeFromSuperview()
        }
        visibleCards = []
        remainingIndices = state
        for index in 0..<min(remainingIndices.count, MGCardStackView.numberOfVisibleCards) {
            if let card = reloadCard(at: remainingIndices[index]) {
                insertCard(card: card, at: remainingIndices[index])
                currentCardIndex = remainingIndices[index]
            }
        }
    }
    
    private func reloadCard(at index: Int) -> MGSwipeCard? {
        guard let dataSource = dataSource else { return nil }
        let card = MGSwipeCard()
        card.footerHeight = dataSource.cardStack(self, heightForCardFooterAt: index)
        card.setFooterView(dataSource.cardStack(self, viewForCardFooterAt: index))
        card.footerIsTransparent = delegate?.cardStack(self, shouldMakeCardFooterTransparentAt: index) ?? false
        card.setContentView(dataSource.cardStack(self, viewforCardAt: index))
        for direction in card.swipeDirections {
            card.setOverlay(forDirection: direction, overlay: dataSource.cardStack(self, viewForCardOverlayAt: index, for: direction))
        }
        card.swipeDirections = delegate?.cardStack(self, allowedSwipeDirectionsForCardAt: index) ?? [.left, .right]
        card.options = delegate?.cardStack(self, optionsForCardAt: index) ?? MGSwipeCardOptions()
        return card
    }
    
    private func insertCard(card: MGSwipeCard, at index: Int) {
//        card.removeAllAnimations()
        card.delegate = self
        cardStack.insertSubview(card, at: visibleCards.count - index)
        visibleCards.insert(card, at: index)
        setFrame(forCard: card, at: index)
    }
    
    //MARK: - Main Methods
    
    public func shift(withDistance distance: Int = 1) {
        if distance == 0 || visibleCards.count <= 1 { return }

        if distance > 0 {
            visibleCards.first?.removeFromSuperview()
            visibleCards.removeFirst()
            remainingIndices.shiftInPlace()
            currentCardIndex = remainingIndices[0]
            let bottomCardIndex = remainingIndices[visibleCards.count]
            let card = reloadCard(at: bottomCardIndex)
            insertCard(card: card!, at: visibleCards.count)
            setFrame(forCard: visibleCards[0], at: 0)
        } else {
            visibleCards.last?.removeFromSuperview()
            visibleCards.removeLast()
            remainingIndices.shiftInPlace(withDistance: -1)
            currentCardIndex = remainingIndices[0]
            let card = reloadCard(at: remainingIndices[0])
            insertCard(card: card!, at: 0)
            setFrame(forCard: visibleCards[1], at: 1)
        }
    }
    
    public func swipe(_ direction: SwipeDirection) {
        if visibleCards.count <= 0 { return }
        let topCard = visibleCards[0]
        if topCard.isUserInteractionEnabled {
            topCard.swipe(withDirection: direction)
        }
    }
    
    private var undoAnimationIsActive = false
    
    //undoLastAction?
    public func undoLastSwipe() -> MGSwipeCard? {
//        if stateArray.count <= 0 { return nil }
//        if undoAnimationIsActive { return nil }
//
//        undoAnimationIsActive = true
//
//        for card in visibleCards {
//            card.transform = CGAffineTransform.identity
//        }
//
//        loadState(self.stateArray.removeLast())
//
//        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
//            self.loadState(self.stateArray.removeLast())
//        }) { (_) in
//
//            self.undoAnimationIsActive = false
//
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//                for direction in self.visibleCards[0].swipeDirections {
//                    self.visibleCards[0].overlay(forDirection: direction)?.alpha = 0
//                }
//            }, completion: nil)
//        }
//        visibleCards[0].resetPosition()
//        return visibleCards[0]
        return nil
    }
 
    private func removeCards(_ cards: [MGSwipeCard]) {
        cards.forEach { card in
            card.delegate = nil
            card.removeFromSuperview()
        }
    }
    
    //MARK: - Setters/Getters
    
    //func viewForCard
    
}

//MARK: - MGSwipeCardDelegate

extension MGCardStackView: MGSwipeCardDelegate {
    
    public func card(didTap card: MGSwipeCard, location: CGPoint) {
        delegate?.cardStack(self, didSelectCardAt: currentCardIndex, touchPoint: location)
    }
    
    public func card(didBeginSwipe card: MGSwipeCard) {
        //remove all animations
    }
    
    //load background card
    public func card(didContinueSwipe card: MGSwipeCard) {
        if visibleCards.count <= 1 { return }
        let topCard = visibleCards[0]
        let translation = topCard.panGestureRecognizer.translation(in: cardStack)
        let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
        let percentTranslation = max(min(1, 2 * abs(translation.x)/minimumSideLength), min(1, 2 * abs(translation.y)/minimumSideLength))
        let scaleFactor = MGCardStackView.cardScaleFactor + (1 - MGCardStackView.cardScaleFactor) * percentTranslation
        let nextCard = visibleCards[1]
        nextCard.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    }
    
    public func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection) {
        stateArray.append(remainingIndices)
        remainingIndices.removeFirst()
        visibleCards.remove(at: 0)
        delegate?.cardStack(self, didSwipeCardAt: currentCardIndex, with: direction)
        
        if remainingIndices.count == 0 {
            delegate?.didSwipeAllCards(self)
            return
        }
        
        //load next card
        
        currentCardIndex = remainingIndices[0]
        if remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = remainingIndices[visibleCards.count]
            let card = reloadCard(at: bottomCardIndex)
            insertCard(card: card!, at: visibleCards.count)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
            self.visibleCards[0].transform = CGAffineTransform.identity
        }) { _ in
            self.visibleCards[0].isUserInteractionEnabled = true
        }

    }
    
    public func card(didCancelSwipe card: MGSwipeCard) {
        //call animator
        //should rasterize is false in completion
        if visibleCards.count <= 1 { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.setFrame(forCard: self.visibleCards[1], at: 1)
        }, completion: nil)
    }
    
}



