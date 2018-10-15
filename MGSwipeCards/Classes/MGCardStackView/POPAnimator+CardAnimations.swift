//
//  PopAnimation+CardAnimations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 10/13/18.
//

import pop

extension POPAnimator {
    
    static func applyScaleAnimation(to view: UIView, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY) {
            scaleAnimation.duration = duration + 0.0001
            scaleAnimation.toValue = toValue
            scaleAnimation.beginTime = CACurrentMediaTime() + delay
            scaleAnimation.completionBlock = completionBlock
            view.pop_add(scaleAnimation, forKey: POPAnimator.scaleKey)
        }
    }
    
    static func applyTranslationAnimation(to view: UIView, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration + 0.0001
            translationAnimation.toValue = toValue
            translationAnimation.beginTime = CACurrentMediaTime() + delay
            translationAnimation.completionBlock = completionBlock
            view.layer.pop_add(translationAnimation, forKey: POPAnimator.translationKey)
        }
    }
    
    static func applyRotationAnimation(to view: UIView, toValue: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration + 0.0001
            rotationAnimation.toValue = toValue
            rotationAnimation.beginTime = CACurrentMediaTime() + delay
            rotationAnimation.completionBlock = completionBlock
            view.layer.pop_add(rotationAnimation, forKey: POPAnimator.rotationKey)
        }
    }
    
    static func applyTransformAnimation(to view: UIView, toValue transform: CGAffineTransform, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) ->
        Void)?) {
        applyTranslationAnimation(to: view, toValue: transform.translation(), delay: delay, duration: duration, completionBlock: nil)
        applyRotationAnimation(to: view, toValue: transform.rotationAngle(), delay: delay, duration: duration, completionBlock: nil)
        applyScaleAnimation(to: view, toValue: transform.scaleFactor(), delay: delay, duration: duration, completionBlock: completionBlock)
    }
    
    static func applyAlphaAnimation(to view: UIView?, toValue: CGFloat, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha) {
            alphaAnimation.duration = duration + 0.0001
            alphaAnimation.toValue = toValue
            alphaAnimation.completionBlock = { animation, finished in
                completionBlock?(animation, finished)
            }
            view?.pop_add(alphaAnimation, forKey: POPAnimator.alphaKey)
        }
    }
}

//MARK: Animation Keys

extension POPAnimator {
    public static var scaleKey = "POPScaleAnimation"
    public static var translationKey = "POPTranslationAnimation"
    public static var rotationKey = "POPRotationAnimation"
    public static var alphaKey = "POPAlphaAnimation"
    
    public static var customAnimationKeys = [
        scaleKey,
        translationKey,
        rotationKey,
        alphaKey
    ]
}
