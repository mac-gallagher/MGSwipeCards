//
//  MockSwipeCardDelegate.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 1/18/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import MGSwipeCards
import Quick
import Nimble

class MockSwipeCardDelegate: SwipeCardDelegate {
    var didTapCalled: Bool = false
    func card(didTap card: SwipeCard) {
        didTapCalled = true
    }
    
    var didBeginSwipeCalled: Bool = false
    func card(didBeginSwipe card: SwipeCard) {
        didBeginSwipeCalled = true
    }
    
    var didContinueSwipeCalled: Bool = false
    func card(didContinueSwipe card: SwipeCard) {
        didContinueSwipeCalled = true
    }
    
    var didSwipeCalled: Bool = false
    var didSwipeForced: Bool?
    var didSwipeDirection: SwipeDirection?
    
    func card(didSwipe card: SwipeCard, with direction: SwipeDirection, forced: Bool) {
        didSwipeCalled = true
        didSwipeForced = forced
        didSwipeDirection = direction
    }
    
    var didReverseSwipeCalled: Bool = false
    var didReverseSwipeDirection: SwipeDirection?
    
    func card(didReverseSwipe card: SwipeCard, from direction: SwipeDirection) {
        didReverseSwipeCalled = true
        didReverseSwipeDirection = direction
    }
    
    var didCancelSwipeCalled: Bool = false
    func card(didCancelSwipe card: SwipeCard) {
        didCancelSwipeCalled = true
    }
}
