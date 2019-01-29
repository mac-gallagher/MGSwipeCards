//
//  TestableCardAnimator.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 2/4/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

@testable import MGSwipeCards

class TestableCardAnimator: CardAnimator {
    
    var testTransformForSwipe: CGAffineTransform?
    override func swipeTransform(forCard card: MGSwipeCard, forDirection direction: SwipeDirection, forced: Bool) -> CGAffineTransform {
        return testTransformForSwipe ?? super.swipeTransform(forCard: card, forDirection: direction, forced: forced)
    }
    
    var testTranslationForSwipe: CGPoint?
    override func translationForSwipe(card: MGSwipeCard, direction: SwipeDirection, translation: CGPoint) -> CGPoint {
        return testTranslationForSwipe ?? super.translationForSwipe(card: card, direction: direction, translation: translation)
    }
    
    var testRotationForSwipe: CGFloat?
    override func rotationForSwipe(card: MGSwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
        return testRotationForSwipe ?? super.rotationForSwipe(card: card, direction: direction, forced: forced)
    }
    
    var testOverlayFadeDuration: TimeInterval?
    override func overlayFadeDuration(_ card: MGSwipeCard, direction: SwipeDirection, forced: Bool) -> TimeInterval {
        return testOverlayFadeDuration ?? super.overlayFadeDuration(card, direction: direction, forced: forced)
    }
}
