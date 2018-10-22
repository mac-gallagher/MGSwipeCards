//
//  PopAnimation+CardAnimations.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 10/13/18.
//

import pop

//MARK: - Card Animations

fileprivate enum CardAnimationState {
    case resetting, swiping, undoing
}

extension POPAnimator {
    
    fileprivate static var cardAnimations = [MGSwipeCard: CardAnimationState]()
    
    static func applySwipeAnimation(to card: MGSwipeCard, direction: SwipeDirection, duration: TimeInterval, overlayFadeDuration: TimeInterval, forced: Bool = false, completion: ((Bool) -> Void)?) {
        POPAnimator.removeAllCardAnimations(on: card)
        POPAnimator.cardAnimations[card] = .swiping
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        let overlayDuration = forced ? overlayFadeDuration : 0
        let rotation = rotationForSwipe(card, direction: direction)
        let dragTranslation = forced ? direction.point : card.panGestureRecognizer.translation(in: card.superview)
        let translation = translationPoint(card, direction: direction, dragTranslation: dragTranslation)
        
        applyOverlayAnimations(to: card, showDirection: direction, duration: overlayDuration) { (_, finished) in
            if finished {
                POPAnimator.applyRotationAnimation(to: card, toValue: rotation, duration: duration, completionBlock: nil)
                POPAnimator.applyTranslationAnimation(to: card, toValue: translation, duration: duration) { _, finished in
                    if finished {
                        POPAnimator.cardAnimations.removeValue(forKey: card)
                        card.layer.shouldRasterize = false
                    }
                    completion?(finished)
                }
            }
        }
    }
    
    private static var cardResetTranslationKey = "cardResetTranslation"
    private static var cardResetRotationKey = "cardResetRotation"
    private static var cardResetOverlayAlphaKey = "cardResetOverlayAlpha"
    
    static func applyResetAnimation(to card: MGSwipeCard, springBounciness: CGFloat, springSpeed: CGFloat, completion: ((Bool) -> Void)?) {
        POPAnimator.removeAllCardAnimations(on: card)
        POPAnimator.cardAnimations[card] = .resetting
        
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        if let resetTranslationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetTranslationAnimation.toValue = CGPoint.zero
            resetTranslationAnimation.springBounciness = springBounciness
            resetTranslationAnimation.springSpeed = springSpeed
            resetTranslationAnimation.completionBlock = { _, finished in
                if finished {
                    POPAnimator.cardAnimations.removeValue(forKey: card)
                    card.layer.shouldRasterize = false
                }
                completion?(finished)
            }
            card.layer.pop_add(resetTranslationAnimation, forKey: POPAnimator.cardResetTranslationKey)
        }
        
        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = springBounciness
            resetRotationAnimation.springSpeed = springSpeed
            card.layer.pop_add(resetRotationAnimation, forKey: POPAnimator.cardResetRotationKey)
        }
        
        card.swipeDirections.forEach { direction in
            if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
                resetOverlayAnimation.toValue = 0
                resetOverlayAnimation.springBounciness = springBounciness
                resetOverlayAnimation.springSpeed = springSpeed
                card.overlay(forDirection: direction)?.pop_add(resetOverlayAnimation, forKey: POPAnimator.cardResetOverlayAlphaKey)
            }
        }
    }
    
    static func applyUndoAnimation(to card: MGSwipeCard, from direction: SwipeDirection, duration: TimeInterval, overlayFadeDuration: TimeInterval, completion: ((Bool) -> Void)?) {
        POPAnimator.removeAllCardAnimations(on: card)
        POPAnimator.cardAnimations[card] = .undoing
        
        //recreate previous swipe transform
        card.transform = CGAffineTransform.identity
        card.transform.tx = POPAnimator.translationPoint(card, direction: direction, dragTranslation: direction.point).x
        card.transform.ty = POPAnimator.translationPoint(card, direction: direction, dragTranslation: direction.point).y
        if direction == .left {
            card.transform = card.transform.rotated(by: -2 * card.maximumRotationAngle)
        } else if direction == .right {
            card.transform = card.transform.rotated(by: 2 * card.maximumRotationAngle)
        }
        POPAnimator.applyOverlayAnimations(to: card, showDirection: direction, duration: 0, completionBlock: nil)
        
        POPAnimator.applyRotationAnimation(to: card, toValue: 0, duration: duration, completionBlock: nil)
        POPAnimator.applyTranslationAnimation(to: card, toValue: .zero, duration: duration) { _, finished in
            if finished {
                POPAnimator.cardAnimations.removeValue(forKey: card)
                card.layer.shouldRasterize = false
                POPAnimator.applyOverlayAnimations(to: card, showDirection: nil, duration: overlayFadeDuration, completionBlock: { _, finished in
                    completion?(finished)
                })
            }
        }
    }
    
    //TODO: Does not exactly match user's swipe speed. Becomes more accurate the smaller card.options.maximumSwipeDuration is
    private static func translationPoint(_ card: MGSwipeCard, direction: SwipeDirection, dragTranslation: CGPoint) -> CGPoint {
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: card.bounds.width, y: card.bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let maxLength = max(abs(dragTranslation.x), abs(dragTranslation.y))
        let directionVector = CGPoint(x: dragTranslation.x / maxLength, y: dragTranslation.y / maxLength)
        let velocityFactor = max(1, card.swipeSpeed(on: direction) / card.minimumSwipeSpeed)
        return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
    }
    
    private static func rotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        if direction == .up || direction == .down { return 0 }
        let location = card.panGestureRecognizer.location(in: card)
        
        if (direction == .left && location.y < card.bounds.height / 2) || (direction == .right && location.y >= card.bounds.height / 2) {
            return -2 * card.maximumRotationAngle
        }
        return 2 * card.maximumRotationAngle
    }
    
    private static func randomRotationForSwipe(_ card: MGSwipeCard, direction: SwipeDirection) -> CGFloat {
        switch direction {
        case .up, .down: return 0
        case .left, .right: return Array([-1,1])[Int(arc4random_uniform(UInt32(2)))] * (2 * card.maximumRotationAngle)
        }
    }
    
    //TODO: Clean this up
    private static func applyOverlayAnimations(to card: MGSwipeCard, showDirection: SwipeDirection?, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        var overlays = [UIView]()
        for direction in card.swipeDirections {
            if let overlay = card.overlay(forDirection: direction) {
                overlays.append(overlay)
            }
        }
        
        if overlays.isEmpty {
            completionBlock?(nil, true)
        } else {
            var completionCalled = false
            for direction in card.swipeDirections {
                let alpha: CGFloat = direction == showDirection ? 1 : 0
                let overlay = card.overlay(forDirection: direction)
                POPAnimator.applyAlphaAnimation(to: overlay, toValue: alpha, duration: duration) { (animation, finished) in
                    if !completionCalled {
                        completionBlock?(animation, finished)
                        completionCalled = true
                    }
                }
            }
        }
    }
    
    static func removeAllCardAnimations(on card: MGSwipeCard) {
        card.layer.pop_removeAllAnimations()
        card.pop_removeAllAnimations()
        POPAnimator.cardAnimations.removeValue(forKey: card)
    }
}

