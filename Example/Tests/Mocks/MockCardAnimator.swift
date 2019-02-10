//
//  MockCardAnimator.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 1/18/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble

@testable import MGSwipeCards

class MockCardAnimator: CardAnimator {
    var swipeCalled: Bool = false
    var swipeDirection: SwipeDirection?
    
    func swipe(_ card: SwipeCard, direction: SwipeDirection) {
        swipeCalled = true
        swipeDirection = direction
    }
    
    var reverseSwipeCalled: Bool = false
    
    func reverseSwipe(_ card: SwipeCard) {
        reverseSwipeCalled = true
    }
    
    var resetCalled: Bool = false
    
    func reset(_ card: SwipeCard) {
        resetCalled = true
    }
    
    var swipeAnimationCalled: Bool = false
    var swipeAnimationDirection: SwipeDirection?
    var swipeAnimationForced: Bool?
    
    func animateSwipe(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) {
        swipeAnimationCalled = true
        swipeAnimationDirection = direction
        swipeAnimationForced = forced
    }
    
    var reverseSwipeAnimationCalled: Bool = false
    var reverseSwipeAnimationDirection: SwipeDirection?
    
    func animateReverseSwipe(_ card: SwipeCard, from direction: SwipeDirection) {
        reverseSwipeAnimationCalled = true
        reverseSwipeAnimationDirection = direction
    }
    
    var resetAnimationCalled: Bool = false
    func animateReset(_ card: SwipeCard) {
        resetAnimationCalled = true
    }
    
    var removeAllAnimationsCalled: Bool = false
    func removeAllAnimations(on card: SwipeCard) {
        removeAllAnimationsCalled = true
    }
}
