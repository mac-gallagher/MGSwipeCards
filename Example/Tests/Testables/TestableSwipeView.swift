//
//  MockSwipeView.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/18/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

@testable import MGSwipeCards

class TestableSwipeView: SwipeView {
    override var panGestureRecognizer: UIPanGestureRecognizer {
        return panRecognizer
    }
    
    private lazy var panRecognizer = TestablePanGestureRecognizer(target: self, action: #selector(handlePan))
    
    override var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer = TestableTapGestureRecognizer(target: self, action: #selector(handleTap))
    
    var didTapCalled: Bool = false
    override func didTap(recognizer: UITapGestureRecognizer) {
        super.didTap(recognizer: recognizer)
        didTapCalled = true
    }
    
    var beginSwipingCalled: Bool = false
    override func beginSwiping(recognizer: UIPanGestureRecognizer) {
        super.beginSwiping(recognizer: recognizer)
        beginSwipingCalled = true
    }
    
    var didContinueSwipingCalled: Bool = false
    override func continueSwiping(recognizer: UIPanGestureRecognizer) {
        super.continueSwiping(recognizer: recognizer)
        didContinueSwipingCalled = true
    }
    
    var didSwipeCalled: Bool = false
    var didSwipeDirection: SwipeDirection?
    override func didSwipe(recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {
        super.didSwipe(recognizer: recognizer, with: direction)
        didSwipeCalled = true
        didSwipeDirection = direction
    }
    
    var didCancelSwipeCalled: Bool = false
    override func didCancelSwipe(recognizer: UIPanGestureRecognizer) {
        super.didCancelSwipe(recognizer: recognizer)
        didCancelSwipeCalled = true
    }
}
