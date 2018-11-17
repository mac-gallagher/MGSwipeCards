//
//  PopAnimator+BasicAnimations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

import pop

extension POPAnimator {
    //MARK: - Basic Animations
    
    static func applyScaleAnimation(to view: UIView?, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear), completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY) {
            scaleAnimation.duration = duration
            scaleAnimation.toValue = toValue
            scaleAnimation.beginTime = CACurrentMediaTime() + delay
            scaleAnimation.timingFunction = timingFunction
            scaleAnimation.completionBlock = completionBlock
            view?.pop_add(scaleAnimation, forKey: POPAnimator.scaleKey)
        }
    }
    
    static func applyTranslationAnimation(to view: UIView?, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear), completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.timingFunction = timingFunction
            translationAnimation.duration = duration
            translationAnimation.toValue = toValue
            translationAnimation.beginTime = CACurrentMediaTime() + delay
            translationAnimation.completionBlock = completionBlock
            view?.layer.pop_add(translationAnimation, forKey: POPAnimator.translationKey)
        }
    }
    
    static func applyRotationAnimation(to view: UIView?, toValue: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear), completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.timingFunction = timingFunction
            rotationAnimation.duration = duration
            rotationAnimation.toValue = toValue
            rotationAnimation.beginTime = CACurrentMediaTime() + delay
            rotationAnimation.completionBlock = completionBlock
            view?.layer.pop_add(rotationAnimation, forKey: POPAnimator.rotationKey)
        }
    }
    
    static func applyFadeAnimation(to view: UIView?, toValue: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear), completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha) {
            alphaAnimation.timingFunction = timingFunction
            alphaAnimation.duration = duration
            alphaAnimation.toValue = toValue
            alphaAnimation.beginTime = CACurrentMediaTime() + delay
            alphaAnimation.completionBlock = { animation, finished in
                completionBlock?(animation, finished)
            }
            view?.pop_add(alphaAnimation, forKey: POPAnimator.fadeKey)
        }
    }
    
    static func applyTransformAnimation(to view: UIView, transform: CGAffineTransform, delay: TimeInterval = 0, duration: TimeInterval, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear), completionBlock: ((POPAnimation?, Bool) ->
        Void)?) {
        applyTranslationAnimation(to: view, toValue: transform.translation(), delay: delay, duration: duration, timingFunction: timingFunction, completionBlock: nil)
        applyRotationAnimation(to: view, toValue: transform.rotationAngle(), delay: delay, duration: duration, timingFunction: timingFunction, completionBlock: nil)
        applyScaleAnimation(to: view, toValue: transform.scaleFactor(), delay: delay, duration: duration, timingFunction: timingFunction, completionBlock: completionBlock)
    }
    
    //MARK: - Spring Animations
    
    static func applySpringTranslationAnimation(to view: UIView?, toValue: CGPoint, springBounciness: CGFloat = 4, springSpeed: CGFloat = 12, delay: TimeInterval = 0, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let resetTranslationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetTranslationAnimation.toValue = toValue
            resetTranslationAnimation.beginTime = CACurrentMediaTime() + delay
            resetTranslationAnimation.springBounciness = springBounciness
            resetTranslationAnimation.springSpeed = springSpeed
            resetTranslationAnimation.completionBlock = completionBlock
            view?.layer.pop_add(resetTranslationAnimation, forKey: POPAnimator.springTranslationKey)
        }
    }
    
    static func applySpringRotationAnimation(to view: UIView?, toValue: CGFloat, springBounciness: CGFloat = 4, springSpeed: CGFloat = 12, delay: TimeInterval = 0, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let rotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.toValue = toValue
            rotationAnimation.beginTime = CACurrentMediaTime() + delay
            rotationAnimation.springBounciness = springBounciness
            rotationAnimation.springSpeed = springSpeed
            rotationAnimation.completionBlock = completionBlock
            view?.layer.pop_add(rotationAnimation, forKey: POPAnimator.springRotationKey)
        }
    }
    
    static func applySpringScaleAnimation(to view: UIView?, toValue: CGPoint, springBounciness: CGFloat = 4, springSpeed: CGFloat = 12, delay: TimeInterval = 0, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY) {
            scaleAnimation.toValue = toValue
            scaleAnimation.beginTime = CACurrentMediaTime() + delay
            scaleAnimation.springBounciness = springBounciness
            scaleAnimation.springSpeed = springSpeed
            scaleAnimation.completionBlock = completionBlock
            view?.pop_add(scaleAnimation, forKey: POPAnimator.springScaleKey)
        }
    }
    
    static func applySpringFadeAnimation(to view: UIView?, toValue: CGPoint, springBounciness: CGFloat = 4, springSpeed: CGFloat = 12, delay: TimeInterval = 0, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let alphaAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            alphaAnimation.toValue = toValue
            alphaAnimation.beginTime = CACurrentMediaTime() + delay
            alphaAnimation.springBounciness = springBounciness
            alphaAnimation.springSpeed = springSpeed
            alphaAnimation.completionBlock = completionBlock
            view?.pop_add(alphaAnimation, forKey: POPAnimator.springFadeKey)
        }
    }
    
    static func applySpringTransformAnimation(to view: UIView, transform: CGAffineTransform, springBounciness: CGFloat = 4, springSpeed: CGFloat = 12, delay: TimeInterval = 0, completionBlock: ((POPAnimation?, Bool) ->
        Void)?) {
        applySpringTranslationAnimation(to: view, toValue: transform.translation(), springBounciness: springBounciness, springSpeed: springSpeed, delay: delay, completionBlock: nil)
        applySpringRotationAnimation(to: view, toValue: transform.rotationAngle(), springBounciness: springBounciness, springSpeed: springSpeed, delay: delay, completionBlock: nil)
        applySpringScaleAnimation(to: view, toValue: transform.scaleFactor(), springBounciness: springBounciness, springSpeed: springSpeed, delay: delay, completionBlock: completionBlock)
    }
}

extension POPAnimator {
    static var scaleKey = "POPScaleAnimation"
    static var translationKey = "POPTranslationAnimation"
    static var rotationKey = "POPRotationAnimation"
    static var fadeKey = "POPAlphaAnimation"
    static var springTranslationKey = "springTranslationAnimation"
    static var springRotationKey = "springRotationAnimation"
    static var springFadeKey = "springFadeAnimation"
    static var springScaleKey = "springScaleAnimation"
}
