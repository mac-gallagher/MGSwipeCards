//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import pop

open class MGSwipeCard: MGSwipeView {
    
    open var delegate: MGSwipeCardDelegate?
    
    open var imageView: UIImageView? {
        didSet {
            imageView?.contentMode = .scaleAspectFill
        }
    }
    
    open var footerView: UIView?
    
    open override var backgroundColor: UIColor? {
        didSet {
            backgroundContainer.backgroundColor = backgroundColor
            super.backgroundColor = .clear
        }
    }
    
    override open var layer: CALayer {
        return backgroundContainer.layer
    }
    
    public var animationLayer: CALayer {
        return super.layer
    }
    
    private let backgroundContainer: UIView = {
        let container = UIView()
        container.isUserInteractionEnabled = false
        container.layer.masksToBounds = true
        return container
    }()
    
    private var overlayContainer: UIView?
    
    private var overlays: [SwipeDirection: UIView?] = [:]
    
    //MARK: - Swipe Recognition Settings
    
    public var minimumSwipeSpeed: CGFloat = 1600 //in points per second
    
    public var minimumSwipeMargin: CGFloat = 0.5 //values defined in [0,2]
    
    //MARK: - Swipe Animation Settings
    
    public var maximumRotationAngle: CGFloat = CGFloat.pi / 10
    
    public var swipeAnimationMinimumDuration: TimeInterval = 0.8 
    
    public var resetAnimationSpringBounciness: CGFloat = 12.0
    
    public var resetAnimationSpringSpeed: CGFloat = 20.0
    
    public override init() {
        super.init()
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        super.addSubview(backgroundContainer)
        backgroundColor = .black
    }
    
    open override func addSubview(_ view: UIView) {
        backgroundContainer.addSubview(view)
        if let overlayContainer = overlayContainer {
            backgroundContainer.bringSubview(toFront: overlayContainer)
        }
        if let imageView = imageView {
            backgroundContainer.sendSubview(toBack: imageView)
        }
    }
    
    open override func insertSubview(_ view: UIView, at index: Int) {
        backgroundContainer.insertSubview(view, at: index)
        if let overlayContainer = overlayContainer {
            backgroundContainer.bringSubview(toFront: overlayContainer)
        }
        if let imageView = imageView {
            backgroundContainer.sendSubview(toBack: imageView)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        backgroundContainer.frame = bounds
        
        if let footer = footerView {
            footer.frame = CGRect(x: 0, y: bounds.height - footer.bounds.height, width: bounds.width, height: footer.bounds.height)
            overlayContainer?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - footer.bounds.height)
            if footer.backgroundColor == .clear || footer.backgroundColor == nil {
                imageView?.frame = bounds
            } else {
                imageView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - footer.bounds.height)
            }
        } else {
            imageView?.frame = bounds
            overlayContainer?.frame = bounds
        }

        for overlay in overlays.values {
            overlay?.frame = overlayContainer?.bounds ?? CGRect.zero
        }
    }
    
    //MARK: Customization Methods
    
    public func setOverlay(forDirection direction: SwipeDirection, overlay: UIView?) {
        guard let overlay = overlay else { return }
        if overlayContainer == nil {
            overlayContainer?.removeFromSuperview()
            overlayContainer = UIView()
            addSubview(overlayContainer!)
        }
        overlays[direction]??.removeFromSuperview()
        overlayContainer?.addSubview(overlay)
        overlays[direction] = overlay
        overlays[direction]??.alpha = 0
    }
    
    public func setBackgroundImage(_ image: UIImage?) {
        if imageView == nil {
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            addSubview(imageView!)
        }
        imageView?.image = image
    }
    
    public func setFooterView(_ footer: UIView?, withHeight height: CGFloat) {
        if footerView == nil {
            footerView?.removeFromSuperview()
            footerView = footer
            footerView?.bounds = CGRect(x: 0, y: 0, width: 0, height: height)
            addSubview(footerView!)
        }
    }

    public func setShadow(radius: CGFloat, opacity: Float, offset: CGSize = .zero, color: UIColor = UIColor.black) {
        animationLayer.shadowRadius = radius
        animationLayer.shadowOpacity = opacity
        animationLayer.shadowOffset = offset
        animationLayer.shadowColor = color.cgColor
    }
    
    //MARK: - Swiping Methods
    
    private var rotationDirectionY: CGFloat = 1
    
    open override func beginSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        removeAllAnimations()
        animationLayer.rasterizationScale = UIScreen.main.scale
        animationLayer.shouldRasterize = true
        let touchPoint = recognizer.location(in: self)
        setAnchor(to: CGPoint(x: touchPoint.x / bounds.width, y: touchPoint.y / bounds.height))
        if touchPoint.y < bounds.height / 2 {
            rotationDirectionY = 1
        } else {
            rotationDirectionY = -1
        }
        delegate?.beginSwiping(on: self)
    }

    private func setAnchor(to anchorPoint: CGPoint) {
        animationLayer.anchorPoint = anchorPoint
        animationLayer.position = CGPoint(x: bounds.size.width * anchorPoint.x, y: bounds.size.height * anchorPoint.y)
    }
    
    private func alphaForOverlay(withDirection direction: SwipeDirection) -> CGFloat {
        if direction != activeDirection { return 0 }
        let totalPercentage = swipeDirections.reduce(0) { (percentage, direction) in
            return percentage + swipePercentage(onDirection: direction)
        }
        return min((2 * swipePercentage(onDirection: direction) - totalPercentage)/minimumSwipeMargin, 1)
    }
    
    open override func continueSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        
        let superviewTranslation = recognizer.translation(in: superview)
        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        let rotationAngle = max(-CGFloat.pi/2, min(rotationDirectionY * abs(maximumRotationAngle) * rotationStrength, CGFloat.pi/2))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        
        animationLayer.setAffineTransform(transform)
        
        for direction in swipeDirections {
            overlays[direction]??.alpha = alphaForOverlay(withDirection: direction)
        }
        delegate?.continueSwiping(on: self)
    }

    open override func endSwiping(on view: MGSwipeView, recognizer: UIPanGestureRecognizer) {
        guard let direction = activeDirection else { return }
        if swipeSpeed(onDirection: direction) >= minimumSwipeSpeed {
            swipeOffScreenAnimation(didSwipeFast: true)
            delegate?.didSwipe(on: self, withDirection: direction)
        } else if swipePercentage(onDirection: direction) >= minimumSwipeMargin {
            swipeOffScreenAnimation(didSwipeFast: false)
            delegate?.didSwipe(on: self, withDirection: direction)
        } else {
            resetCardAnimation()
            delegate?.didCancelSwipe(on: self)
        }
    }
    
}

