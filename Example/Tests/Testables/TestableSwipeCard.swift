//
//  MockSwipeCard.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/19/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

@testable import MGSwipeCards

class TestableSwipeCard: MGSwipeCard {
    override var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    private lazy var panRecognizer = TestablePanGestureRecognizer(target: self, action: #selector(handlePan))
    
    override var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer = TestableTapGestureRecognizer(target: self, action: #selector(handleTap))
    
    var testTouchLocation: CGPoint?
    override var touchLocation: CGPoint? {
        return testTouchLocation ?? super.touchLocation
    }
    
    var testRotationDirection: CGFloat?
    override var rotationDirectionY: CGFloat {
        return testRotationDirection ?? super.rotationDirectionY
    }
    
    var testDragPercentage = [SwipeDirection: CGFloat]()
    override func dragPercentage(on direction: SwipeDirection) -> CGFloat {
        return testDragPercentage[direction] ?? super.dragPercentage(on: direction)
    }
    
    var testDragRotation: CGFloat?
    override func dragRotationAngle(recognizer: UIPanGestureRecognizer) -> CGFloat {
        return testDragRotation ?? super.dragRotationAngle(recognizer: recognizer)
    }
    
    var testDragTransform: CGAffineTransform?
    override func dragTransform(recognizer: UIPanGestureRecognizer) -> CGAffineTransform {
        return testDragTransform ?? super.dragTransform(recognizer: recognizer)
    }
    
    var testOverlayPercentage = [SwipeDirection: CGFloat]()
    override func overlayPercentage(forDirection direction: SwipeDirection) -> CGFloat {
        return testOverlayPercentage[direction] ?? super.overlayPercentage(forDirection: direction)
    }
}
