//
//  MGSwipeCardDelegate.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/31/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import Foundation

public protocol MGSwipeCardDelegate {
    
    func didTap(on card: MGSwipeCard, recognizer: UITapGestureRecognizer)
    func beginSwiping(on card: MGSwipeCard)
    func continueSwiping(on card: MGSwipeCard)
    func didSwipe(on card: MGSwipeCard, with direction: SwipeDirection)
    func didCancelSwipe(on card: MGSwipeCard)
    
}
