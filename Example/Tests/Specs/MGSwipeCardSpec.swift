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
            describe("initialization") { //DONE
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
            
            describe("content + footer layout") { //DONE
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
            
            describe("overlay layout") { //DONE
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
            
            describe("tap gesture") { //DONE
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
            
            describe("physical swipe begin") { //DONE
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
                
                context("when the swipe begins") {
                    let cardCenterX: CGFloat = self.swipeCardWidth / 2
                    let cardCenterY: CGFloat = self.swipeCardHeight / 2
                    var swipeCard: TestableSwipeCard!
                    
                    beforeEach {
                        swipeCard = self.setupSwipeCard()
                    }
                    
                    context("and the touch point is in the first quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.touchPoint = CGPoint(x: cardCenterX + 1, y: cardCenterY + 1)
                        }
                        
                        it("should have rotation direction equal to -1") {
                            expect(swipeCard.rotationDirectionY).to(equal(-1))
                        }
                    }
                    
                    context("and the touch point is in the second quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.touchPoint = CGPoint(x: cardCenterX - 1, y: cardCenterY + 1)
                        }
                        
                        it("should have rotation direction equal to -1") {
                            expect(swipeCard.rotationDirectionY).to(equal(-1))
                        }
                    }
                    
                    context("and the touch point is in the third quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.touchPoint = CGPoint(x: cardCenterX - 1, y: cardCenterY - 1)
                        }
                        
                        it("should have rotation direction equal to 1") {
                            expect(swipeCard.rotationDirectionY).to(equal(1))
                        }
                    }
                    
                    context("and the touch point is in the fourth quadrant of the card's bounds") {
                        beforeEach {
                            swipeCard.touchPoint = CGPoint(x: cardCenterX + 1, y: cardCenterY - 1)
                        }
                        
                        it("should have rotation direction equal to 1") {
                            expect(swipeCard.rotationDirectionY).to(equal(1))
                        }
                    }
                }
            }
            
            //TODO: - Finish translation, rotation, and overlay alpha
            describe("physical swipe change") {
                context("when the parent view's continueSwiping method is called") {
                    var mockSwipeCardDelegate: MockSwipeCardDelegate!
                    var swipeCard: MGSwipeCard!
                    
                    beforeEach {
                        mockSwipeCardDelegate = MockSwipeCardDelegate()
                        swipeCard = self.setupSwipeCard(configure: { card in
                            card.delegate = mockSwipeCardDelegate
                        })
                        swipeCard.continueSwiping(recognizer: UIPanGestureRecognizer())
                    }
                    
                    it("should call the didContinueSwipe delegate method") {
                        expect(mockSwipeCardDelegate.didContinueSwipeCalled).to(beTrue())
                    }
                }
            }
            
            describe("physical swipe end") { //DONE
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
                        var animator = MockCardAnimator()
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
                            let timeout: TimeInterval = swipeCard.animationOptions.cardSwipeAnimationDuration + 10
                            expect(mockSwipeCardDelegate.didSwipeCalled).toEventually(beTrue(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didSwipeForced).toEventually(beFalse(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didSwipeDirection).toEventually(equal(direction), timeout: timeout)
                        }
                    }
                }
            }
            
            describe("overlay percentage") { //FINISH
                var swipeCard: TestableSwipeCard!
                
                beforeEach {
                    swipeCard = self.setupSwipeCard()
                }
                
                for direction in SwipeDirection.allDirections {
                    context("when the card is dragged in exactly one direction") {
                        beforeEach {
                            swipeCard.dragPercentage[direction] = 0.1
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
                }
                
                context("when the card is dragged in more than one direction") {
                    let neighboringPairs: [(SwipeDirection, SwipeDirection)]
                        = [(.up, .right),
                           (.right, .down),
                           (.down, .left),
                           (.left, .up)]
                    
                    for (direction1, direction2) in neighboringPairs {
                        context("and the drag percentage of two directions is equal") {
                            beforeEach {
                                swipeCard.dragPercentage[direction1] = 0.1
                                swipeCard.dragPercentage[direction2] = 0.1
                            }
                            
                            it("should return an overlay percentage of 0% for both directions") {
                                expect(swipeCard.overlayPercentage(forDirection: direction1)).to(equal(0))
                                expect(swipeCard.overlayPercentage(forDirection: direction2)).to(equal(0))
                            }
                        }
                        
                        context("and the drag percentage of the two directions is not equal") {
                            beforeEach {
                                swipeCard.dragPercentage[direction1] = 0.2
                                swipeCard.dragPercentage[direction2] = 0.1
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
            
            describe("rotation angle") {
                //pi / 2
            }
            
            describe("programmatic swipe") { //DONE
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
            
            describe("reverse swipe") { //DONE
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
                            let timeout: TimeInterval = swipeCard.animationOptions.reverseSwipeAnimationDuration + 10
                            expect(mockSwipeCardDelegate.didReverseSwipeCalled).toEventually(beTrue(), timeout: timeout)
                            expect(mockSwipeCardDelegate.didReverseSwipeDirection).toEventually(equal(direction), timeout: timeout)
                        }
                        
                        it("should enable user interaction on the card once the animation has completed") {
                            let timeout: TimeInterval = swipeCard.animationOptions.reverseSwipeAnimationDuration + 10
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
    func setupSwipeCard(configure: (TestableSwipeCard) -> Void = { _ in } ) -> TestableSwipeCard {
        let parentView = UIView()
        let swipeCard = TestableSwipeCard()
        parentView.addSubview(swipeCard)
        
        swipeCard.translatesAutoresizingMaskIntoConstraints = false
        swipeCard.widthAnchor.constraint(equalToConstant: swipeCardWidth).isActive = true
        swipeCard.heightAnchor.constraint(equalToConstant: swipeCardHeight).isActive = true
        
        configure(swipeCard)
        
        swipeCard.setNeedsLayout()
        swipeCard.layoutIfNeeded()
        
        return swipeCard
    }
    
    func setupSwipeCard(withAnimator animator: CardAnimatable,
                        configure: (TestableSwipeCard) -> Void = { _ in } ) -> TestableSwipeCard {
        let parentView = UIView()
        let swipeCard = TestableSwipeCard(animator: animator)
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
