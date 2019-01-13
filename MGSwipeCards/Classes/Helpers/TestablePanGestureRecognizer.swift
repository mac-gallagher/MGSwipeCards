//
//  TestableUIPanGestureRecognizer.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 1/12/19.
//

import UIKit

class TestablePanGestureRecognizer: UIPanGestureRecognizer {
    var testTarget: AnyObject?
    var testAction: Selector?
    
    var testLocation: CGPoint?
    var testTranslation: CGPoint?
    var testVelocity: CGPoint?
    var testState: UIGestureRecognizer.State?
    
    override var state: UIGestureRecognizer.State {
        get {
            return testState ?? super.state
        }
        set {
            super.state = newValue
        }
    }
    
    override init(target: Any?, action: Selector?) {
        testTarget = target as AnyObject
        testAction = action
        super.init(target: target, action: action)
    }
    
    override func location(in view: UIView?) -> CGPoint {
        return testLocation ?? super.location(in: view)
    }
    
    override func translation(in view: UIView?) -> CGPoint {
        return testTranslation ?? super.translation(in: view)
    }
    
    override func velocity(in view: UIView?) -> CGPoint {
        return testVelocity ?? super.velocity(in: view)
    }
    
    func performPan(withLocation location: CGPoint?, translation: CGPoint?, velocity: CGPoint?, state: UIPanGestureRecognizer.State?) {
        testLocation = location
        testTranslation = translation
        testVelocity = velocity
        testState = state
        if let action = testAction {
            testTarget?.performSelector(onMainThread: action, with: self, waitUntilDone: true)
        }
    }
}
