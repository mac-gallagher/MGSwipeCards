//
//  SwipeViewSpec.swift
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
        describe("SwipeView") {
            var subject: TestableSwipeView!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            var testTapGestureRecognizer: TestableTapGestureRecognizer!
            
            beforeEach {
                subject = TestableSwipeView()
                testPanGestureRecognizer = subject.panGestureRecognizer as? TestablePanGestureRecognizer
                testTapGestureRecognizer = subject.tapGestureRecognizer as? TestableTapGestureRecognizer
            }
            
            describe("initialization") {
                context("when initializing a new swipe view") {
                    var swipeView: SwipeView!
                    
                    beforeEach {
                        swipeView = SwipeView()
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
            
            //MARK: - Swipe Calculations
            
            describe("drag speed") {
                for direction in SwipeDirection.allDirections {
                    context("when swiping with a nonzero velocity in the specified direction") {
                        
                        beforeEach {
                            let velocity: CGPoint = direction.point
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: nil, velocity: velocity, state: nil)
                        }
                        
                        it("should return a positive drag speed") {
                            expect(subject.dragSpeed(on: direction)).to(beGreaterThan(0))
                        }
                    }
                }
            }
            
            describe("drag percentage") {
                for direction in SwipeDirection.allDirections {
                    context("when swiping halfway across the screen in the specified direction") {
                        
                        beforeEach {
                            let translationX: CGFloat = direction.point.x * (UIScreen.main.bounds.size.width / 2)
                            let translationY: CGFloat = direction.point.y * (UIScreen.main.bounds.size.height / 2)
                            let translation: CGPoint = CGPoint(x: translationX, y: translationY)
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                        }
                        
                        it("should return a percentage of 100% in the specified direction and 0% in all other directions") {
                            for swipeDirection in SwipeDirection.allDirections {
                                let expectedPercentage: CGFloat = swipeDirection == direction ? 1.0 : 0.0
                                expect(subject.dragPercentage(on: swipeDirection)).to(equal(expectedPercentage))
                            }
                        }
                    }
                    
                    context("when swiping the full length of the screen in the specified direction") {
                        
                        beforeEach {
                            let translationX = direction.point.x * UIScreen.main.bounds.size.width
                            let translationY = direction.point.y * UIScreen.main.bounds.size.height
                            let translation = CGPoint(x: translationX, y: translationY)
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                        }
                        
                        it("should return a percentage of 200% in the specified direction and 0% in all other directions") {
                            for swipeDirection in SwipeDirection.allDirections {
                                let expectedPercentage: CGFloat = swipeDirection == direction ? 2.0 : 0.0
                                expect(subject.dragPercentage(on: swipeDirection)).to(equal(expectedPercentage))
                            }
                        }
                    }
                }
            }
            
            describe("active direction") {
                let neighboringPairs: [(SwipeDirection, SwipeDirection)]
                    = [(.up, .right),
                       (.right, .down),
                       (.down, .left),
                       (.left, .up)]
                
                context("when the drag percentage is zero for all directions") {
                    let translation: CGPoint = .zero
                    
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                    }
                    
                    it("should not have an active direction") {
                        expect(subject.activeDirection).to(beNil())
                    }
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when the drag percentage is nonzero for exactly one direction") {
                        let translation: CGPoint = direction.point
                        
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                        }
                        
                        it("should set the active direction correspondingly") {
                            expect(subject.activeDirection).to(equal(direction))
                        }
                    }
                }
                
                for (direction1, direction2) in neighboringPairs {
                    context("when the drag percentage is nonzero for exactly two directions") {
                        let translationX = (2 * direction1.point.x + direction2.point.x) * (UIScreen.main.bounds.size.width / 2)
                        let translationY = (2 * direction1.point.y + direction2.point.y) * (UIScreen.main.bounds.size.height / 2)
                        let translation = CGPoint(x: translationX, y: translationY)
                        
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                        }
                        
                        it("should set the direction with the highest drag percentage as the active direction") {
                            expect(subject.activeDirection).to(equal(direction1))
                        }
                    }
                }
            }
            
            //MARK: - Delegates
            
            describe("tap gesture") {
                context("when a tap gesture is recognized") {
                    let touchPoint = CGPoint(x: 50, y: 50)
                    
                    beforeEach {
                        testTapGestureRecognizer.performTap(withLocation: touchPoint)
                    }
                    
                    it("should set the correct touch location") {
                        expect(subject.touchLocation).to(equal(touchPoint))
                    }
                    
                    it("should call the didTap method") {
                        expect(subject.didTapCalled).to(beTrue())
                    }
                }
            }
            
            describe("pan gesture") {
                let unsupportedStates: [UIPanGestureRecognizer.State] = [.cancelled, .failed, .possible, .recognized]
                
                context("when a pan gesture begin is recognized") {
                    let touchPoint: CGPoint = CGPoint(x: 50, y: 50)
                    
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: touchPoint, translation: nil, velocity: nil, state: .began)
                    }
                    
                    it("should set the correct touch location") {
                        expect(subject.touchLocation).to(equal(touchPoint))
                    }
                    
                    it("it should call the beginSwiping method") {
                        expect(subject.beginSwipingCalled).to(beTrue())
                    }
                }
                
                context("when a pan gesture change is recognized") {
                    
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: nil, velocity: nil, state: .changed)
                    }
                    
                    it("it should call the didContinueSwiping method") {
                        expect(subject.didContinueSwipingCalled).to(beTrue())
                    }
                }
                
                for state in unsupportedStates {
                    context("when an unsupported pan gesture state is recognized") {
                        
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: nil, velocity: nil, state: state)
                        }
                        
                        it("it should not call the didBeginSwipe method") {
                            expect(subject.didContinueSwipingCalled).to(beFalse())
                        }
                        
                        it("it should not call the didContinueSwiping method") {
                            expect(subject.didContinueSwipingCalled).to(beFalse())
                        }
                        
                        it("it should not call the didEndSwiping method") {
                            expect(subject.didContinueSwipingCalled).to(beFalse())
                        }
                    }
                }
            }
            
            describe("swipe recognition") {
                let minimumSwipeMargin: CGFloat = 0.3
                let minimumSwipeSpeed: CGFloat = 500
                
                beforeEach {
                    subject.minimumSwipeMargin = minimumSwipeMargin
                    subject.minimumSwipeSpeed = minimumSwipeSpeed
                }
                
                context("when a pan gesture ended with no active direction") {
                    
                    beforeEach {
                        testPanGestureRecognizer.performPan(withLocation: nil, translation: nil, velocity: nil, state: .ended)
                    }
                    
                    it("should call the didCancelSwipe delegate method") {
                        expect(subject.didCancelSwipeCalled).to(beTrue())
                    }
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when a pan gesture ended with a translation less than the minimum swipe margin") {
                        let translationX: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.width / 2) - 1
                        let translationY: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.height / 2) - 1
                        
                        beforeEach {
                            let translation: CGPoint = CGPoint(x: direction.point.x * translationX, y: direction.point.y * translationY)
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: .ended)
                        }
                        
                        it("should call the didCancelSwipe delegate method") {
                            expect(subject.didCancelSwipeCalled).to(beTrue())
                        }
                    }
                    
                    context("when a pan gesture ended with a translation greater than or equal to the minimum swipe margin") {
                        let translationX: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.width / 2)
                        let translationY: CGFloat = minimumSwipeMargin * (UIScreen.main.bounds.height / 2)
                        
                        beforeEach {
                            let translation: CGPoint = CGPoint(x: direction.point.x * translationX, y: direction.point.y * translationY)
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: .ended)
                        }
                        
                        it("should call the didSwipe delegate method with the correct direction") {
                            expect(subject.didSwipeCalled).to(beTrue())
                            expect(subject.didSwipeDirection).to(equal(direction))
                        }
                    }
                    
                    context("when a pan gesture ended with a speed less than the minimum swipe speed") {
                        let velocity: CGPoint = CGPoint(x: direction.point.x * (minimumSwipeSpeed - 1), y: direction.point.x * (minimumSwipeSpeed - 1))
                        
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: direction.point, velocity: velocity, state: .ended)
                        }
                        
                        it("should call the didCancelSwipe delegate method") {
                            expect(subject.didCancelSwipeCalled).to(beTrue())
                        }
                    }
                    
                    context("when a pan gesture ended with a speed greater than or equal to the minimum swipe speed") {
                        let velocity: CGPoint = CGPoint(x: direction.point.x * minimumSwipeSpeed, y: direction.point.y * minimumSwipeSpeed)
                        
                        beforeEach {
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: direction.point, velocity: velocity, state: .ended)
                        }
                        
                        it("should call the didSwipe delegate method with the correct direction") {
                            expect(subject.didSwipeCalled).to(beTrue())
                            expect(subject.didSwipeDirection).to(equal(direction))
                        }
                    }
                }
            }
        }
    }
}
