//
//  PopAnimation+CardAnimations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 10/13/18.
//

import pop

extension POPAnimation {
    
    static func applyScaleAnimation(to view: UIView, scaleFactor: CGFloat, beginTime: CFTimeInterval = 0, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if duration == 0 {
            view.transform = view.transform.scaledBy(x: scaleFactor, y: scaleFactor)
            completionBlock?(nil, true)
            return
        }
        if view.transform == CGAffineTransform.identity && scaleFactor == 1 {
            completionBlock?(nil, true)
            return
        }
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY) {
            scaleAnimation.duration = duration
            scaleAnimation.toValue = CGSize(width: scaleFactor, height: scaleFactor)
            scaleAnimation.beginTime = beginTime
            scaleAnimation.completionBlock = completionBlock
            view.pop_add(scaleAnimation, forKey: POPAnimation.scaleKey)
        }
    }
    
    static func applyTranslationAnimation(to view: UIView, translation: CGPoint, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if duration == 0 {
            view.transform = view.transform.translatedBy(x: translation.x, y: translation.y)
            completionBlock?(nil, true)
            return
        }
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.toValue = translation
            translationAnimation.completionBlock = completionBlock
            view.layer.pop_add(translationAnimation, forKey: POPAnimation.translationKey)
        }
    }
    
    static func applyRotationAnimation(to view: UIView, rotationAngle: CGFloat, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if duration == 0 {
            view.transform = view.transform.rotated(by: rotationAngle)
            completionBlock?(nil, true)
            return
        }
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration
            rotationAnimation.toValue = rotationAngle
            rotationAnimation.completionBlock = completionBlock
            view.layer.pop_add(rotationAnimation, forKey: POPAnimation.rotationKey)
        }
    }
    
    static func applyAlphaAnimation(to view: UIView?, alpha: CGFloat, duration: CFTimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if duration == 0 || view == nil {
            view?.alpha = alpha
            completionBlock?(nil, true)
            return
        }
        if let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha) {
            alphaAnimation.duration = duration
            alphaAnimation.toValue = alpha
            alphaAnimation.completionBlock = { animation, finished in
                completionBlock?(animation, finished)
            }
            view?.pop_add(alphaAnimation, forKey: POPAnimation.overlayAlphaKey)
        }
    }
}

extension POPAnimation {
    public static var scaleKey = "scaleAnimation"
    public static var translationKey = "translationAnimation"
    public static var rotationKey = "rotationAnimation"
    public static var overlayAlphaKey = "overlayAlphaAnimation"
    
    public static var viewAnimationKeys = [
        scaleKey,
        translationKey,
        rotationKey,
        overlayAlphaKey
    ]
}
