//
//  CardAnimationOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

public protocol CardAnimatonOptions {
    var maximumRotationAngle: CGFloat { get set }
    var totalSwipeDuration: TimeInterval { get set }
    var totalReverseSwipeDuration: TimeInterval { get set }
    var totalResetDuration: TimeInterval { get set }
}

public class MGCardAnimationOptions: NSObject, CardAnimatonOptions {
    public static let defaultOptions = MGCardAnimationOptions()
    
    /// The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2].
    /// Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10 {
        didSet {
            maximumRotationAngle = max(-CGFloat.pi / 2, min(maximumRotationAngle, CGFloat.pi / 2))
        }
    }
    
    /// The duration of the animated swipe. Measured in seconds. Defaults to 0.7. Must be greater than zero
    public var totalSwipeDuration: TimeInterval = 0.7
    
    /// The duration of the animated reverse swipe. Measured in seconds. Defaults to 0.2. Must be greater than zero
    public var totalReverseSwipeDuration: TimeInterval = 0.2
    
    /// The duration of the spring-like animation applied when a swipe is canceled. Measured in seconds. Defaults to 0.6.
    public var totalResetDuration: TimeInterval = 0.6
    
    /// The duration of the fade animation applied to the overlays before the animated swipe translation,
    /// and after the reverse swipe translation. Relative to the total swipe duration
    public var relativeSwipeOverlayFadeDuration: TimeInterval = 0.15
    
    public var relativeReverseSwipeOverlayFadeDuration: TimeInterval = 0.15
    
    /// The damping coefficient of the spring-like animation applied when a swipe is canceled.
    /// Measured as a value between 0 and 1. Defaults to 0.4
    public var resetSpringDamping: CGFloat = 0.4
}
