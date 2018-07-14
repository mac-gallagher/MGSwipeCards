//
//  MGCardStackViewOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/14/18.
//

import Foundation

open class MGCardStackViewOptions {
    
    open static var defaultOptions = MGCardStackViewOptions()
    
    open var cardStackInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    open var numberOfVisibleCards: Int = 2
    open var backgroundCardScaleFactor: CGFloat = 0.95
    open var backgroundCardResetAnimationDuration: TimeInterval = 0.2
    open var forwardShiftAnimationInitialScaleFactor: CGFloat = 0.98
    open var backwardShiftAnimationInitialScaleFactor: CGFloat = 1.02
    
    public init() {}
}
