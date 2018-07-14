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
    func cardStack(_ cardStack: MGCardStackView, cardForIndexAt index: Int) -> MGSwipeCard
//    func cardStack(_ cardStack: MGCardStackView, offsetForIndexAt index: Int) -> CGSize
//    func cardStack(_ cardStack: MGCardStackView, scaleFactorForIndexAt index: Int) -> CGFloat
}
