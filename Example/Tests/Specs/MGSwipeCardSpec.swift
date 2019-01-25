//
//  MGSwipeCardSpec.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/13/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble

@testable import MGSwipeCards

class MGSwipeCardSpec: QuickSpec {
    let swipeCardWidth: CGFloat = 100
    let swipeCardHeight: CGFloat = 200
    
    override func spec() {
        describe("MGSwipeCard") {
            describe("initialization") {
                context("when initializing a card") {
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard()
                    }
                    
                    it("should have the default animation options") {
                        expect(swipeCard.animationOptions).to(be(CardAnimationOptions.defaultOptions))
                    }
                    
                    it("should not have any overlays") {
                        expect(swipeCard.leftOverlay).to(beNil())
                        expect(swipeCard.upOverlay).to(beNil())
                        expect(swipeCard.rightOverlay).to(beNil())
                        expect(swipeCard.downOverlay).to(beNil())
                    }
                    
                    it("should not have a footer") {
                        expect(swipeCard.footer).to(beNil())
                    }
                    
                    it("should have a footer height of 100") {
                        expect(swipeCard.footerHeight).to(equal(100))
                    }
                    
                    it("should have its footer set to opaque") {
                        expect(swipeCard.isFooterTransparent).to(beFalse())
                    }
                    
                    it("should have user interaction enabled") {
                        expect(swipeCard.isUserInteractionEnabled).to(beTrue())
                    }
                    
                    it("should not have any content") {
                        expect(swipeCard.content).to(beNil())
                    }
                    
                    it("should not have a delegate") {
                        expect(swipeCard.delegate).to(beNil())
                    }
                    
                    it("should have no rotation direction set") {
                        expect(swipeCard.rotationDirectionY).to(equal(0))
                    }
                    
                    it("should have an overlay container") {
                        expect(swipeCard.overlayContainer).toNot(beNil())
                    }
                    
                    it("should layout its overlay container to cover the card's bounds") {
                        expect(swipeCard.overlayContainer.frame).to(equal(swipeCard.bounds))
                    }
                }
            }
            
            describe("content + footer layout") {
                context("when adding a footer to a card") {
                    let footerHeight: CGFloat = 80
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard(configure: { card in
                            card.footer = UIView()
                            card.footerHeight = footerHeight
                        })
                    }
                    
                    it("should layout the footer with the correct frame") {
                        let expectedY = self.swipeCardHeight - footerHeight
                        let expectedFrame = CGRect(x: 0, y: expectedY, width: self.swipeCardWidth, height: footerHeight)
                        expect(swipeCard.footer?.frame).to(equal(expectedFrame))
                    }
                }
                
                context("when adding content to a card with no footer") {
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard(configure: { card in
                            card.content = UIView()
                        })
                    }
                    
                    it("should layout the content to cover the card's bounds") {
                        expect(swipeCard.content?.frame).to(equal(swipeCard.bounds))
                    }
                }
                
                context("when adding content to a card with an opaque footer") {
                    let footerHeight: CGFloat = 80
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard(configure: { card in
                            card.content = UIView()
                            card.footer = UIView()
                            card.footerHeight = footerHeight
                        })
                    }
                    
