//
//  TestablePanGestureRecognizer.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/12/19.
//

import UIKit

class TestablePanGestureRecognizer: UIPanGestureRecognizer {
    var testTarget: AnyObject?
    var testAction: Selector?
    
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
    
    var testLocation: CGPoint?
    override func location(in view: UIView?) -> CGPoint {
        return testLocation ?? super.location(in: view)
    }
    
    var testTranslation: CGPoint?
    override func translation(in view: UIView?) -> CGPoint {
        return testTranslation ?? super.translation(in: view)
    }
    
    var testVelocity: CGPoint?
    override func velocity(in view: UIView?) -> CGPoint {
        return testVelocity ?? super.velocity(in: view)
    }
    
    var testState: UIGestureRecognizer.State?
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
