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
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int)
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, recognizer: UITapGestureRecognizer)
    func cardStack(_ cardStack: MGCardStackView, swipeDirectionsForCardAt index: Int) -> [SwipeDirection]
    //    func shouldDisplayContentBehindFooter()
}

public extension MGCardStackViewDelegate {
    
    func didSwipeAllCards(_ cardStack: MGCardStackView) {}
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection) {}
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int) {}
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, recognizer: UITapGestureRecognizer) {}
    func cardStack(_ cardStack: MGCardStackView, swipeDirectionsForCardAt index: Int) -> [SwipeDirection] { return [.left, .right] }
}
