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
    var swipeAnimationCalled: Bool = false
    var swipeAnimationDirection: SwipeDirection?
    var swipeAnimationForced: Bool?
    
    func swipe(direction: SwipeDirection, forced: Bool, completion: ((Bool) -> ())?) {
        swipeAnimationCalled = true
        swipeAnimationDirection = direction
        swipeAnimationForced = forced
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?(true)
        }
    }
    
    var reverseSwipeCalled: Bool = false
    var reverseSwipeFromDirection: SwipeDirection?
    
    func reverseSwipe(from direction: SwipeDirection, completion: ((Bool) -> ())?) {
        reverseSwipeCalled = true
        reverseSwipeFromDirection = direction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?(true)
        }
    }
    
    var resetAnimationCalled: Bool = false
    func reset(completion: ((Bool) -> ())?) {
        resetAnimationCalled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion?(true)
        }
    }
    
    var removeAllAnimationsCalled: Bool = false
    func removeAllAnimations() {
        removeAllAnimationsCalled = true
    }
}
