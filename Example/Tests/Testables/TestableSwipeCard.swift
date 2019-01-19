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
    
    var touchPoint: CGPoint?
    override var touchLocation: CGPoint? {
        return touchPoint ?? super.touchLocation
    }
    
    var dragPercentage = [SwipeDirection: CGFloat]()
    override func dragPercentage(on direction: SwipeDirection) -> CGFloat {
        return dragPercentage[direction] ?? super.dragPercentage(on: direction)
    }
}
