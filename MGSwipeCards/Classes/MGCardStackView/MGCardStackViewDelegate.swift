//
//  MGSwipeableCardContainerDelegate.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/31/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import Foundation

public protocol MGCardStackViewDelegate {
    
    func didSwipeAllCards()
    
    func didEndSwipe(on card: MGSwipeCard, withDirection direction: SwipeDirection)
    
    func didTap(on card: MGSwipeCard, recognizer: UITapGestureRecognizer)
    
}
