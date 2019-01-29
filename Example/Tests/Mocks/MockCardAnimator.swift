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

class MockCardAnimator: CardAnimatable {
    
    var swipeCalled: Bool = false
    var swipeDirection: SwipeDirection?
    
    func swipe(_ card: MGSwipeCard, direction: SwipeDirection) {
        swipeCalled = true
        swipeDirection = direction
    }
    
    var reverseSwipeCalled: Bool = false
    
    func reverseSwipe(_ card: MGSwipeCard) {
        reverseSwipeCalled = true
    }
    
    var resetCalled: Bool = false
    
    func reset(_ card: MGSwipeCard) {
        resetCalled = true
    }
    
    var swipeAnimationCalled: Bool = false
    var swipeAnimationDirection: SwipeDirection?
    var swipeAnimationForced: Bool?
    
    func animateSwipe(_ card: MGSwipeCard, direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?) {
        swipeAnimationCalled = true
        swipeAnimationDirection = direction
        swipeAnimationForced = forced
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?(true)
        }
    }
    
    var reverseSwipeAnimationCalled: Bool = false
    var reverseSwipeAnimationDirection: SwipeDirection?
    
    func animateReverseSwipe(_ card: MGSwipeCard, from direction: SwipeDirection, completion: ((Bool) -> ())?) {
        reverseSwipeAnimationCalled = true
        reverseSwipeAnimationDirection = direction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?(true)
        }
    }
    
    var resetAnimationCalled: Bool = false
    func animateReset(_ card: MGSwipeCard, completion: ((Bool) -> ())?) {
        resetAnimationCalled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?(true)
        }
    }
    
    var removeAllAnimationsCalled: Bool = false
    func removeAllAnimations(on card: MGSwipeCard) {
        removeAllAnimationsCalled = true
    }
}
