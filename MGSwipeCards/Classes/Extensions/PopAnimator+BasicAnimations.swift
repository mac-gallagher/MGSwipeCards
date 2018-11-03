//
//  PopAnimator+BasicAnimations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

import pop

extension POPAnimator {
    
    private static var scaleKey = "POPScaleAnimation"
    
    static func applyScaleAnimation(to view: UIView?, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY) {
            scaleAnimation.duration = duration
            scaleAnimation.toValue = toValue
            scaleAnimation.beginTime = CACurrentMediaTime() + delay
            scaleAnimation.completionBlock = completionBlock
            view?.pop_add(scaleAnimation, forKey: POPAnimator.scaleKey)
        }
    }
    
    private static var translationKey = "POPTranslationAnimation"
    
    static func applyTranslationAnimation(to view: UIView?, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.toValue = toValue
            translationAnimation.beginTime = CACurrentMediaTime() + delay
            translationAnimation.completionBlock = completionBlock
            view?.layer.pop_add(translationAnimation, forKey: POPAnimator.translationKey)
        }
    }
    
    private static var rotationKey = "POPRotationAnimation"
    
    static func applyRotationAnimation(to view: UIView?, toValue: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration
            rotationAnimation.toValue = toValue
            rotationAnimation.beginTime = CACurrentMediaTime() + delay
            rotationAnimation.completionBlock = completionBlock
            view?.layer.pop_add(rotationAnimation, forKey: POPAnimator.rotationKey)
        }
    }
    
    private static var fadeKey = "POPAlphaAnimation"
    
    static func applyFadeAnimation(to view: UIView?, toValue: CGFloat, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha) {
            alphaAnimation.duration = duration
            alphaAnimation.toValue = toValue
            alphaAnimation.completionBlock = { animation, finished in
                completionBlock?(animation, finished)
            }
            view?.pop_add(alphaAnimation, forKey: POPAnimator.fadeKey)
        }
    }
    
    static func applyTransformAnimation(to view: UIView, transform: CGAffineTransform, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) ->
        Void)?) {
        applyTranslationAnimation(to: view, toValue: transform.translation(), delay: delay, duration: duration, completionBlock: nil)
        applyRotationAnimation(to: view, toValue: transform.rotationAngle(), delay: delay, duration: duration, completionBlock: nil)
        applyScaleAnimation(to: view, toValue: transform.scaleFactor(), delay: delay, duration: duration, completionBlock: completionBlock)
    }
}
