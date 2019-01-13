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
            }
        }
        
        describe("tap gesture") {
            var swipeView: MockSwipeView!
            var testTapGestureRecognizer: TestableTapGestureRecognizer!
            
            beforeEach {
                swipeView = self.setupSwipeView()
                testTapGestureRecognizer = swipeView.tapGestureRecognizer as? TestableTapGestureRecognizer
            }
            
            describe("when a tap gesture is recognized") {
                let touchPoint = CGPoint(x: 50, y: 50)
                
                beforeEach {
                    testTapGestureRecognizer.performTap(withLocation: touchPoint)
                }
                
                it("should set the correct touch location") {
                    expect(swipeView.touchLocation).to(equal(touchPoint))
                }
                
                it("should call the didTap method") {
                    expect(swipeView.didTapCalled).to(beTrue())
                }
            }
        }
        
        describe("pan gesture") {
            var swipeView: MockSwipeView!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            
            beforeEach {
                swipeView = self.setupSwipeView()
                testPanGestureRecognizer = swipeView.panGestureRecognizer as? TestablePanGestureRecognizer
            }
            
            describe("when pan gesture begin is recognized") {
                let touchPoint = CGPoint(x: 50, y: 50)
                
                beforeEach {
                    testPanGestureRecognizer.performPan(withLocation: touchPoint, translation: nil, velocity: nil, state: .began)
                }
                
                it("should set the correct touch location") {
                    expect(swipeView.touchLocation).to(equal(touchPoint))
                }
                
                it("it should call the beginSwiping method") {
                    expect(swipeView.beginSwipingCalled).to(beTrue())
                }
            }
            
            describe("when pan gesture change is recognized") {
                beforeEach {
                    testPanGestureRecognizer.performPan(withLocation: nil, translation: nil, velocity: nil, state: .changed)
                }
                
                it("it should call the didContinueSwiping method") {
                    expect(swipeView.didContinueSwipingCalled).to(beTrue())
                }
            }
        }
        
        describe("swipe recognition") {
            let minimumSwipeMargin: CGFloat = 0.3
            let minimumSwipeSpeed: CGFloat = 500
            let swipeDirections = SwipeDirection.allDirections
            var swipeView: MockSwipeView!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            
            beforeEach {
                swipeView = self.setupSwipeView(configure: { swipeView in
                    swipeView.minimumSwipeMargin = minimumSwipeMargin
                    swipeView.minimumSwipeSpeed = minimumSwipeSpeed
                    swipeView.swipeDirections = swipeDirections
                })
                testPanGestureRecognizer = swipeView.panGestureRecognizer as? TestablePanGestureRecognizer
            }
            
            for direction in swipeDirections {
                describe("when a pan gesture ended with a translation less than the minimum swipe margin") {
                    let translationX: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.width / 2) - 1
                    let translationY: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.height / 2) - 1
                    
                    beforeEach {
                        let translation: CGPoint = CGPoint(x: direction.point.x * translationX, y: direction.point.y * translationY)
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: .ended)
                    }
                    
                    it("should not call the didSwipe delegate method") {
                        expect(swipeView.didSwipeCalled).to(beFalse())
                    }
                    
                    it("should call the didCancelSwipe delegate method") {
                        expect(swipeView.didCancelSwipeCalled).to(beTrue())
                    }
                }
                
                describe("when a pan gesture ended with a translation greater than or equal to the minimum swipe margin") {
                    let translationX: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.width / 2)
                    let translationY: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.height / 2)
                    
                    beforeEach {
                        let translation: CGPoint = CGPoint(x: direction.point.x * translationX, y: direction.point.y * translationY)
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: .ended)
                    }
                    
                    it("should call the didSwipe delegate method with the correct direction") {
                        expect(swipeView.didSwipeCalled).to(beTrue())
                        expect(swipeView.swipeDirection).to(equal(direction))
                    }
                    
                    it("should not call the didCancelSwipe delegate method") {
                        expect(swipeView.didCancelSwipeCalled).to(beFalse())
                    }
                }
                
                describe("when a pan gesture ended with a speed less than the minimum swipe speed") {
                    beforeEach {
                        let velocity: CGPoint = CGPoint(x: direction.point.x * (minimumSwipeSpeed - 1), y: direction.point.x * (minimumSwipeSpeed - 1))
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: direction.point, velocity: velocity, state: .ended)
                    }
                    
                    it("should not call the didSwipe delegate method") {
                        expect(swipeView.didSwipeCalled).to(beFalse())
                    }
                    
                    it("should call the didCancelSwipe delegate method") {
                        expect(swipeView.didCancelSwipeCalled).to(beTrue())
                    }
                }
                
                describe("when a pan gesture ended with a speed greater than or equal to the minimum swipe speed") {
                    beforeEach {
                        let velocity: CGPoint = CGPoint(x: direction.point.x * minimumSwipeSpeed, y: direction.point.y * minimumSwipeSpeed)
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: direction.point, velocity: velocity, state: .ended)
                    }
                    
                    it("should call the didSwipe delegate method with the correct direction") {
                        expect(swipeView.didSwipeCalled).to(beTrue())
                        expect(swipeView.swipeDirection).to(equal(direction))
                    }
                    
                    it("should not call the didCancelSwipe delegate method") {
                        expect(swipeView.didCancelSwipeCalled).to(beFalse())
                    }
                }
            }
        }
    }
}

extension SwipeViewSpec {
    func setupSwipeView(configure: (MockSwipeView) -> Void = { _ in } ) -> MockSwipeView {
        let swipeView = MockSwipeView()
        configure(swipeView)
        return swipeView
    }
}

extension SwipeViewSpec {
    class MockSwipeView: SwipeView {
        var didTapCalled: Bool = false
        override func didTap(recognizer: UITapGestureRecognizer) {
            super.didTap(recognizer: recognizer)
            didTapCalled = true
        }
        
        var beginSwipingCalled: Bool = false
        override func beginSwiping(recognizer: UIPanGestureRecognizer) {
            super.beginSwiping(recognizer: recognizer)
            beginSwipingCalled = true
        }
        
        var didContinueSwipingCalled: Bool = false
        override func continueSwiping(recognizer: UIPanGestureRecognizer) {
            super.continueSwiping(recognizer: recognizer)
            didContinueSwipingCalled = true
        }
        
        var didSwipeCalled: Bool = false
        var swipeDirection: SwipeDirection?
        override func didSwipe(recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {
            super.didSwipe(recognizer: recognizer, with: direction)
            didSwipeCalled = true
            swipeDirection = direction
        }
        
        var didCancelSwipeCalled: Bool = false
        override func didCancelSwipe(recognizer: UIPanGestureRecognizer) {
            super.didCancelSwipe(recognizer: recognizer)
            didCancelSwipeCalled = true
        }
    }
}
