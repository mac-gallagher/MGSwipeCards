//
//  MGSwipeCardOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 7/12/18.
//

import Foundation

open class MGSwipeCardOptions {
    
    static var defaultOptions = MGSwipeCardOptions()
    
    ///The minimum duration of the off-screen swipe animation. Measured in seconds. Defaults to 0.8.
    public var swipeAnimationMinimumDuration: TimeInterval = 0.8
    
    ///The effective bounciness of the swipe spring animation upon a cancelled swipe. Higher values increase spring movement range resulting in more oscillations and springiness. Defined as a value in the range [0, 20]. Defaults to 12.
    public var resetAnimationSpringBounciness: CGFloat = 12.0
    
    ///The effective speed of the spring animation upon a cancelled swipe. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20]. Defaults to 20.
    public var resetAnimationSpringSpeed: CGFloat = 20.0
    
    ///The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1600.
    public var minimumSwipeSpeed: CGFloat = 1600
    
    ///The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2]. Defaults to 0.5.
    public var minimumSwipeMargin: CGFloat = 0.5
    
    ///The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2]. Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10
    
    public init() {}
    
}

