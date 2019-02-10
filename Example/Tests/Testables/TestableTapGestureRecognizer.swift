//
//  TestableTapGestureRecognizer.swift
//  MGSwipeCards_Tests
//
//  Created by Mac Gallagher on 1/12/19.
//

import UIKit

class TestableTapGestureRecognizer: UITapGestureRecognizer {
    var testTarget: AnyObject?
    var testAction: Selector?
    
    override init(target: Any?, action: Selector?) {
        testTarget = target as AnyObject
        testAction = action
        super.init(target: target, action: action)
    }
    
    var testLocation: CGPoint?
    override func location(in view: UIView?) -> CGPoint {
        return testLocation ?? super.location(in: view)
    }
    
    func performTap(withLocation location: CGPoint?) {
        testLocation = location
        if let action = testAction {
            testTarget?.performSelector(onMainThread: action, with: self, waitUntilDone: true)
        }
    }
}
