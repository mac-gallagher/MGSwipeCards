//
//  CardAnimatonOptionsSpec.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 1/13/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble

@testable import MGSwipeCards

class CardAnimatonOptionsSpec: QuickSpec {
    override func spec() {
        describe("initialization") {
            context("when initializing a card animation options object") {
                var animationOptions: CardAnimationOptions!
                
                beforeEach {
                    animationOptions = CardAnimationOptions()
                }
                
                it("should have a maximum rotation angle of CGFloat.pi / 10") {
                    expect(animationOptions.maximumRotationAngle).to(equal(CGFloat.pi / 10))
                }
                
                it("should have a swipe animation duration of 0.6") {
                    expect(animationOptions.cardSwipeAnimationDuration).to(equal(0.6))
                }
                
                it("should have an overlay fade duration of 0.1") {
                    expect(animationOptions.overlayFadeAnimationDuration).to(equal(0.1))
                }
                
                it("should have a reverse swipe animation duration of 0.1") {
                    expect(animationOptions.reverseSwipeAnimationDuration).to(equal(0.1))
                }
                
                it("should have a reset animation spring bounciness of 12.0") {
                    expect(animationOptions.resetAnimationSpringBounciness).to(equal(12.0))
                }
                
                it("should have a reset animation spring speed of 20.0") {
                    expect(animationOptions.resetAnimationSpringSpeed).to(equal(20.0))
                }
            }
        }
        
        describe("describe maximum rotation angle") {
            context("when setting the maximum rotation angle to something less than -CGFloat.pi/2") {
                var animationOptions: CardAnimationOptions!
                
                beforeEach {
                    animationOptions = CardAnimationOptions()
                    animationOptions.maximumRotationAngle = -CGFloat.pi
                }
                it("should return -CGFloat.pi / 2") {
                    expect(animationOptions.maximumRotationAngle).to(equal(-CGFloat.pi / 2))
                }
            }
            
            context("when setting the maximum rotation angle to something greater than CGFloat.pi/2") {
                var animationOptions: CardAnimationOptions!
                
                beforeEach {
                    animationOptions = CardAnimationOptions()
                    animationOptions.maximumRotationAngle = CGFloat.pi
                }
                it("should return CGFloat.pi / 2") {
                    expect(animationOptions.maximumRotationAngle).to(equal(CGFloat.pi / 2))
                }
            }
        }
    }
}
