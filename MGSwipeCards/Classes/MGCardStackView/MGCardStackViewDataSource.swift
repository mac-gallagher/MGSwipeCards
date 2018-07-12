//
//  MGCardStackViewDataSource.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/31/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import Foundation

public protocol MGCardStackViewDataSource {
    
    func numberOfCards(in cardStack: MGCardStackView) -> Int
    func cardStack(_ cardStack: MGCardStackView, viewforCardAt index: Int) -> UIView?
    func cardStack(_ cardStack: MGCardStackView, viewForCardFooterAt index: Int) -> UIView?
    func cardStack(_ cardStack: MGCardStackView, heightForCardFooterAt index: Int) -> CGFloat
    func cardStack(_ cardStack: MGCardStackView, viewForCardOverlayAt index: Int, for direction: SwipeDirection) -> UIView?
}

public extension MGCardStackViewDataSource {
    
    func cardStack(_ cardStack: MGCardStackView, viewForCardFooterAt index: Int) -> UIView? { return nil }
    func cardStack(_ cardStack: MGCardStackView, heightForCardFooterAt index: Int) -> CGFloat { return 100 }
    func cardStack(_ cardStack: MGCardStackView, viewForCardOverlayAt index: Int, for direction: SwipeDirection) -> UIView? { return nil }
}
