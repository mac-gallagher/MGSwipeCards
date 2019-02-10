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
    override func spec() {
        describe("MGSwipeCard") {
            let cardWidth: CGFloat = 100
            let cardHeight: CGFloat = 200
            var subject: TestableSwipeCard!
            var mockSwipeCardDelegate: MockSwipeCardDelegate!
            var mockCardAnimator: MockCardAnimator!
            var testPanGestureRecognizer: TestablePanGestureRecognizer!
            
            beforeEach {
                mockSwipeCardDelegate = MockSwipeCardDelegate()
                mockCardAnimator = MockCardAnimator()
                subject = TestableSwipeCard(delegate: mockSwipeCardDelegate,
                                            animator: mockCardAnimator,
                                            animationOptions: DefaultCardAnimationOptions())
                testPanGestureRecognizer = subject.panGestureRecognizer as? TestablePanGestureRecognizer
                self.layoutSwipeCard(subject, width: cardWidth, height: cardHeight)
            }
            
            describe("initialization") {
                context("when initializing a card") {
                    var swipeCard: SwipeCard!
                    
                    beforeEach {
                        swipeCard = SwipeCard()
                    }
                    
                    it("should have the default animation options") {
                        expect(swipeCard.animationOptions).to(be(DefaultCardAnimationOptions.shared))
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
                }
            }
            
            //MARK: - Layout
            
            describe("content + footer layout") {
                context("when adding a footer to a card") {
                    let footerHeight: CGFloat = 80
                    
                    beforeEach {
                        subject.footer = UIView()
                        subject.footerHeight = footerHeight
                        subject.layoutIfNeeded()
                    }
                    
                    it("should layout the footer with the correct frame") {
                        let expectedY: CGFloat = cardHeight - footerHeight
                        let expectedFrame: CGRect = CGRect(x: 0, y: expectedY, width: cardWidth, height: footerHeight)
                        expect(subject.footer?.frame).to(equal(expectedFrame))
                    }
                }
                
                context("when adding content to a card with no footer") {
                    beforeEach {
                        subject.content = UIView()
                        subject.layoutIfNeeded()
                    }
                    
                    it("should layout the content to cover the card's bounds") {
                        expect(subject.content?.frame).to(equal(subject.bounds))
                    }
                }
                
                context("when adding content to a card with an opaque footer") {
                    let footerHeight: CGFloat = 80
                    
                    beforeEach {
                        subject.content = UIView()
                        subject.footer = UIView()
                        subject.footerHeight = footerHeight
                        subject.layoutIfNeeded()
                    }
                    
                    it("should layout the content above the card's footer") {
                        let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
                        expect(subject.content?.frame).to(equal(expectedFrame))
                    }
                }
                
                context("when adding content to a card with a transparent footer") {
                    let footer = UIView()
                    let footerHeight: CGFloat = 80
                    let content = UIView()
                    
                    beforeEach {
                        subject.content = content
                        subject.footerHeight = footerHeight
                        subject.footer = footer
                        subject.isFooterTransparent = true
                        subject.layoutIfNeeded()
                    }
                    
                    it("should layout its footer above its content in the view hierarchy") {
                        let footerIndex = subject.subviews.firstIndex(of: footer)
                        let contentIndex = subject.subviews.firstIndex(of: content)
                        expect(contentIndex).to(beLessThan(footerIndex))
                    }
                    
                    it("should layout the content to cover the card's bounds") {
                        expect(subject.content?.frame).to(equal(subject.bounds))
                    }
                }
            }
            
            describe("overlay layout") {
                for direction in SwipeDirection.allDirections {
                    context("when adding an overlay") {
                        let overlay = UIView()
                        
                        beforeEach {
                            subject.setOverlay(overlay, forDirection: direction)
                        }
                        
                        it("should add the overlay to the overlay container's view hierarchy") {
                            expect(overlay.superview).to(equal(subject.overlayContainer))
                        }
                        
                        it("should set the overlay's alpha value equal to zero") {
                            expect(overlay.alpha).to(equal(0))
                        }
                    }
                    
                    context("when replacing a card's existing overlay") {
                        let oldOverlay = UIView()
                        
                        beforeEach {
                            subject.setOverlay(oldOverlay, forDirection: direction)
                            subject.setOverlay(UIView(), forDirection: direction)
                        }
                        
                        it("should remove the old overlay from its superview") {
                            expect(oldOverlay.superview).to(beNil())
                        }
                    }
                    
                    context("when adding an overlay to a card with no footer") {
                        let overlay = UIView()
                        
                        beforeEach {
                            subject.setOverlay(overlay, forDirection: direction)
                            subject.layoutIfNeeded()
                        }
                        
                        it("should layout its overlay to cover the card's bounds") {
                            expect(overlay.frame).to(equal(subject.bounds))
                        }
                    }
                    
                    context("when adding an overlay to a card with an opaque footer") {
                        let overlay = UIView()
                        let footerHeight: CGFloat = 80
                        
                        beforeEach {
                            subject.setOverlay(overlay, forDirection: direction)
                            subject.footerHeight = footerHeight
                            subject.footer = UIView()
                            subject.layoutIfNeeded()
                        }
                        
                        it("should layout the overlay above the card's footer") {
                            let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
                            expect(overlay.frame).to(equal(expectedFrame))
                        }
                    }
                    
                    context("when adding an overlay to a card with a transparent footer") {
                        let overlay = UIView()
                        let footer = UIView()
                        let footerHeight: CGFloat = 80
                        
                        beforeEach {
                            subject.setOverlay(overlay, forDirection: direction)
                            subject.footer = footer
                            subject.footerHeight = footerHeight
                            subject.isFooterTransparent = true
                            subject.layoutIfNeeded()
                        }
                        
                        it("should layout its overlay container above its footer in the view hierarchy") {
                            let footerIndex = subject.subviews.firstIndex(of: footer)
                            let overlayContainerIndex = subject.subviews.firstIndex(of: subject.overlayContainer)
                            expect(overlayContainerIndex).to(beGreaterThan(footerIndex))
                        }
                        
                        it("should layout the overlay above the card's footer") {
                            let expectedFrame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight - footerHeight)
                            expect(overlay.frame).to(equal(expectedFrame))
                        }
                    }
                }
            }
            
            //MARK: - Drag Computations
            
            describe("drag rotation") {
                for direction in [SwipeDirection.up, SwipeDirection.down] {
                    context("when the card is dragged vertically") {
                        
                        beforeEach {
                            let translation: CGPoint = CGPoint(x: 0, y: direction.point.y * UIScreen.main.bounds.height)
                            testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                        }
                        
                        it("should have rotation angle equal to zero") {
                            let actualRotationAngle = subject.dragRotationAngle(recognizer: testPanGestureRecognizer)
                            expect(actualRotationAngle).to(equal(0))
                        }
                    }
                }
                
                for direction in [SwipeDirection.left, SwipeDirection.right] {
                    for rotationDirection in [CGFloat(-1), CGFloat(1)] {
                        context("when the card is dragged horizontally") {
                            let maximumRotationAngle: CGFloat = CGFloat.pi / 4
                            
                            beforeEach {
                                subject.testRotationDirection = rotationDirection
                                subject.animationOptions.maximumRotationAngle = maximumRotationAngle
                            }
                            
                            context("less than the screen's width") {
                                let translation: CGPoint = CGPoint(x: direction.point.x * (UIScreen.main.bounds.width - 1), y: 0)
                                
                                beforeEach {
                                    testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                                }
                                
                                it("should return a rotation angle less than the maximum rotation angle") {
                                    let actualRotationAngle = subject.dragRotationAngle(recognizer: testPanGestureRecognizer)
                                    expect(abs(actualRotationAngle)).to(beLessThan(maximumRotationAngle))
                                }
                            }
                            
                            context("at least the length of the screen's width") {
                                
                                beforeEach {
                                    let translation: CGPoint = CGPoint(x: direction.point.x * UIScreen.main.bounds.width, y: 0)
                                    testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                                }
                                
                                it("should return a rotation angle equal to the maximum rotation angle") {
                                    let actualRotationAngle = subject.dragRotationAngle(recognizer: testPanGestureRecognizer)
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
                
                beforeEach {
                    subject.testDragRotation = rotationAngle
                    testPanGestureRecognizer.performPan(withLocation: nil, translation: translation, velocity: nil, state: nil)
                }
                
                context("when the card is dragged") {
                    it("should return the transform with the proper rotation and translation") {
                        let expectedTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
                            .concatenating(CGAffineTransform(rotationAngle: rotationAngle))
                        expect(subject.dragTransform(recognizer: testPanGestureRecognizer)).to(equal(expectedTransform))
                    }
                }
            }
            
            describe("overlay percentage") {
                for direction in SwipeDirection.allDirections {
                    context("when the drag percentage is nonzero in exactly one direction") {
                        
                        beforeEach {
                            subject.testDragPercentage[direction] = 0.1
                        }
                        
                        it("should return a nonzero overlay percentage in the dragged direction and 0% for all other directions") {
                            for swipeDirection in SwipeDirection.allDirections {
                                if swipeDirection == direction {
                                    expect(subject.overlayPercentage(forDirection: swipeDirection)).toNot(equal(0))
                                } else {
                                    expect(subject.overlayPercentage(forDirection: swipeDirection)).to(equal(0))
                                }
                            }
                        }
                    }
                    
                    context("when the card is dragged in the indicated direction below its minimum swipe margin") {
                        let minimumSwipeMargin: CGFloat = 0.7
                        
                        beforeEach {
                            subject.minimumSwipeMargin = minimumSwipeMargin
                            subject.testDragPercentage[direction] = minimumSwipeMargin - 0.1
                        }
                        
                        it("should have an overlay percentage less than 1 in the indicated direction") {
                            let expectedPercentage: CGFloat = subject.overlayPercentage(forDirection: direction)
                            expect(expectedPercentage).to(beLessThan(1))
                        }
                    }
                    
                    context("when the card is dragged in the indicated direction at least its minimum swipe margin") {
                        let minimumSwipeMargin: CGFloat = 0.7
                        
                        beforeEach {
                            subject.minimumSwipeMargin = minimumSwipeMargin
                            subject.testDragPercentage[direction] = minimumSwipeMargin
                        }
                        
                        it("should have an overlay percentage equal to 1 in the indicated direction") {
                            let expectedPercentage: CGFloat = subject.overlayPercentage(forDirection: direction)
                            expect(expectedPercentage).to(equal(1))
                        }
                    }
                }
                
                context("when the drag percentage is nonzero in more than one direction") {
                    let neighboringPairs: [(SwipeDirection, SwipeDirection)]
                        = [(.up, .right),
                           (.right, .down),
                           (.down, .left),
                           (.left, .up)]
                    
                    for (direction1, direction2) in neighboringPairs {
                        context("and the drag percentage of the two directions is equal") {
                            
                            beforeEach {
                                subject.testDragPercentage[direction1] = 0.1
                                subject.testDragPercentage[direction2] = 0.1
                            }
                            
                            it("should return an overlay percentage of 0% for both directions") {
                                expect(subject.overlayPercentage(forDirection: direction1)).to(equal(0))
                                expect(subject.overlayPercentage(forDirection: direction2)).to(equal(0))
                            }
                        }
                        
                        context("and the drag percentage of the two directions is not equal") {
                            
                            beforeEach {
                                subject.testDragPercentage[direction1] = 0.2
                                subject.testDragPercentage[direction2] = 0.1
                            }
                            
                            it("should return an overlay percentage of 0% for one direction and a nonzero overlay percentage for the other") {
                                let direction1Percentage: CGFloat = subject.overlayPercentage(forDirection: direction1)
                                let direction2Percentage: CGFloat = subject.overlayPercentage(forDirection: direction2)
                                expect(direction1Percentage).toNot(equal(0))
                                expect(direction2Percentage).to(equal(0))
                            }
                        }
                    }
                }
            }
            
            //MARK: - Completions
            
            describe("animation completions") {
                context("when the reset animation completion is called") {
                    
                    beforeEach {
                        subject.resetCompletion(subject)
                    }
                    
                    it("should call the didCancelSwipe delegate function") {
                        expect(mockSwipeCardDelegate.didCancelSwipeCalled).to(beTrue())
                    }
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when the swipe animation completion is called") {
                        context("and forced is true") {
                            
                            beforeEach {
                                subject.swipeCompletion(subject, direction, true)
                            }
                            
                            it("should call the didSwipe delegate method with the correct parameters") {
                                expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
                                expect(mockSwipeCardDelegate.didSwipeForced).to(beTrue())
                                expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
                            }
                        }
                        
                        context("and forced is false") {
                            
                            beforeEach {
                                subject.swipeCompletion(subject, direction, false)
                            }
                            
                            it("should call the didSwipe delegate method with the correct parameters") {
                                expect(mockSwipeCardDelegate.didSwipeCalled).to(beTrue())
                                expect(mockSwipeCardDelegate.didSwipeForced).to(beFalse())
                                expect(mockSwipeCardDelegate.didSwipeDirection).to(equal(direction))
                            }
                        }
                    }
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when the reverse swipe animation completion is called") {
                        
                        beforeEach {
                            subject.reverseSwipeCompletion(subject, direction)
                        }
                        
                        it("should call the didSwipe delegate method with the correct parameters") {
                            expect(mockSwipeCardDelegate.didReverseSwipeCalled).to(beTrue())
                            expect(mockSwipeCardDelegate.didReverseSwipeDirection).to(equal(direction))
                        }
                        
                        it("should enable user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beTrue())
                        }
                    }
                }
            }
            
            //MARK: - Gestures
            
            describe("tap gesture") {
                context("when the didTap method is called") {
                    
                    beforeEach {
                        subject.didTap(recognizer: UITapGestureRecognizer())
                    }
                    
                    it("should call the didTap delegate method") {
                        expect(mockSwipeCardDelegate.didTapCalled).to(beTrue())
                    }
                }
            }
            
            describe("physical swipe begin") {
                context("when the beginSwiping method is called") {
                    
                    beforeEach {
                        subject.beginSwiping(recognizer: UIPanGestureRecognizer())
                    }
                    
                    it("should call the didBeginSwipe delegate method") {
                        expect(mockSwipeCardDelegate.didBeginSwipeCalled).to(beTrue())
                    }
                    
                    it("should remove all animations on the card") {
                        expect(mockCardAnimator.removeAllAnimationsCalled).to(beTrue())
                    }
                }
                
                context("when the physical swipe begins") {
                    let cardCenterX: CGFloat = cardWidth / 2
                    let cardCenterY: CGFloat = cardHeight / 2
                    
                    context("and the touch point is in the first quadrant of the card's bounds") {
                        
                        beforeEach {
                            subject.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                        }
                        
                        it("should have rotation direction equal to 1") {
                            expect(subject.rotationDirectionY).to(equal(1))
                        }
                    }
                    
                    context("and the touch point is in the second quadrant of the card's bounds") {
                        
                        beforeEach {
                            subject.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                        }
                        
                        it("should have rotation direction equal to 1") {
                            expect(subject.rotationDirectionY).to(equal(1))
                        }
                    }
                    
                    context("and the touch point is in the third quadrant of the card's bounds") {
                        
                        beforeEach {
                            subject.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                        }
                        
                        it("should have rotation direction equal to -1") {
                            expect(subject.rotationDirectionY).to(equal(-1))
                        }
                    }
                    
                    context("and the touch point is in the fourth quadrant of the card's bounds") {
                        
                        beforeEach {
                            subject.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                        }
                        
                        it("should have rotation direction equal to -1") {
                            expect(subject.rotationDirectionY).to(equal(-1))
                        }
                    }
                }
            }
            
            describe("physical swipe change") {
                for direction in SwipeDirection.allDirections {
                    context("when the continueSwiping method is called") {
                        let testOverlayPercentage: CGFloat = 0.5
                        let overlay: UIView = UIView()
                        let testTransform: CGAffineTransform = {
                            let rotation = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                            let translation = CGAffineTransform(translationX: 100, y: 100)
                            return rotation.concatenating(translation)
                        }()
                        
                        beforeEach {
                            subject.setOverlay(overlay, forDirection: direction)
                            subject.testOverlayPercentage[direction] = testOverlayPercentage
                            subject.testDragTransform = testTransform
                            subject.continueSwiping(recognizer: UIPanGestureRecognizer())
                        }
                        
                        it("should apply the proper overlay alpha values") {
                            expect(overlay.alpha).to(equal(testOverlayPercentage))
                        }
                        
                        it("should apply the proper transformation to the card") {
                            expect(subject.transform).to(equal(testTransform))
                        }
                        
                        it("should call the didContinueSwipe delegate method") {
                            expect(mockSwipeCardDelegate.didContinueSwipeCalled).to(beTrue())
                        }
                    }
                }
            }
            
            describe("physical swipe end") {
                context("when the parent view's didCancelSwipe method is called") {
                    
                    beforeEach {
                        subject.didCancelSwipe(recognizer: UIPanGestureRecognizer())
                    }
                    
                    it("should call the animator's reset method") {
                        expect(mockCardAnimator.resetAnimationCalled).to(beTrue())
                    }
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when the parent view's didSwipe method is called") {
                        
                        beforeEach {
                            subject.didSwipe(recognizer: UIPanGestureRecognizer(), with: direction)
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should trigger a swipe animation with the correct parameters") {
                            expect(mockCardAnimator.swipeAnimationCalled).to(beTrue())
                            expect(mockCardAnimator.swipeAnimationDirection).to(equal(direction))
                            expect(mockCardAnimator.swipeAnimationForced).to(beFalse())
                        }
                    }
                }
            }
            
            //MARK: - Main Methods
            
            describe("overlay getter") {
                for direction in SwipeDirection.allDirections {
                    context("when calling the overlay getter function") {
                        let overlay = UIView()
                        
                        beforeEach {
                            subject.setOverlay(overlay, forDirection: direction)
                        }
                        
                        it("should return the correct overlay") {
                            expect(subject.overlay(forDirection: direction)).to(equal(overlay))
                        }
                    }
                }
            }
            
            describe("programmatic swipe") {
                for direction in SwipeDirection.allDirections {
                    context("when the swipe method is called with no animation") {
                        
                        beforeEach {
                            subject.swipe(direction: direction, animated: false)
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("call the animator's swipe method with the correct direction") {
                            expect(mockCardAnimator.swipeCalled).to(beTrue())
                            expect(mockCardAnimator.swipeDirection).to(equal(direction))
                        }
                    }
                    
                    context("when the swipe method is called with an animation") {
                        
                        beforeEach {
                            subject.swipe(direction: direction, animated: true)
                        }
                        
                        it("should disable the user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should trigger a swipe animation with the correct parameters") {
                            expect(mockCardAnimator.swipeAnimationCalled).to(beTrue())
                            expect(mockCardAnimator.swipeAnimationDirection).to(equal(direction))
                            expect(mockCardAnimator.swipeAnimationForced).to(beTrue())
                        }
                    }
                }
            }
            
            describe("reverse swipe") {
                for direction in SwipeDirection.allDirections {
                    context("when the reverse swipe method is called with no animation") {
                        
                        beforeEach {
                            subject.reverseSwipe(from: direction, animated: false)
                        }
                        
                        it("should call the animator's reverse swipe method") {
                            expect(mockCardAnimator.reverseSwipeCalled).to(beTrue())
                        }
                    }
                    
                    context("when the reverse swipe method is called with an animation") {
                        
                        beforeEach {
                            subject.reverseSwipe(from: direction, animated: true)
                        }
                        
                        it("should disable user interaction on the card") {
                            expect(subject.isUserInteractionEnabled).to(beFalse())
                        }
                        
                        it("should trigger a reverse swipe animation from the correct direction") {
                            expect(mockCardAnimator.reverseSwipeAnimationCalled).to(beTrue())
                            expect(mockCardAnimator.reverseSwipeAnimationDirection).to(equal(direction))
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Setup

extension MGSwipeCardSpec {
    func layoutSwipeCard(_ card: SwipeCard, width: CGFloat, height: CGFloat) {
        let parentView = UIView()
        
        parentView.addSubview(card)
        
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: width).isActive = true
        card.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        card.setNeedsLayout()
        card.layoutIfNeeded()
    }
}
