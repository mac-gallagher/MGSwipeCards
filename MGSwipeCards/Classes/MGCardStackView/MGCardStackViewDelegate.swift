//
//  MGSwipeableCardContainerDelegate.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/31/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import Foundation

@objc public protocol MGCardStackViewDelegate {
    
    @objc optional func didSwipeAllCards()
    
    @objc optional func didEndSwipe(on card: MGSwipeCard, withDirection direction: SwipeDirection)
    
    @objc optional func didTap(on card: MGSwipeCard, recognizer: UITapGestureRecognizer)
    
}
