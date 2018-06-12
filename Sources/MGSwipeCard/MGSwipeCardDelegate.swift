//
//  MGSwipeCardDelegate.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/31/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

public protocol MGSwipeCardDelegate {
    
    func beginSwiping(on card: MGSwipeCard)
    
    func continueSwiping(on card: MGSwipeCard)
    
    func didSwipe(on card: MGSwipeCard, withDirection direction: SwipeDirection)
    
    func didCancelSwipe(on card: MGSwipeCard)
    
}