//MARK: - Card Animation State Getters

extension MGSwipeCard {

    var isSwipeAnimating: Bool {
        return POPAnimator.cardAnimations[self] == .swiping ? true : false
    }
    
    var isResetAnimating: Bool {
        return POPAnimator.cardAnimations[self] == .resetting ? true : false
    }
    
    var isUndoAnimating: Bool {
        return POPAnimator.cardAnimations[self] == .undoing ? true : false
    }
    
    var isAnimating: Bool {
        return isSwipeAnimating || isResetAnimating || isUndoAnimating
    }
}

//MARK: - Basic View Animations

extension POPAnimator {
    
    private static var scaleKey = "POPScaleAnimation"
    
    static func applyScaleAnimation(to view: UIView, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY) {
            scaleAnimation.duration = duration + 0.0001
            scaleAnimation.toValue = toValue
            scaleAnimation.beginTime = CACurrentMediaTime() + delay
            scaleAnimation.completionBlock = completionBlock
            view.pop_add(scaleAnimation, forKey: POPAnimator.scaleKey)
        }
    }
    
    private static var translationKey = "POPTranslationAnimation"
    
    static func applyTranslationAnimation(to view: UIView, toValue: CGPoint, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration + 0.0001
            translationAnimation.toValue = toValue
            translationAnimation.beginTime = CACurrentMediaTime() + delay
            translationAnimation.completionBlock = completionBlock
            view.layer.pop_add(translationAnimation, forKey: POPAnimator.translationKey)
        }
    }
    
    private static var rotationKey = "POPRotationAnimation"
    
    static func applyRotationAnimation(to view: UIView, toValue: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) -> Void)?) {
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration = duration + 0.0001
            rotationAnimation.toValue = toValue
            rotationAnimation.beginTime = CACurrentMediaTime() + delay
            rotationAnimation.completionBlock = completionBlock
            view.layer.pop_add(rotationAnimation, forKey: POPAnimator.rotationKey)
        }
    }
    
    private static var alphaKey = "POPAlphaAnimation"
    
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
    
    static func applyTransformAnimation(to view: UIView, toValue transform: CGAffineTransform, delay: TimeInterval = 0, duration: TimeInterval, completionBlock: ((POPAnimation?, Bool) ->
        Void)?) {
        applyTranslationAnimation(to: view, toValue: transform.translation(), delay: delay, duration: duration, completionBlock: nil)
        applyRotationAnimation(to: view, toValue: transform.rotationAngle(), delay: delay, duration: duration, completionBlock: nil)
        applyScaleAnimation(to: view, toValue: transform.scaleFactor(), delay: delay, duration: duration, completionBlock: completionBlock)
    }
}
