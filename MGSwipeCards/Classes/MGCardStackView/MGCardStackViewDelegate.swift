//
//  MGSwipeableCardContainerDelegate.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/31/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import Foundation

public protocol MGCardStackViewDelegate {
    
    func didSwipeAllCards(_ cardStack: MGCardStackView)
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection)
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, touchPoint: CGPoint)
    func cardStack(_ cardStack: MGCardStackView, additionalOptionsForCardAt index: Int) -> MGSwipeCardOptions
}

public extension MGCardStackViewDelegate {
    
    func didSwipeAllCards(_ cardStack: MGCardStackView) {}
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection) {}
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, touchPoint: CGPoint) {}
    func cardStack(_ cardStack: MGCardStackView, additionalOptionsForCardAt index: Int) -> MGSwipeCardOptions { return MGSwipeCardOptions.defaultOptions }
}