//MARK: - Animation Methods

private extension MGSwipeCard {
    
    func swipeOffScreenAnimation(didSwipeFast: Bool) {
        removeAllAnimations()
        isUserInteractionEnabled = false
        guard let direction = activeDirection else { return }
        overlays[direction]??.alpha = 1
        
        //reset anchor to center of card?
        
        let duration = swipeAnimationMinimumDuration
        if let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY) {
            translationAnimation.duration = duration
            translationAnimation.toValue = translationForSwipeAnimation(didSwipeFast: didSwipeFast)
            translationAnimation.completionBlock = { (_, _) in
                self.removeFromSuperview()
            }
            animationLayer.pop_add(translationAnimation, forKey: "swipeTranslationAnimation")
        }
        
        if let rotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation) {
            rotationAnimation.duration =  duration
            rotationAnimation.toValue = 2 * rotationForSwipeAnimation * maximumRotationAngle
            animationLayer.pop_add(rotationAnimation, forKey: "swipeRotationAnimation")
        }
    }
    
    var rotationForSwipeAnimation: CGFloat {
        if activeDirection == SwipeDirection.up || activeDirection == SwipeDirection.down {
            return 0
        }
        let location = panGestureRecognizer.location(in: self)
        if (activeDirection == .left && location.y < bounds.height / 2) || (activeDirection == .right && location.y >= bounds.height / 2) {
            return -1
        }
        return 1
    }
    
    func translationForSwipeAnimation(didSwipeFast: Bool) -> CGPoint {
        guard let superview = superview else { return CGPoint.zero }
        let cardDiagonalLength = CGPoint.zero.distance(to: CGPoint(x: bounds.width, y: bounds.height))
        let minimumOffscreenTranslation = CGPoint(x: UIScreen.main.bounds.width + cardDiagonalLength, y: UIScreen.main.bounds.height + cardDiagonalLength)
        let translation = panGestureRecognizer.translation(in: superview)
        let maxLength = max(abs(translation.x), abs(translation.y))
        let directionVector = CGPoint(x: translation.x / maxLength, y: translation.y / maxLength)
        if didSwipeFast {
            let velocityFactor = panGestureRecognizer.velocity(in: superview).norm / minimumSwipeSpeed
            return CGPoint(x: velocityFactor * directionVector.x * minimumOffscreenTranslation.x, y: velocityFactor * directionVector.y * minimumOffscreenTranslation.y)
        }
        return CGPoint(x: directionVector.x * minimumOffscreenTranslation.x, y: directionVector.y * minimumOffscreenTranslation.y)
    }
    
    func resetCardAnimation() {
        removeAllAnimations()
        
        if let resetPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY) {
            resetPositionAnimation.toValue = CGPoint.zero
            resetPositionAnimation.springBounciness = resetAnimationSpringBounciness
            resetPositionAnimation.springSpeed = resetAnimationSpringSpeed
            resetPositionAnimation.completionBlock = { _, _ in
                self.animationLayer.transform = CATransform3DIdentity
                self.animationLayer.shouldRasterize = false
            }
            animationLayer.pop_add(resetPositionAnimation, forKey: "resetPositionAnimation")
        }
        
        if let resetRotationAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation) {
            resetRotationAnimation.toValue = 0
            resetRotationAnimation.springBounciness = resetAnimationSpringBounciness
            resetRotationAnimation.springSpeed = resetAnimationSpringSpeed
            animationLayer.pop_add(resetRotationAnimation, forKey: "resetRotationAnimation")
        }
        
        guard let direction = activeDirection else { return }
        if let resetOverlayAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha) {
            resetOverlayAnimation.toValue = 0
            resetOverlayAnimation.springBounciness = resetAnimationSpringBounciness
            resetOverlayAnimation.springSpeed = resetAnimationSpringSpeed
            overlays[direction]??.pop_add(resetOverlayAnimation, forKey: "resetAlphaAnimation")
        }
    }
    
    func removeAllAnimations() {
        animationLayer.pop_removeAllAnimations()
        for overlay in overlays.values {
            overlay?.pop_removeAllAnimations()
        }
    }
}


