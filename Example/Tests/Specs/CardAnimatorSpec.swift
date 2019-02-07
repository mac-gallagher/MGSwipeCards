//
//  CardAnimatorSpec.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/19/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble

@testable import MGSwipeCards

class CardAnimatorSpec: QuickSpec {
    let swipeCardWidth: CGFloat = 100
    let swipeCardHeight: CGFloat = 200
    
    override func spec() {
        describe("CardAnimator") {
            var subject: TestableCardAnimator!
            var swipeCard: TestableSwipeCard!
            
            beforeEach {
                subject = TestableCardAnimator()
                swipeCard = self.setupSwipeCard()
            }
            
            describe("swipe rotation") {
                for direction in [SwipeDirection.up, SwipeDirection.down]{
                    context("when the direction is vertical") {
                        it("should return a rotation angle equal to zero") {
                            let upRotationForced = subject.rotationForSwipe(card: MGSwipeCard(), direction: direction, forced: true)
                            expect(upRotationForced).to(equal(0))
                            
                            let downRotationSwiped = subject.rotationForSwipe(card: MGSwipeCard(), direction: direction, forced: false)
                            expect(downRotationSwiped).to(equal(0))
                        }
                    }
                }
                
                context("when the direction is horizontal and the swipe is forced") {
                    let maximumRotationAngle: CGFloat = CGFloat.pi / 4
                    
                    beforeEach {
                        swipeCard.animationOptions.maximumRotationAngle = maximumRotationAngle
                    }
                    
                    it("should return the twice the maximum rotation angle") {
                        let leftRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .left, forced: true)
                        expect(leftRotationAngle).to(equal(-2 * maximumRotationAngle))
                        
                        let rightRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .right, forced: true)
                        expect(rightRotationAngle).to(equal(2 * maximumRotationAngle))
                    }
                }
                
                context("when the direction is horizontal and the swipe not forced") {
                    let cardCenterX: CGFloat = swipeCardWidth / 2
                    let cardCenterY: CGFloat = swipeCardHeight / 2
                    let maximumRotationAngle: CGFloat = CGFloat.pi / 4
                    
                    beforeEach {
                        swipeCard.animationOptions.maximumRotationAngle = maximumRotationAngle
                    }
                    
                    context("and the touch point is in the first quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                        }
                        
                        it("should return the correct rotation angle") {
                            let leftRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .left, forced: false)
                            expect(leftRotationAngle).to(equal(-2 * maximumRotationAngle))
                            
                            let rightRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .right, forced: false)
                            expect(rightRotationAngle).to(equal(2 * maximumRotationAngle))
                        }
                    }
                    
