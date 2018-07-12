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
    func cardStack(_ cardStack: MGCardStackView, allowedSwipeDirectionsForCardAt index: Int) -> [SwipeDirection]
    func cardStack(_ cardStack: MGCardStackView, shouldMakeCardFooterTransparentAt index: Int) -> Bool //shouldBringFooterToFrontAt
    func cardStack(_ cardStack: MGCardStackView, optionsForCardAt index: Int) -> MGSwipeCardOptions
    //random rotation direction
}

public extension MGCardStackViewDelegate {
    
    func didSwipeAllCards(_ cardStack: MGCardStackView) {}
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection) {}
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, touchPoint: CGPoint) {}
    func cardStack(_ cardStack: MGCardStackView, allowedSwipeDirectionsForCardAt index: Int) -> [SwipeDirection] { return [.left, .right] }
    func cardStack(_ cardStack: MGCardStackView, shouldMakeCardFooterTransparentAt index: Int) -> Bool { return false }
    func cardStack(_ cardStack: MGCardStackView, optionsForCardAt index: Int) -> MGSwipeCardOptions { return MGSwipeCardOptions.defaultOptions }
}
