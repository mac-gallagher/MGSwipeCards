//
//  MGCardStackViewOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/14/18.
//

open class MGCardStackViewOptions {
    
    public static var defaultOptions = MGCardStackViewOptions()
    
    open var cardStackInsets: UIEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    
    ///The maximum number of cards to be displayed on screen.
    open var numberOfVisibleCards: Int = 3
    
    open var backgroundCardResetAnimationDuration: TimeInterval = 0.3
    open var backgroundCardScaleAnimationDuration: TimeInterval = 0.4
    
    open var forwardShiftAnimationInitialScaleFactor: CGFloat = 0.98
    open var backwardShiftAnimationInitialScaleFactor: CGFloat = 1.02
    
    open var cardOverlayFadeInOutDuration: TimeInterval = 0.15
    open var cardUndoAnimationDuration: TimeInterval = 0.2
    
    ///The minimum duration of the off-screen swipe animation. Measured in seconds. Defaults to 0.8.
    open var cardSwipeAnimationMaximumDuration: TimeInterval = 0.8
    
    ///The effective bounciness of the swipe spring animation upon a cancelled swipe. Higher values increase spring movement range resulting in more oscillations and springiness. Defined as a value in the range [0, 20]. Defaults to 12.
    open var cardResetAnimationSpringBounciness: CGFloat = 12.0
    
    ///The effective speed of the spring animation upon a cancelled swipe. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20]. Defaults to 20.
    open var cardResetAnimationSpringSpeed: CGFloat = 20.0
    
    public init() {}
}