                    context("and the touch point is in the second quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                        }
                        
                        it("should return the correct rotation angle") {
                            let leftRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .left, forced: false)
                            expect(leftRotationAngle).to(equal(-2 * maximumRotationAngle))
                            
                            let rightRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .right, forced: false)
                            expect(rightRotationAngle).to(equal(2 * maximumRotationAngle))
                        }
                    }
                    
                    context("and the touch point is in the third quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                        }
                        
                        it("should return the correct rotation angle") {
                            let leftRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .left, forced: false)
                            expect(leftRotationAngle).to(equal(2 * maximumRotationAngle))
                            
                            let rightRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .right, forced: false)
                            expect(rightRotationAngle).to(equal(-2 * maximumRotationAngle))
                        }
                    }
                    
                    context("and the touch point is in the fourth quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.testTouchLocation = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                        }
                        
                        it("should return the correct rotation angle") {
                            let leftRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .left, forced: false)
                            expect(leftRotationAngle).to(equal(2 * maximumRotationAngle))
                            
                            let rightRotationAngle: CGFloat = subject.rotationForSwipe(card: swipeCard, direction: .right, forced: false)
                            expect(rightRotationAngle).to(equal(-2 * maximumRotationAngle))
                        }
                    }
                }
            }
            
            describe("swipe translation") {
                let diagonalTranslations: [CGPoint] = [CGPoint(x: 1, y: 1),
                                                       CGPoint(x: 1, y: -1),
                                                       CGPoint(x: -1, y: 1),
                                                       CGPoint(x: -1, y: -1)]

                for direction in SwipeDirection.allDirections {
                    context("when swiping in the indicated SwipeDirection below the minimum swipe speed") {
                        let screenBounds: CGRect = UIScreen.main.bounds
                        var actualTranslation: CGPoint!
                        
                        beforeEach {
                            swipeCard.testDragSpeed = swipeCard.minimumSwipeSpeed / 2
                            actualTranslation = subject.translationForSwipe(card: swipeCard, direction: direction, translation: direction.point)
                        }

                        it("should return a translation far enough to swipe the card off screen") {
                            let translatedCardBounds = CGRect(x: actualTranslation.x,
                                                              y: actualTranslation.y,
                                                              width: self.swipeCardWidth,
                                                              height: self.swipeCardHeight)
                            expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
                        }
                    }

                    context("when swiping in the indicated SwipeDirection at least the minimum swipe speed") {
                        let screenBounds: CGRect = UIScreen.main.bounds
                        var actualTranslation: CGPoint!

                        beforeEach {
                            swipeCard.testDragSpeed = swipeCard.minimumSwipeSpeed
                            actualTranslation = subject.translationForSwipe(card: swipeCard, direction: direction, translation: direction.point)
                        }

                        it("should return a translation far enough to swipe the card off screen") {
                            let translatedCardBounds = CGRect(x: actualTranslation.x,
                                                              y: actualTranslation.y,
                                                              width: self.swipeCardWidth,
                                                              height: self.swipeCardHeight)
                            expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
                        }
                    }
                }

                for diagonal in diagonalTranslations {
                    context("when swiping in a diagonal direction below the minimum swipe speed") {
                        let screenBounds: CGRect = UIScreen.main.bounds
                        let testDirection: SwipeDirection = .left
                        var actualTranslation: CGPoint!

                        beforeEach {
                            swipeCard.testDragSpeed = swipeCard.minimumSwipeSpeed / 2
                            actualTranslation = subject.translationForSwipe(card: swipeCard, direction: testDirection, translation: diagonal)
                        }

                        it("should return a translation far enough to swipe the card off screen") {
                            let translatedCardBounds = CGRect(x: actualTranslation.x,
                                                              y: actualTranslation.y,
                                                              width: self.swipeCardWidth,
                                                              height: self.swipeCardHeight)
                            expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
                        }
                    }

                    context("when swiping in a diagonal direction at least the minimum swipe speed") {
                        let screenBounds: CGRect = UIScreen.main.bounds
                        let testDirection: SwipeDirection = .left
                        var actualTranslation: CGPoint!
                        
                        beforeEach {
                            swipeCard.testDragSpeed = swipeCard.minimumSwipeSpeed
                            actualTranslation = subject.translationForSwipe(card: swipeCard, direction: testDirection, translation: diagonal)
                        }
                        
                        it("should return a translation far enough to swipe the card off screen") {
                            let translatedCardBounds = CGRect(x: actualTranslation.x,
                                                              y: actualTranslation.y,
                                                              width: self.swipeCardWidth,
                                                              height: self.swipeCardHeight)
                            expect(screenBounds.intersects(translatedCardBounds)).to(beFalse())
                        }
                    }
                }
            }

            describe("swipe transform") {
                context("when calling the swipeTransform method") {
                    let testRotationAngle: CGFloat = CGFloat.pi / 4
                    let testTranslation: CGPoint = CGPoint(x: 100, y: 200)
                    let testDirection: SwipeDirection = .left
                    let testForced: Bool = false
                    let testTransform: CGAffineTransform = {
                        let transform = CGAffineTransform(rotationAngle: testRotationAngle)
                        return transform.concatenating(CGAffineTransform(translationX: testTranslation.x, y: testTranslation.y))
                    }()

                    beforeEach {
                        subject.testRotationForSwipe = testRotationAngle
                        subject.testTranslationForSwipe = testTranslation
                    }

                    it("should return a transform with the proper rotation and translation") {
                        let actualTranslation: CGAffineTransform = subject.swipeTransform(forCard: swipeCard, forDirection: testDirection, forced: testForced)
                        expect(actualTranslation).to(equal(testTransform))
                    }
                }
            }

            describe("swipe overlay fade duration") {
                for direction in SwipeDirection.allDirections {
                    context("when the relativeSwipeOverlayFadeDuration method is called and there is no overlay in the indicated direction") {
                        context("and it is forced") {
                            it("should return a duration of zero") {
                                let actualDuration: TimeInterval = subject.relativeSwipeOverlayFadeDuration(swipeCard, direction: direction, forced: true)
                                expect(actualDuration).to(equal(0))
                            }
                        }

                        context("and it is not forced") {
                            it("should return a duration of zero") {
                                let actualDuration: TimeInterval = subject.relativeSwipeOverlayFadeDuration(swipeCard, direction: direction, forced: false)
                                expect(actualDuration).to(equal(0))
                            }
                        }
                    }

                    context("when the relativeSwipeOverlayFadeDuration method is called and there is an overlay in the indicated direction") {
                        beforeEach {
                            swipeCard.setOverlay(UIView(), forDirection: direction)
                        }

                        context("and it is forced") {
                            it("should return the correct percentage of the swipe duration") {
                                let actualDuration: TimeInterval = subject.relativeSwipeOverlayFadeDuration(swipeCard, direction: direction, forced: true)
                                let expectedDuration: TimeInterval = swipeCard.animationOptions.relativeSwipeOverlayFadeDuration * swipeCard.animationOptions.totalSwipeDuration
                                expect(actualDuration).to(equal(expectedDuration))
                            }
                        }

                        context("and it is not forced") {
                            it("should return a duration of zero") {
                                let actualDuration: TimeInterval = subject.relativeSwipeOverlayFadeDuration(swipeCard, direction: direction, forced: false)
                                expect(actualDuration).to(equal(0))
                            }
                        }
                    }
                }
            }
            
            describe("reverse swipe overlay fade duration") {
                for direction in SwipeDirection.allDirections {
                    context("when the relativeReverseSwipeOverlayFadeDuration method is called and there is no overlay in the indicated direction") {
                        it("should return a duration of zero") {
                            let actualDuration: TimeInterval = subject.relativeReverseSwipeOverlayFadeDuration(swipeCard, direction: direction)
                            expect(actualDuration).to(equal(0))
                        }
                    }
                    
                    context("when the relativeReverseSwipeOverlayFadeDuration method is called and there is an overlay in the indicated direction") {
                        beforeEach {
                            swipeCard.setOverlay(UIView(), forDirection: direction)
                        }
                        
                        it("should return the correct percentage of the swipe duration") {
                            let actualDuration: TimeInterval = subject.relativeReverseSwipeOverlayFadeDuration(swipeCard, direction: direction)
                             let expectedDuration: TimeInterval = swipeCard.animationOptions.relativeReverseSwipeOverlayFadeDuration * swipeCard.animationOptions.totalReverseSwipeDuration
                            expect(actualDuration).to(equal(expectedDuration))
                        }
                    }
                }
            }

            describe("reset methods") {
                context("when calling the non-animated reset method") {
                    let testOverlayDirection: SwipeDirection = .left
                    let testOverlay: UIView = UIView()
                    let testTransform: CGAffineTransform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)

                    beforeEach {
                        swipeCard.setOverlay(testOverlay, forDirection: testOverlayDirection)
                        swipeCard.testActiveDirection = testOverlayDirection
                        swipeCard.transform = testTransform
                        testOverlay.alpha = 1
                        subject.reset(swipeCard)
                    }
                    
                    it("should immediately set the active direction's overlay alpha to zero") {
                        expect(testOverlay.alpha).to(equal(0))
                    }

                    it("should immediately set the card's transform equal to the identity transform") {
                        expect(swipeCard.transform).to(equal(.identity))
                    }
                }

                context("when calling the animated reset method") {
                    let testOverlayDirection: SwipeDirection = .left
                    let testOverlay: UIView = UIView()
                    let testTransform: CGAffineTransform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
                    let testResetDuration: TimeInterval = 0.2
                    var testCompletionCalled: Bool = false
                    let testCompletion: ((Bool)) -> Void = { _ in
                        testCompletionCalled = true
                    }
                    
                    beforeEach {
                        swipeCard.setOverlay(testOverlay, forDirection: testOverlayDirection)
                        swipeCard.testActiveDirection = testOverlayDirection
                        swipeCard.animationOptions.totalResetDuration = testResetDuration
                        swipeCard.transform = testTransform
                        testOverlay.alpha = 1
                        subject.animateReset(swipeCard, completion: testCompletion)
                    }
                    
                    it("should set the active direction's overlay alpha to zero after the proper duration") {
                        expect(testOverlay.alpha).toEventually(equal(0), timeout: testResetDuration + 10)
                    }

                    it("should set the card's transform equal to the identity transform after the proper duration") {
                        expect(swipeCard.transform).to(equal(.identity))
                        expect(swipeCard.transform).toEventually(equal(.identity), timeout: testResetDuration + 10)
                    }

                    it("should call the completion once the animation has completed") {
                        expect(testCompletionCalled).toEventually(beTrue(), timeout: testResetDuration + 10)
                    }
                }
            }

            describe("swipe methods") {
                for direction in SwipeDirection.allDirections {
                    context("when calling the non-animated swipe method") {
                        let testOverlay: UIView = UIView()
                        let testTransform: CGAffineTransform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
                        
                        beforeEach {
                            for overlayDirection in SwipeDirection.allDirections {
                                if overlayDirection == direction {
                                    swipeCard.setOverlay(testOverlay, forDirection: overlayDirection)
                                    testOverlay.alpha = 1
                                } else {
                                    let tempOverlay: UIView = UIView()
                                    swipeCard.setOverlay(tempOverlay, forDirection: overlayDirection)
                                    tempOverlay.alpha = 1
                                }
                            }
                            subject.testTransformForSwipe = testTransform
                            subject.swipe(swipeCard, direction: direction)
                        }

                        it("should immediately set the indicated direction's overlay alpha value to 1, and all others to 0") {
                            for overlayDirection in SwipeDirection.allDirections {
                                if overlayDirection == direction {
                                    expect(swipeCard.overlays[overlayDirection]?.alpha).to(equal(1))
                                } else {
                                    expect(swipeCard.overlays[overlayDirection]?.alpha).to(equal(0))
                                }
                            }
                        }

                        it("should immediately set the card's transform to the proper swipe transform") {
                            expect(swipeCard.transform).to(equal(testTransform))
                        }
                    }

                    for forced in [false, true] {
                        context("when calling the animated swipe method") {
                            let testOverlay: UIView = UIView()
                            let testTransform: CGAffineTransform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
                            let testOverlayDuration: TimeInterval = 0.2
                            let testSwipeDuration: TimeInterval = 0.2
                            var testCompletionCalled: Bool = false
                            let testCompletion: ((Bool)) -> Void = { _ in
                                testCompletionCalled = true
                            }
                            beforeEach {
                                for overlayDirection in SwipeDirection.allDirections {
                                    if overlayDirection == direction {
                                        swipeCard.setOverlay(testOverlay, forDirection: overlayDirection)
                                        testOverlay.alpha = 1
                                    } else {
                                        let tempOverlay: UIView = UIView()
                                        swipeCard.setOverlay(tempOverlay, forDirection: overlayDirection)
                                        tempOverlay.alpha = 1
                                    }
                                }
                                swipeCard.animationOptions.relativeSwipeOverlayFadeDuration = testOverlayDuration
                                swipeCard.animationOptions.totalSwipeDuration = testSwipeDuration
                                
                                subject.testTransformForSwipe = testTransform
                                subject.testRelativeSwipeOverlayFadeDuration = testOverlayDuration
                                subject.animateSwipe(swipeCard, direction: direction, forced: forced, completion: testCompletion)
                            }
                            
                            it("should immediately set the alpha value of all overlays not in the indicated direction to zero") {
                                for overlayDirection in SwipeDirection.allDirections {
                                    if overlayDirection != direction {
                                        expect(swipeCard.overlays[overlayDirection]?.alpha).to(equal(0))
                                    }
                                }
                            }

                            it("should set the alpha value of the overlay in the indicated direction to 1 after the proper overlay duration") {
                                expect(testOverlay.alpha).toEventually(equal(1), timeout: testOverlayDuration + 10)
                            }

                            it("should set card's transform to the proper swipe transform after the total duration") {
                                expect(swipeCard.transform).toEventually(equal(testTransform), timeout: testOverlayDuration + testSwipeDuration + 10)
                            }

                            it("should call the completion once the animation has completed") {
                                expect(testCompletionCalled).toEventually(beTrue(), timeout: testOverlayDuration + testSwipeDuration + 10)
                            }
                        }
                    }
                }
            }

            describe("reverse swipe methods") {
                context("when calling the non-animated reverse swipe method") {
                    let testTransform: CGAffineTransform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
                    
                    beforeEach {
                        for overlayDirection in SwipeDirection.allDirections {
                            let tempOverlay = UIView()
                            swipeCard.setOverlay(tempOverlay, forDirection: overlayDirection)
                            tempOverlay.alpha = 1
                        }
                        swipeCard.transform = testTransform
                        subject.reverseSwipe(swipeCard)
                    }

                    it("should immediately set each direction's overlay's alpha value to zero") {
                        for overlayDirection in SwipeDirection.allDirections {
                            expect(swipeCard.overlays[overlayDirection]?.alpha).to(equal(0))
                        }
                    }

                    it("should immediately set the card's transform equal to the the identity transform") {
                        expect(swipeCard.transform).to(equal(.identity))
                    }
                }

                for direction in SwipeDirection.allDirections {
                    context("when calling the animated reverse swipe method") {
                        let testTransform: CGAffineTransform = CGAffineTransform(a: 1, b: 1, c: 1, d: 1, tx: 1, ty: 1)
                        let testOverlayDuration: TimeInterval = 0.2
                        let testSwipeDuration: TimeInterval = 0.2
                        var testCompletionCalled: Bool = false
                        let testCompletion: ((Bool)) -> Void = { _ in
                            testCompletionCalled = true
                        }

                        beforeEach {
                            subject.testTransformForSwipe = testTransform
                            subject.animateReverseSwipe(swipeCard, from: direction, completion: testCompletion)
                        }

//                        it("should immediately recreate the swipe in the indicated direction") {
//                            expect(swipeCard.transform).to(equal(testTransform))
//                        }

                        it("should call the completion once the animation has completed") {
                            expect(testCompletionCalled).toEventually(beTrue(), timeout: testSwipeDuration + testOverlayDuration + 10)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Setup

extension CardAnimatorSpec {
    func setupSwipeCard() -> TestableSwipeCard {
        let parentView = UIView()
        let swipeCard = TestableSwipeCard()
        parentView.addSubview(swipeCard)
        
        swipeCard.translatesAutoresizingMaskIntoConstraints = false
        swipeCard.widthAnchor.constraint(equalToConstant: swipeCardWidth).isActive = true
        swipeCard.heightAnchor.constraint(equalToConstant: swipeCardHeight).isActive = true
        
        swipeCard.setNeedsLayout()
        swipeCard.layoutIfNeeded()
        
        return swipeCard
    }
}
