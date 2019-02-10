//
//  DefaultCardAnimationOptionsSpec.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 1/13/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble
import MGSwipeCards

class DefaultCardAnimationOptionsSpec: QuickSpec {
    override func spec() {
        describe("DefaultCardAnimationOptions") {
            var subject: DefaultCardAnimationOptions!
            
            beforeEach {
                subject = DefaultCardAnimationOptions()
            }
            
            describe("initialization") {
                context("when initializing a card animation options object") {
                    
                    it("should have a maximum rotation angle of CGFloat.pi / 10") {
                        expect(subject.maximumRotationAngle).to(equal(CGFloat.pi / 10))
                    }
                    
                    it("should have a total swipe duration of 0.7") {
                        expect(subject.totalSwipeDuration).to(equal(0.7))
                    }
                    
                    it("should have a relative swipe overlay fade duration of 0.15") {
                        expect(subject.relativeSwipeOverlayFadeDuration).to(equal(0.15))
                    }
                    
                    it("should have a relative reverse swipe overlay fade duration of 0.15") {
                        expect(subject.relativeReverseSwipeOverlayFadeDuration).to(equal(0.15))
                    }
                    
                    it("should have a reverse swipe animation duration of 0.2") {
                        expect(subject.totalReverseSwipeDuration).to(equal(0.2))
                    }
                    
                    it("should have a reset spring damping of 0.4") {
                        expect(subject.resetSpringDamping).to(equal(0.4))
                    }
                    
                    it("should have a reset spring duration of 0.6") {
                        expect(subject.totalResetDuration).to(equal(0.6))
                    }
                }
            }
            
            describe("maximum rotation angle") {
                context("when setting the maximum rotation angle to a value less than -CGFloat.pi/2") {
                    beforeEach {
                        subject.maximumRotationAngle = -CGFloat.pi
                    }
                    
                    it("should return -CGFloat.pi / 2") {
                        expect(subject.maximumRotationAngle).to(equal(-CGFloat.pi / 2))
                    }
                }
                
                context("when setting the maximum rotation angle to a value greater than CGFloat.pi/2") {
                    beforeEach {
                        subject.maximumRotationAngle = CGFloat.pi
                    }
                    
                    it("should return CGFloat.pi / 2") {
                        expect(subject.maximumRotationAngle).to(equal(CGFloat.pi / 2))
                    }
                }
            }
        }
    }
}
