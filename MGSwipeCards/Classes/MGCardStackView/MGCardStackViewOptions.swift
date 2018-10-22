//
//  MGCardStackViewOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/14/18.
//

open class MGCardStackViewOptions {
    
    public static var defaultOptions = MGCardStackViewOptions()
    
    open var cardStackInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    /**
     The maximum number of cards to be displayed on screen.
    */
    open var numberOfVisibleCards: Int = 3
    
    open var backgroundCardResetAnimationDuration: TimeInterval = 0.3
    open var backgroundCardScaleAnimationDuration: TimeInterval = 0.4
    
    public init() {}
}
