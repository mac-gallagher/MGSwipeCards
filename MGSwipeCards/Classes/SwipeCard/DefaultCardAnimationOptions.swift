//
//  CardAnimationOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

public protocol CardAnimatonOptions {
    /// The maximum rotation angle of the card. Measured in radians.
    var maximumRotationAngle: CGFloat { get set }
}

/// The animation option set corresponding to the `DefaultCardAnimator`.
public class DefaultCardAnimationOptions: NSObject, CardAnimatonOptions {
    
    /// The static shared instance of `DefaultCardAnimationOptions`.
    static let shared: DefaultCardAnimationOptions = DefaultCardAnimationOptions()
    
    /// The maximum rotation angle of the card, measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2].
    /// Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10 {
        didSet {
            maximumRotationAngle = max(-CGFloat.pi / 2, min(maximumRotationAngle, CGFloat.pi / 2))
        }
    }
    
    /// The total duration of the animated swipe, measured in seconds. Defaults to 0.7. Must be greater than zero.
    public var totalSwipeDuration: TimeInterval = 0.7
    
    /// The total duration of the animated reverse swipe, measured in seconds. Defaults to 0.2. Must be greater than zero.
    public var totalReverseSwipeDuration: TimeInterval = 0.2
    
    /// The duration of the spring-like animation applied when a swipe is canceled. Measured in seconds. Defaults to 0.6. Must be greater than zero.
    public var totalResetDuration: TimeInterval = 0.6
    
    /// The duration of the fade animation applied to the overlays before the swipe translation. Relative to the total swipe duration.
    public var relativeSwipeOverlayFadeDuration: TimeInterval = 0.15
    
    /// The duration of the fade animation applied to the overlays after the reverse swipe translation. Relative to the total reverse swipe duration.
    public var relativeReverseSwipeOverlayFadeDuration: TimeInterval = 0.15
    
    /// The damping coefficient of the spring-like animation applied when a swipe is canceled.
    /// Defined as a value in the range [0, 1]. Defaults to 0.4
    public var resetSpringDamping: CGFloat = 0.4
}
