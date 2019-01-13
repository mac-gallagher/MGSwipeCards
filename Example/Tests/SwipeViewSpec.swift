//
//  MGSwipeCards_Tests.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/12/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble

@testable import MGSwipeCards

class SwipeViewSpec: QuickSpec {
    override func spec() {
        describe("initialization") {
            describe("when initializing a new swipe view") {
                var swipeView: SwipeView!
                
                beforeEach {
                    swipeView = self.setupSwipeView()
                }
                
                it("should have its swipe directions set to all directions") {
                    expect(swipeView.swipeDirections).to(equal(SwipeDirection.allDirections))
                }
                
                it("should have a minimum swipe speed of 1100") {
                    expect(swipeView.minimumSwipeSpeed).to(equal(1100))
                }
                
                it("should not have an active swipe direction") {
                    expect(swipeView.activeDirection).to(beNil())
                }
                
                it("should have a minimum swipe margin of 0.5") {
                    expect(swipeView.minimumSwipeMargin).to(equal(0.5))
                }
                
                it("should not have an initial touch location") {
                    expect(swipeView.touchLocation).to(beNil())
                }
                
                it("should have a tap gesture recognizer") {
                    expect(swipeView.tapGestureRecognizer).toNot(beNil())
                }
                
                it("should have a pan gesture recognizer") {
                    expect(swipeView.panGestureRecognizer).toNot(beNil())
                }
                
                it("should not have a delegate") {
                    expect(swipeView.swipeViewDelegate).to(beNil())
                }
            }
        }
        
        describe("gesture recognizers") {
            
        }
    }
}

extension SwipeViewSpec {
    func setupSwipeView() -> SwipeView {
        return SwipeView()
    }
}

extension SwipeViewSpec {
    class MockSwipeViewDelegate: SwipeViewDelegate {
        var didTapCalled: Bool = false
        func didTap(on view: SwipeView) {
            didTapCalled = true
        }
        
        var didBeginSwipeCalled: Bool = false
        func didBeginSwipe(on view: SwipeView) {
            didContinueSwipeCalled = true
        }
        
        var didContinueSwipeCalled: Bool = false
        func didContinueSwipe(on view: SwipeView) {
            didContinueSwipeCalled = true
        }
        
        var didSwipeCalled: Bool = false
        func didSwipe(on view: SwipeView, with direction: SwipeDirection) {
            didSwipeCalled = true
        }
        
        var didCancelSwipeCalled: Bool = false
        func didCancelSwipe(on view: SwipeView) {
            didCancelSwipeCalled = true
        }
    }
}
