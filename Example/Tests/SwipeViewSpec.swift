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
        
        describe("tap gesture") {
            var swipeView: SwipeView!
            var mockSwipeViewDelegate: MockSwipeViewDelegate!
            var testTapGestureRecognizer: TestableTapGestureRecognizer!
            
            beforeEach {
                mockSwipeViewDelegate = MockSwipeViewDelegate()
                swipeView = self.setupSwipeView(configure: { swipeView in
                    swipeView.swipeViewDelegate = mockSwipeViewDelegate
                })
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
                
                it("should call the didTap delegate method") {
                    expect(mockSwipeViewDelegate.didTapCalled).to(beTrue())
                }
            }
        }
        
        describe("pan gesture") {
            var swipeView: SwipeView!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            var mockSwipeViewDelegate: MockSwipeViewDelegate!
            
            beforeEach {
                mockSwipeViewDelegate = MockSwipeViewDelegate()
                swipeView = self.setupSwipeView(configure: { swipeView in
                    swipeView.swipeViewDelegate = mockSwipeViewDelegate
                })
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
                
                it("it should call the didBeginSwipe delegate method") {
                    expect(mockSwipeViewDelegate.didBeginSwipeCalled).to(beTrue())
                }
            }
            
            describe("when pan gesture change is recognized") {
                beforeEach {
                    testPanGestureRecognizer.performPan(withLocation: nil, translation: nil, velocity: nil, state: .changed)
                }
                
                it("it should call the didContinueSwipe delegate method") {
                    expect(mockSwipeViewDelegate.didContinueSwipeCalled).to(beTrue())
                }
            }
        }
        
        describe("swipe recognition") {
            let minimumSwipeMargin: CGFloat = 0.3
            let minimumSwipeSpeed: CGFloat = 500
            let swipeDirections = SwipeDirection.allDirections
            var swipeView: SwipeView!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            var mockSwipeViewDelegate: MockSwipeViewDelegate!
            
            beforeEach {
                mockSwipeViewDelegate = MockSwipeViewDelegate()
                swipeView = self.setupSwipeView(configure: { swipeView in
                    swipeView.swipeViewDelegate = mockSwipeViewDelegate
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
                        expect(mockSwipeViewDelegate.didSwipeCalled).to(beFalse())
                    }
                    
                    it("should call the didCancelSwipe delegate method") {
                        expect(mockSwipeViewDelegate.didCancelSwipeCalled).to(beTrue())
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
                        expect(mockSwipeViewDelegate.didSwipeCalled).to(beTrue())
                        expect(mockSwipeViewDelegate.swipeDirection).to(equal(direction))
                    }
                    
                    it("should not call the didCancelSwipe delegate method") {
                        expect(mockSwipeViewDelegate.didCancelSwipeCalled).to(beFalse())
                    }
                }
                
                describe("when a pan gesture ended with a speed less than the minimum swipe speed") {
                    beforeEach {
                        let velocity: CGPoint = CGPoint(x: direction.point.x * (minimumSwipeSpeed - 1), y: direction.point.x * (minimumSwipeSpeed - 1))
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: direction.point, velocity: velocity, state: .ended)
                    }
                    
                    it("should not call the didSwipe delegate method") {
                        expect(mockSwipeViewDelegate.didSwipeCalled).to(beFalse())
                    }
                    
                    it("should call the didCancelSwipe delegate method") {
                        expect(mockSwipeViewDelegate.didCancelSwipeCalled).to(beTrue())
                    }
                }
                
                describe("when a pan gesture ended with a speed greater than or equal to the minimum swipe speed") {
                    beforeEach {
                        let velocity: CGPoint = CGPoint(x: direction.point.x * minimumSwipeSpeed, y: direction.point.y * minimumSwipeSpeed)
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: direction.point, velocity: velocity, state: .ended)
                    }
                    
                    it("should call the didSwipe delegate method with the correct direction") {
                        expect(mockSwipeViewDelegate.didSwipeCalled).to(beTrue())
                        expect(mockSwipeViewDelegate.swipeDirection).to(equal(direction))
                    }
                    
                    it("should not call the didCancelSwipe delegate method") {
                        expect(mockSwipeViewDelegate.didCancelSwipeCalled).to(beFalse())
                    }
                }
            }
        }
    }
}

extension SwipeViewSpec {
    func setupSwipeView(configure: (SwipeView) -> Void = { _ in } ) -> SwipeView {
        let swipeView = SwipeView()
        configure(swipeView)
        return swipeView
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
            didBeginSwipeCalled = true
        }
        
        var didContinueSwipeCalled: Bool = false
        func didContinueSwipe(on view: SwipeView) {
            didContinueSwipeCalled = true
        }
        
        var didSwipeCalled: Bool = false
        var swipeDirection: SwipeDirection?
        func didSwipe(on view: SwipeView, with direction: SwipeDirection) {
            didSwipeCalled = true
            swipeDirection = direction
        }
        
        var didCancelSwipeCalled: Bool = false
        func didCancelSwipe(on view: SwipeView) {
            didCancelSwipeCalled = true
        }
    }
}
