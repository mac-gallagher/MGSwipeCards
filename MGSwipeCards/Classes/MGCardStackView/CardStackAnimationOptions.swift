//
//  CardStackOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

open class CardStackAnimationOptions: NSObject {
    public static var defaultOptions = CardStackAnimationOptions()
    
    /// The amount of time it takes for the background cards to reset to their original position after a *cancelled swipe*.
    open var backgroundCardResetAnimationDuration: TimeInterval = 0.3
    
    /// The amount of time it takes for the background cards to reset to their original position after a *swipe*, *shift*, or *undo*.
    open var backgroundCardTransformAnimationDuration: TimeInterval = 0.4
}
