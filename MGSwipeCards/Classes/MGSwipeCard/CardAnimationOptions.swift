//
//  CardOptions.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

public class CardAnimationOptions: NSObject {
    public static var defaultOptions = CardAnimationOptions()
    
    /// The duration of the animated swipe translation. Measured in seconds. Defaults to 0.6.
    public var cardSwipeAnimationDuration: TimeInterval = 0.6
    
    /// The duration of the fade animation applied to the overlays before the animated swipe translation, and after the reverse swipe translation. Measured in seconds. Defaults to 0.1.
    public var overlayFadeAnimationDuration: TimeInterval = 0.1
    
    /// The duration of the animated reverse swipe translation. Measured in seconds. Defaults to 0.1.
    public var reverseSwipeAnimationDuration: TimeInterval = 0.1
    
    ///The effective bounciness of the spring animation upon a cancelled swipe. Higher values increase spring movement range resulting in more oscillations and springiness. Defined as a value in the range [0, 20]. Defaults to 12.
    public var resetAnimationSpringBounciness: CGFloat = 12.0
    
    /// The effective speed of the spring animation upon a cancelled swipe. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20]. Defaults to 20.
    public var resetAnimationSpringSpeed: CGFloat = 20.0
}
