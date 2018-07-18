//
//  MGCardStackView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

internal struct State {
    static var emptyState = State(remainingIndices: [], lastSwipedCardIndex: nil, lastSwipedDirection: nil)
    var remainingIndices: [Int]
    var lastSwipedCardIndex: Int?
    var lastSwipedDirection: SwipeDirection?
}

open class MGCardStackView: UIView {
    
    open var delegate: MGCardStackViewDelegate? {
        didSet {
            if let options = delegate?.additionalOptions(self) {
                self.options = options
            }
        }
    }
    
    public var dataSource: MGCardStackViewDataSource? {
        didSet { reloadData() }
    }
    
    public private(set) var options = MGCardStackViewOptions.defaultOptions
    
    private lazy var animator = CardStackAnimator(cardStack: self)
    
    private var visibleCards: [MGSwipeCard] = []
    private var topCard: MGSwipeCard? {
        return visibleCards.first ?? nil
    }
    
    private var lastSwipedCard: MGSwipeCard?
    private var lastSwipedCardIsVisible: Bool {
        return lastSwipedCard?.frame.intersects(UIScreen.main.bounds) ?? false
    }
    
    private var states: [State] = []
    private var currentState: State {
        return states.last ?? State.emptyState
    }
    public var currentCardIndex: Int {
        return currentState.remainingIndices.first ?? 0
    }
    
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
        layoutCardStack()
    }
    
    private func layoutCardStack() {
        for (index, card) in visibleCards.enumerated() {
            layoutCard(card, at: index)
        }
    }
    
    private func layoutBackgroundCards() {
        for index in 1..<visibleCards.count {
            layoutCard(visibleCards[index], at: index)
        }
    }
    
    private func layoutCard(_ card: MGSwipeCard?, at index: Int) {
        card?.transform = CGAffineTransform.identity
        card?.frame = cardStack.bounds
        if index == 0 {
            card?.isUserInteractionEnabled = true
        } else {
            card?.transform = CGAffineTransform(scaleX: options.backgroundCardScaleFactor, y: options.backgroundCardScaleFactor)
            card?.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - Data Source
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards(in: self)
        states = []
        states.append(State(remainingIndices: Array(0..<numberOfCards), lastSwipedCardIndex: nil, lastSwipedDirection: nil))
        loadState(atStateArrayIndex: 0)
    }
    
    private func loadState(atStateArrayIndex index: Int) {
        visibleCards.forEach { card in
            card.removeFromSuperview()
        }
        visibleCards = []
        states.removeLast(states.count - (index + 1))
        for index in 0..<min(currentState.remainingIndices.count, options.numberOfVisibleCards) {
            if let card = reloadCard(at: currentState.remainingIndices[index]) {
                cardStack.insertSubview(card, at: visibleCards.count - index)
                visibleCards.insert(card, at: index)
            }
        }
    }
    
    private func reloadCard(at index: Int) -> MGSwipeCard? {
        guard let dataSource = dataSource else { return nil }
        let card = dataSource.cardStack(self, cardForIndexAt: index)
        if let options = delegate?.cardStack(self, additionalOptionsForCardAt: index) {
            card.options = options
        }
        card.delegate = self
        return card
    }
    
    //MARK: - Main Methods
    
    public func swipe(_ direction: SwipeDirection, randomLeftRightRotation: Bool = true) {
        if lastSwipedCardIsVisible || animator.isResettingCard { return }
        if let topCard = topCard {
            topCard.isUserInteractionEnabled = false
            animator.applySwipeAnimation(to: topCard, direction: direction, forced: true) { finished in
                if finished {
                    topCard.removeFromSuperview()
                }
            }
            swipe(topCard, direction: direction)
        }
    }
    
    private func swipe(_ card: MGSwipeCard, direction: SwipeDirection) {
        if lastSwipedCardIsVisible || animator.isResettingCard { return }
        delegate?.cardStack(self, didSwipeCardAt: currentCardIndex, with: direction)
        visibleCards.remove(at: 0)
        lastSwipedCard = card
        let newState = State(remainingIndices: Array(currentState.remainingIndices.dropFirst()), lastSwipedCardIndex: currentCardIndex, lastSwipedDirection: direction)
        states.append(newState)

        if currentState.remainingIndices.count == 0 {
            delegate?.didSwipeAllCards(self)
            return
        }

        if currentState.remainingIndices.count - visibleCards.count > 0 {
            let bottomCardIndex = currentState.remainingIndices[visibleCards.count]
            if let card = reloadCard(at: bottomCardIndex) {
                cardStack.insertSubview(card, at: 0)
                visibleCards.insert(card, at: visibleCards.count)
                layoutCard(card, at: visibleCards.count)
            }
        }

        UIView.animate(withDuration: options.backgroundCardResetAnimationDuration, delay: options.cardOverlayFadeInOutDuration, options: .curveLinear, animations: {
            self.layoutCardStack()
        }, completion: nil)

        topCard?.isUserInteractionEnabled = false
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(handleUserInteractionTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func handleUserInteractionTimer(_ timer: Timer) {
        if !lastSwipedCardIsVisible {
            if visibleCards.count > 0 {
                topCard?.isUserInteractionEnabled = true
            }
            timer.invalidate()
        }
    }
    
    public func undoLastSwipe() {
        if states.count <= 1 { return }
        if lastSwipedCardIsVisible || animator.isResettingCard { return }
        guard let lastSwipedIndex = currentState.lastSwipedCardIndex, let direction = currentState.lastSwipedDirection else { return }
        
        delegate?.cardStack(self, didUndoSwipeOnCardAt: lastSwipedIndex, from: direction)
        loadState(atStateArrayIndex: self.states.count - 2)
        
        layoutCard(topCard, at: 0)
        topCard?.isUserInteractionEnabled = false
        animator.applyReverseSwipeAnimation(to: topCard, from: direction) { finished in
            if finished {
                self.topCard?.isUserInteractionEnabled = true
            }
        }
        UIView.animate(withDuration: options.backgroundCardResetAnimationDuration, animations: {
            self.layoutBackgroundCards()
        })
    }

    public func shift(withDistance distance: Int = 1) {
        if distance == 0 || visibleCards.count <= 1 { return }
        if lastSwipedCardIsVisible || animator.isResettingCard { return }
        let newState = State(remainingIndices: currentState.remainingIndices.shift(withDistance: distance), lastSwipedCardIndex: currentState.lastSwipedCardIndex, lastSwipedDirection: currentState.lastSwipedDirection)
        states.removeLast()
        states.append(newState)
        loadState(atStateArrayIndex: self.states.count - 1)

        layoutCardStack()
        if delegate?.shouldDisableShiftAnimation(self) == true { return }
        if distance > 0 {
            let scaleFactor = options.forwardShiftAnimationInitialScaleFactor
            topCard?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        } else {
            let scaleFactor = options.backwardShiftAnimationInitialScaleFactor
            topCard?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        }
        UIView.animate(withDuration: 0.1) {
            self.layoutCard(self.topCard, at: 0)
        }
    }
    
}

//MARK: - MGSwipeCardDelegate

extension MGCardStackView: MGSwipeCardDelegate {
    
    public func card(didTap card: MGSwipeCard, location: CGPoint) {
        delegate?.cardStack(self, didSelectCardAt: currentCardIndex, touchPoint: location)
    }
    
    public func card(didBeginSwipe card: MGSwipeCard) {
        animator.removeAllSwipeAnimations(on: card)
    }
    
    public func card(didContinueSwipe card: MGSwipeCard) {
        if visibleCards.count <= 1 { return }
        guard let topCard = topCard else { return }
        let translation = topCard.panGestureRecognizer.translation(in: cardStack)
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
            return min((2 * card.swipePercentage(on: direction) - totalPercentage)/card.options.minimumSwipeMargin, 1)
        }
        
        card.swipeDirections.forEach { direction in
            card.overlay(forDirection: direction)?.alpha = alphaForOverlay(card, with: direction)
        }
    }
    
    public func card(didSwipe card: MGSwipeCard, with direction: SwipeDirection) {
        card.isUserInteractionEnabled = false
        animator.applySwipeAnimation(to: card, direction: direction) { _ in
            card.removeFromSuperview()
        }
        swipe(card, direction: direction)
    }
    
    public func card(didCancelSwipe card: MGSwipeCard) {
        animator.applyResetAnimation(to: card, completion: nil)
        if visibleCards.count <= 1 { return }
        UIView.animate(withDuration: options.backgroundCardResetAnimationDuration, delay: 0, options: .curveLinear, animations: {
            self.layoutBackgroundCards()
        }, completion: nil)
    }
    
}












