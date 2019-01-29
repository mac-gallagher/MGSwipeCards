//
//  CardAnimationOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

public class CardAnimationOptions: NSObject {
    public static let defaultOptions = CardAnimationOptions()
    
    /// The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2].
    /// Defaults to `CGFloat.pi`/10.
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10 {
        didSet {
            maximumRotationAngle = max(-CGFloat.pi / 2, min(maximumRotationAngle, CGFloat.pi / 2))
        }
    }
    
    /// The duration of the animated swipe translation. Measured in seconds. Defaults to 0.6.
    public var cardSwipeAnimationDuration: TimeInterval = 0.6
    
    /// The duration of the fade animation applied to the overlays before the animated swipe translation,
    /// and after the reverse swipe translation. Measured in seconds. Defaults to 0.1.
    public var overlayFadeAnimationDuration: TimeInterval = 0.1
    
    /// The duration of the animated reverse swipe translation. Measured in seconds. Defaults to 0.1.
    public var reverseSwipeAnimationDuration: TimeInterval = 0.1
    
    /// The duration of the spring-like animation applied when a swipe is canceled. Measured in seconds. Defaults to 0.6
    public var resetAnimationSpringDuration: TimeInterval = 0.6
    
    /// The damping coefficient of the spring-like animation applied when a swipe is canceled.
    /// Measured as a value between 0 and 1. Defaults to 0.4
    public var resetAnimationSpringDamping: CGFloat = 0.4
}
