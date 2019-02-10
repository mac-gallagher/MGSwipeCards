//
//  TestableCardAnimator.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 2/4/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

@testable import MGSwipeCards

class TestableCardAnimator: DefaultCardAnimator {
    
    var testTransformForSwipe: CGAffineTransform?
    override func swipeTransform(forCard card: SwipeCard, forDirection direction: SwipeDirection, forced: Bool) -> CGAffineTransform {
        return testTransformForSwipe ?? super.swipeTransform(forCard: card, forDirection: direction, forced: forced)
    }
    
    var testTranslationForSwipe: CGPoint?
    override func translationForSwipe(card: SwipeCard, direction: SwipeDirection, translation: CGPoint) -> CGPoint {
        return testTranslationForSwipe ?? super.translationForSwipe(card: card, direction: direction, translation: translation)
    }
    
    var testRotationForSwipe: CGFloat?
    override func rotationForSwipe(card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
        return testRotationForSwipe ?? super.rotationForSwipe(card: card, direction: direction, forced: forced)
    }
    
    var testRelativeSwipeOverlayFadeDuration: TimeInterval?
    override func relativeSwipeOverlayFadeDuration(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> TimeInterval {
        return testRelativeSwipeOverlayFadeDuration ?? super.relativeSwipeOverlayFadeDuration(card, direction: direction, forced: forced)
    }
    
    var testRelativeReverseSwipeOverlayFadeDuration: TimeInterval?
    override func relativeReverseSwipeOverlayFadeDuration(_ card: SwipeCard, direction: SwipeDirection) -> TimeInterval {
        return testRelativeReverseSwipeOverlayFadeDuration ?? super.relativeReverseSwipeOverlayFadeDuration(card, direction: direction)
    }
}