                    it("should layout the content above the card's footer") {
                        let expectedFrame = CGRect(x: 0, y: 0, width: self.swipeCardWidth, height: self.swipeCardHeight - footerHeight)
                        expect(swipeCard.content?.frame).to(equal(expectedFrame))
                    }
                }
                
                context("when adding content to a card with a transparent footer") {
                    let footer = UIView()
                    let footerHeight: CGFloat = 80
                    let content = UIView()
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard(configure: { card in
                            card.content = content
                            card.footerHeight = footerHeight
                            card.footer = footer
                            card.isFooterTransparent = true
                        })
                    }
                    
                    it("should layout its footer above its content in the view hierarchy") {
                        let footerIndex = swipeCard.subviews.firstIndex(of: footer)
                        let contentIndex = swipeCard.subviews.firstIndex(of: content)
                        expect(contentIndex).to(beLessThan(footerIndex))
                    }
                    
                    it("should layout the content to cover the card's bounds") {
                        expect(swipeCard.content?.frame).to(equal(swipeCard.bounds))
                    }
                }
            }
            
            describe("overlay layout") {
                for direction in SwipeDirection.allDirections {
                    context("when adding an overlay") {
                        let overlay = UIView()
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.setOverlay(overlay, forDirection: direction)
                            })
                        }
                        
                        it("should add the overlay to the overlay container's view hierarchy") {
                            expect(overlay.superview).to(equal(swipeCard.overlayContainer))
                        }
                        
                        it("should set the overlay's alpha value equal to zero") {
                            expect(overlay.alpha).to(equal(0))
                        }
                    }
                    
                    context("when replacing a card's existing overlay") {
                        let oldOverlay = UIView()
                        
                        beforeEach {
                            _ = self.setupSwipeCard(configure: { card in
                                card.setOverlay(oldOverlay, forDirection: direction)
                                card.setOverlay(UIView(), forDirection: direction)
                            })
                        }
                        
                        it("should remove the old overlay from its superview") {
                            expect(oldOverlay.superview).to(beNil())
                        }
                    }
                    
                    context("when adding an overlay to a card with no footer") {
                        let overlay = UIView()
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.setOverlay(overlay, forDirection: direction)
                            })
                        }
                        
                        it("should layout its overlay to cover the card's bounds") {
                            expect(overlay.frame).to(equal(swipeCard.bounds))
                        }
                    }
                    
                    context("when adding an overlay to a card with an opaque footer") {
                        let overlay = UIView()
                        let footerHeight: CGFloat = 80
                        
                        beforeEach {
                            _ = self.setupSwipeCard(configure: { card in
                                card.setOverlay(overlay, forDirection: direction)
                                card.footerHeight = footerHeight
                                card.footer = UIView()
                            })
                        }
                        
                        it("should layout the overlay above the card's footer") {
                            let expectedFrame = CGRect(x: 0, y: 0, width: self.swipeCardWidth, height: self.swipeCardHeight - footerHeight)
                            expect(overlay.frame).to(equal(expectedFrame))
                        }
                    }
                    
                    context("when adding an overlay to a card with a transparent footer") {
                        let overlay = UIView()
                        let footer = UIView()
                        let footerHeight: CGFloat = 80
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.setOverlay(overlay, forDirection: direction)
                                card.footer = footer
                                card.footerHeight = footerHeight
                                card.isFooterTransparent = true
                            })
                        }
                        
                        it("should layout its overlay container above its footer in the view hierarchy") {
                            let footerIndex = swipeCard.subviews.firstIndex(of: footer)
                            let overlayContainerIndex = swipeCard.subviews.firstIndex(of: swipeCard.overlayContainer)
                            expect(overlayContainerIndex).to(beGreaterThan(footerIndex))
                        }
                        
                        it("should layout the overlay above the card's footer") {
                            let expectedFrame = CGRect(x: 0, y: 0, width: self.swipeCardWidth, height: self.swipeCardHeight - footerHeight)
                            expect(overlay.frame).to(equal(expectedFrame))
                        }
                    }
                }
            }
            
            describe("drag rotation") {
                for direction in [SwipeDirection.up, SwipeDirection.down] {
                    context("when the card is dragged vertically") {
                        var swipeCard: TestableSwipeCard!
                        var testPanGestureRecognizer: TestablePanGestureRecognizer!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.testRotationDirection = 0
                            })
                            
                            testPanGestureRecognizer = swipeCard.panGestureRecognizer as? TestablePanGestureRecognizer
                            let translation: CGPoint = CGPoint(x: 0, y: direction.point.y * UIScreen.main.bounds.height)
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                        }
                        
                        it("should have rotation angle equal to zero") {
                            let actualRotationAngle = swipeCard.dragRotationAngle(recognizer: testPanGestureRecognizer)
                            expect(actualRotationAngle).to(equal(0))
                        }
                    }
                }
                
                for direction in [SwipeDirection.left, SwipeDirection.right] {
                    for rotationDirection in [CGFloat(-1), CGFloat(1)] {
                        context("when the card is dragged horizontally") {
                            let maximumRotationAngle: CGFloat = CGFloat.pi / 4
                            var testPanGestureRecognizer: TestablePanGestureRecognizer!
                            var swipeCard: TestableSwipeCard!
                            
                            beforeEach {
                                swipeCard = self.setupSwipeCard(configure: { card in
                                    card.testRotationDirection = rotationDirection
                                    
                                    let options = CardAnimationOptions()
                                    options.maximumRotationAngle = maximumRotationAngle
                                    card.animationOptions = options
                                })
                                
                                testPanGestureRecognizer = swipeCard.panGestureRecognizer as? TestablePanGestureRecognizer
                            }
                            
                            context("less than the screen's width") {
                                beforeEach {
                                    let translation: CGPoint = CGPoint(x: direction.point.x * (UIScreen.main.bounds.width - 1), y: 0)
                                    testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                                }
                                
                                it("should return a rotation angle less than the maximum rotation angle") {
                                    let actualRotationAngle = swipeCard.dragRotationAngle(recognizer: testPanGestureRecognizer)
                                    expect(abs(actualRotationAngle)).to(beLessThan(maximumRotationAngle))
                                }
                            }
                            
                            context("at least the length of the screen's width") {
                                beforeEach {
                                    let translation: CGPoint = CGPoint(x: direction.point.x * UIScreen.main.bounds.width, y: 0)
                                    testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                                }
                                
                                it("should return a rotation angle equal to the maximum rotation angle") {
                                    let actualRotationAngle = swipeCard.dragRotationAngle(recognizer: testPanGestureRecognizer)
                                    expect(abs(actualRotationAngle)).to(equal(maximumRotationAngle))
                                }
                            }
                        }
                    }
                }
            }
            
            
            describe("drag transform") {
                let rotationAngle: CGFloat = CGFloat.pi / 4
                let translation: CGPoint = CGPoint(x: 100, y: 100)
                var testPanGestureRecognizer: TestablePanGestureRecognizer!
                var swipeCard: TestableSwipeCard!
                
                beforeEach {
                    swipeCard = self.setupSwipeCard(configure: { card in
                        card.testDragRotation = rotationAngle
                    })
                    testPanGestureRecognizer = swipeCard.panGestureRecognizer as? TestablePanGestureRecognizer
                    testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                }
                
                context("when the card is dragged") {
                    it("should return the transform with the proper rotation and translation") {
                        let expectedTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
                            .concatenating(CGAffineTransform(rotationAngle: rotationAngle))
                        expect(swipeCard.dragTransform(recognizer: testPanGestureRecognizer)).to(equal(expectedTransform))
                    }
                }
            }
            
            describe("overlay percentage") {
                for direction in SwipeDirection.allDirections {
                    context("when the card is dragged in exactly one direction") {
                        var swipeCard: TestableSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard()
                            swipeCard.testDragPercentage[direction] = 0.1
                        }
                        
                        it("should return a nonzero overlay percentage in the dragged direction and 0% for all other directions") {
                            for swipeDirection in SwipeDirection.allDirections {
                                if swipeDirection == direction {
                                    expect(swipeCard.overlayPercentage(forDirection: swipeDirection)).toNot(equal(0))
                                } else {
                                    expect(swipeCard.overlayPercentage(forDirection: swipeDirection)).to(equal(0))
                                }
                            }
                        }
                    }
                    
                    context("when the card is dragged in the indicated direction below its minimum swipe margin") {
                        let minimumSwipeMargin: CGFloat = 0.7
                        var swipeCard: TestableSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.minimumSwipeMargin = minimumSwipeMargin
                            })
                            swipeCard.testDragPercentage[direction] = minimumSwipeMargin - 0.1
                        }
                        
                        it("should have an overlay percentage less than 1 in the indicated direction") {
                            let expectedPercentage = swipeCard.overlayPercentage(forDirection: direction)
                            expect(expectedPercentage).to(beLessThan(1))
                        }
                    }
                    
                    context("when the card is dragged in the indicated direction at least its minimum swipe margin") {
                        let minimumSwipeMargin: CGFloat = 0.7
                        var swipeCard: TestableSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.minimumSwipeMargin = minimumSwipeMargin
                            })
                            swipeCard.testDragPercentage[direction] = minimumSwipeMargin
                        }
                        
                        it("should have an overlay percentage equal to 1 in the indicated direction") {
                            let expectedPercentage = swipeCard.overlayPercentage(forDirection: direction)
                            expect(expectedPercentage).to(equal(1))
                        }
                    }
                }
                
                context("when the card is dragged in more than one direction") {
                    let neighboringPairs: [(SwipeDirection, SwipeDirection)]
                        = [(.up, .right),
                           (.right, .down),
                           (.down, .left),
                           (.left, .up)]
                    var swipeCard: TestableSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard()
                    }
                    
                    for (direction1, direction2) in neighboringPairs {
                        context("and the drag percentage of the two directions is equal") {
                            beforeEach {
                                swipeCard.testDragPercentage[direction1] = 0.1
                                swipeCard.testDragPercentage[direction2] = 0.1
                            }
                            
                            it("should return an overlay percentage of 0% for both directions") {
                                expect(swipeCard.overlayPercentage(forDirection: direction1)).to(equal(0))
                                expect(swipeCard.overlayPercentage(forDirection: direction2)).to(equal(0))
                            }
                        }
                        
                        context("and the drag percentage of the two directions is not equal") {
                            beforeEach {
                                swipeCard.testDragPercentage[direction1] = 0.2
                                swipeCard.testDragPercentage[direction2] = 0.1
                            }
                            
                            it("should return an overlay percentage of 0% for one direction and a nonzero overlay percentage for the other") {
                                let direction1Percentage = swipeCard.overlayPercentage(forDirection: direction1)
                                let direction2Percentage = swipeCard.overlayPercentage(forDirection: direction2)
                                expect(direction1Percentage).toNot(equal(0))
                                expect(direction2Percentage).to(equal(0))
                            }
                        }
                    }
                }
            }
            
            describe("tap gesture") {
                context("when the parent view's didTap method is called") {
                    var mockSwipeCardDelegate: MockSwipeCardDelegate!
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        mockSwipeCardDelegate = MockSwipeCardDelegate()
                        swipeCard = self.setupSwipeCard(configure: { card in
                            card.delegate = mockSwipeCardDelegate
                        })
                        swipeCard.didTap(recognizer: UITapGestureRecognizer())
                    }
                    
                    it("should call the didTap delegate method") {
                        expect(mockSwipeCardDelegate.didTapCalled).to(beTrue())
                    }
                }
            }
            
            describe("physical swipe begin") {
                context("when parent view's beginSwiping method is called") {
                    var animator: MockCardAnimator!
                    var mockSwipeCardDelegate: MockSwipeCardDelegate!
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        animator = MockCardAnimator()
                        mockSwipeCardDelegate = MockSwipeCardDelegate()
                        swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                            card.delegate = mockSwipeCardDelegate
                        })
                        swipeCard.beginSwiping(recognizer: UIPanGestureRecognizer())
                    }
                    
                    it("should call the didBeginSwipe delegate method") {
                        expect(mockSwipeCardDelegate.didBeginSwipeCalled).to(beTrue())
                    }
                    
                    it("should remove all animations on the card") {
                        expect(animator.removeAllAnimationsCalled).to(beTrue())
                    }
                }
                
                context("when the physical swipe begins") {
                    let cardCenterX: CGFloat = swipeCardWidth / 2
                    let cardCenterY: CGFloat = swipeCardHeight / 2
                    var swipeCard: TestableSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard()
                    }
                    
                    context("and the touch point is in the first quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                        }
                        
                        it("should have rotation direction equal to -1") {
                            expect(swipeCard.rotationDirectionY).to(equal(-1))
                        }
                    }
                    
                    context("and the touch point is in the second quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                        }
                        
                        it("should have rotation direction equal to -1") {
                            expect(swipeCard.rotationDirectionY).to(equal(-1))
                        }
                    }
                    
                    context("and the touch point is in the third quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                        }
                        
                        it("should have rotation direction equal to 1") {
                            expect(swipeCard.rotationDirectionY).to(equal(1))
                        }
                    }
                    
                    context("and the touch point is in the fourth quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                        }
                        
                        it("should have rotation direction equal to 1") {
                            expect(swipeCard.rotationDirectionY).to(equal(1))
                        }
                    }
                }
            }
            
            describe("physical swipe change") { //DONE
                for direction in SwipeDirection.allDirections {
                    context("when the parent view's continueSwiping method is called") {
                        let testOverlayPercentage: CGFloat = 0.5
                        let testTransform: CGAffineTransform = {
                            let rotation = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                            let translation = CGAffineTransform(translationX: 100, y: 100)
                            return rotation.concatenating(translation)
                        }()
                        let overlay: UIView = UIView()
                        var mockSwipeCardDelegate: MockSwipeCardDelegate!
                        var swipeCard: TestableSwipeCard!
                        
                        beforeEach {
                            mockSwipeCardDelegate = MockSwipeCardDelegate()
                            swipeCard = self.setupSwipeCard(configure: { card in
                                card.delegate = mockSwipeCardDelegate
                                card.setOverlay(overlay, forDirection: direction)
                                card.testOverlayPercentage[direction] = testOverlayPercentage
                                card.testDragTransform = testTransform
                            })
                            swipeCard.continueSwiping(recognizer: UIPanGestureRecognizer())
                        }
                        
                        it("should apply the proper overlay alpha values") {
                            expect(overlay.alpha).to(equal(testOverlayPercentage))
                        }
                        
                        it("should apply the proper transformation to the card") {
                            expect(swipeCard.transform).to(equal(testTransform))
                        }
                        
                        it("should call the didContinueSwipe delegate method") {
                            expect(mockSwipeCardDelegate.didContinueSwipeCalled).to(beTrue())
                        }
                    }
                }
            }
            
            describe("physical swipe end") {
                context("when the parent view's didCancelSwipe method is called") {
                    var animator: MockCardAnimator!
                    var mockSwipeCardDelegate: MockSwipeCardDelegate!
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        animator = MockCardAnimator()
                        mockSwipeCardDelegate = MockSwipeCardDelegate()
                        swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                            card.delegate = mockSwipeCardDelegate
                        })
                        swipeCard.didCancelSwipe(recognizer: UIPanGestureRecognizer())
                    }
                    
                    it("should animate the card back to its original position") {
                        expect(animator.resetAnimationCalled).to(beTrue())
                    }
                    
                    it("should call the didCancelSwipe delegate method after the card's reset animation is completed") {
                        expect(mockSwipeCardDelegate.didCancelSwipeCalled).toEventually(beTrue(), timeout: 20)
                    }
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when the parent view's didSwipe method is called") {
                        var animator: MockCardAnimator!
                        var mockSwipeCardDelegate: MockSwipeCardDelegate!
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            animator = MockCardAnimator()
                            mockSwipeCardDelegate = MockSwipeCardDelegate()
                            swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                                card.delegate = mockSwipeCardDelegate
                            })
                            swipeCard.didSwipe(recognizer: UIPanGestureRecognizer(), with: direction)
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(swipeCard.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should trigger a swipe animation with the correct parameters") {
                            expect(animator.swipeAnimationCalled).to(beTrue())
                            expect(animator.swipeAnimationDirection).to(equal(direction))
                            expect(animator.swipeAnimationForced).to(beFalse())
                        }
                        
                        it("should call the didSwipe delegate method with the correct parameters once the animation has completed") {
                            let timeout: TimeInterval = swipeCard.animationOptions.cardSwipeAnimationDuration + 20
                            expect(mockSwipeCardDelegate.didSwipeCalled).toEventually(beTrue(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didSwipeForced).toEventually(beFalse(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didSwipeDirection).toEventually(equal(direction), timeout: timeout)
                        }
                    }
                }
            }
            
            describe("programmatic swipe") {
                for direction in SwipeDirection.allDirections {
                    context("when the swipe method is called") {
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            swipeCard = self.setupSwipeCard()
                            swipeCard.swipe(direction: direction, animated: false)
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(swipeCard.isUserInteractionEnabled).to(beFalse())
                        }
                    }
                    
                    context("when the swipe method is called with no animation") {
                        var mockSwipeCardDelegate: MockSwipeCardDelegate!
                        var animator: MockCardAnimator!
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            mockSwipeCardDelegate = MockSwipeCardDelegate()
                            animator = MockCardAnimator()
                            swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                                card.delegate = mockSwipeCardDelegate
                            })
                            swipeCard.swipe(direction: direction, animated: false)
                        }
                        
                        it("should not trigger a swipe animation") {
                            expect(animator.swipeAnimationCalled).to(beFalse())
                        }
                        
                        it("should immediately call the didSwipe delegate method with the correct parameters") {
                            expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didSwipeForced).to(beTrue())
                            expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
                        }
                    }
                    
                    context("when the swipe method is called with an animation") {
                        var animator: MockCardAnimator!
                        var mockSwipeCardDelegate: MockSwipeCardDelegate!
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            animator = MockCardAnimator()
                            mockSwipeCardDelegate = MockSwipeCardDelegate()
                            swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                                card.delegate = mockSwipeCardDelegate
                            })
                            swipeCard.swipe(direction: direction, animated: true)
                        }
                        
                        it("should trigger a swipe animation with the correct parameters") {
                            expect(animator.swipeAnimationCalled).to(beTrue())
                            expect(animator.swipeAnimationDirection).to(equal(direction))
                            expect(animator.swipeAnimationForced).to(beTrue())
                        }
                        
                        it("should call the didSwipe delegate method with the correct parameters once the animation has completed") {
                            let timeout: TimeInterval = swipeCard.animationOptions.cardSwipeAnimationDuration + 10
                            expect(mockSwipeCardDelegate.didSwipeCalled).toEventually(beTrue(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didSwipeForced).toEventually(beTrue(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didSwipeDirection).toEventually(equal(direction), timeout: timeout)
                        }
                    }
                }
            }
            
            describe("reverse swipe") {
                for direction in SwipeDirection.allDirections {
                    context("when the reverse swipe method is called with no animation") {
                        var animator: MockCardAnimator!
                        var mockSwipeCardDelegate: MockSwipeCardDelegate!
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            animator = MockCardAnimator()
                            mockSwipeCardDelegate = MockSwipeCardDelegate()
                            swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                                card.delegate = mockSwipeCardDelegate
                            })
                            swipeCard.reverseSwipe(from: direction, animated: false)
                        }
                        
                        it("should not trigger a reverse swipe animation") {
                            expect(animator.reverseSwipeCalled).to(beFalse())
                        }
                        
                        it("should immediately call the didReverseSwipe delegate with the correct direction") {
                            expect(mockSwipeCardDelegate.didReverseSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didReverseSwipeDirection).to(equal(direction))
                        }
                        
                        it("should enable user interaction on the card") {
                            expect(swipeCard.isUserInteractionEnabled).to(beTrue())
                        }
                    }
                    
                    context("when the reverse swipe method is called with an animation") {
                        var animator: MockCardAnimator!
                        var mockSwipeCardDelegate: MockSwipeCardDelegate!
                        var swipeCard: MGSwipeCard!
                        
                        beforeEach {
                            animator = MockCardAnimator()
                            mockSwipeCardDelegate = MockSwipeCardDelegate()
                            swipeCard = self.setupSwipeCard(withAnimator: animator, configure: { card in
                                card.delegate = mockSwipeCardDelegate
                            })
                            swipeCard.reverseSwipe(from: direction, animated: true)
                        }
                        
                        it("should immediately disable user interaction on the card") {
                            expect(swipeCard.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should trigger a reverse swipe animation from the correct direction") {
                            expect(animator.reverseSwipeCalled).to(beTrue())
                            expect(animator.reverseSwipeFromDirection).to(equal(direction))
                        }
                        
                        it("should call the didSwipe delegate method with the correct parameters once the animation has completed") {
                            let timeout: TimeInterval = swipeCard.animationOptions.reverseSwipeAnimationDuration + 20
                            expect(mockSwipeCardDelegate.didReverseSwipeCalled).toEventually(beTrue(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didReverseSwipeDirection).toEventually(equal(direction), timeout: timeout)
                        }
                        
                        it("should enable user interaction on the card once the animation has completed") {
                            let timeout: TimeInterval = swipeCard.animationOptions.reverseSwipeAnimationDuration + 20
                            expect(swipeCard.isUserInteractionEnabled).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Setup

extension MGSwipeCardSpec {
    func setupSwipeCard(withAnimator animator: CardAnimatable? = nil,
                        configure: (TestableSwipeCard) -> Void = { _ in } ) -> TestableSwipeCard {
        let parentView = UIView()
        let swipeCard: TestableSwipeCard
        if let animator = animator {
            swipeCard = TestableSwipeCard(animator: animator)
        } else {
            swipeCard = TestableSwipeCard()
        }
        parentView.addSubview(swipeCard)
        
        swipeCard.translatesAutoresizingMaskIntoConstraints = false
        swipeCard.widthAnchor.constraint(equalToConstant: swipeCardWidth).isActive = true
        swipeCard.heightAnchor.constraint(equalToConstant: swipeCardHeight).isActive = true
        
        configure(swipeCard)
        
        swipeCard.setNeedsLayout()
        swipeCard.layoutIfNeeded()
        
        return swipeCard
    }
}
