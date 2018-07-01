//
//  MGSwipeCard.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class MGSwipeCard: MGSwipeView {
    
    //MARK: - Variables
    
    public var delegate: MGSwipeCardDelegate?
    
    public var imageView: UIImageView?
    
    public var footerView: UIView?
    
    public var footerHeight: CGFloat = 80
    
    open override var backgroundColor: UIColor? {
        didSet {
            backgroundView.backgroundColor = backgroundColor
            super.backgroundColor = .clear
        }
    }
    
    override open var layer: CALayer {
        return backgroundView.layer
    }
    
    var animationLayer: CALayer {
        return super.layer
    }
    
    private let backgroundView: UIView = {
        let background = UIView()
        background.isUserInteractionEnabled = false
        background.layer.masksToBounds = true
        return background
    }()
    
    private var overlayContainer: UIView?
    
    var overlays: [SwipeDirection: UIView?] = [:]
    
    //MARK: Swipe Recognition Settings
    
    open var minimumSwipeSpeed: CGFloat = 1600 //in points per second
    
    open var minimumSwipeMargin: CGFloat = 0.5 //values defined in [0,2]
    
    //MARK: Swipe Animation Settings
    
    open var maximumRotationAngle: CGFloat = CGFloat.pi / 10
    
    open var swipeAnimationMinimumDuration: TimeInterval = 0.8
    
    open var resetAnimationSpringBounciness: CGFloat = 12.0
    
    open var resetAnimationSpringSpeed: CGFloat = 20.0
    
    //MARK: - Initialization
    
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
        super.addSubview(backgroundView)
        _ = backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        backgroundColor = .black
    }
    
    //MARK: - Layout
    
    private var footerViewConstraints: [NSLayoutConstraint] = []
    
    private var imageViewConstraints: [NSLayoutConstraint] = []
    
    private var overlayContainerConstraints: [NSLayoutConstraint] = []
    
    private var overlayConstraintsForDirection: [SwipeDirection: [NSLayoutConstraint]] = [:]
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutFooterView()
        layoutImageView()
        layoutOverlays()
    }
    
    private func layoutFooterView() {
        guard let footer = footerView else { return }
        NSLayoutConstraint.deactivate(footerViewConstraints)
        footerViewConstraints = footer.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: footerHeight)
    }
    
    private func layoutImageView() {
        guard let imageView = imageView else { return }
        NSLayoutConstraint.deactivate(imageViewConstraints)
        if footerView == nil || footerView?.backgroundColor == .clear || footerView?.backgroundColor == nil {
            imageViewConstraints = imageView.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor)
        } else {
            imageViewConstraints = imageView.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: footerView!.bottomAnchor, right: backgroundView.rightAnchor)
        }
    }
    
    private func layoutOverlays() {
        guard let overlayContainer = overlayContainer else { return }
        NSLayoutConstraint.deactivate(overlayContainerConstraints)
        overlayContainerConstraints = overlayContainer.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, right: backgroundView.rightAnchor)
        if footerView == nil {
            overlayContainerConstraints = overlayContainer.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor)
        } else {
            overlayContainerConstraints = overlayContainer.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: footerView!.topAnchor, right: backgroundView.rightAnchor)
        }
        
        for direction in swipeDirections {
            if let overlayConstraints = overlayConstraintsForDirection[direction] {
                NSLayoutConstraint.deactivate(overlayConstraints)
            }
            overlayConstraintsForDirection[direction] = overlays[direction]??.anchor(top: overlayContainer.topAnchor, left: overlayContainer.leftAnchor, bottom: overlayContainer.bottomAnchor, right: overlayContainer.rightAnchor)
        }
    }
    
    open override func addSubview(_ view: UIView) {
        backgroundView.addSubview(view)
        updateViewHierarchy()
    }
    
    open override func insertSubview(_ view: UIView, at index: Int) {
        backgroundView.insertSubview(view, at: index)
        updateViewHierarchy()
    }
    
    private func updateViewHierarchy() {
        if let overlayContainer = overlayContainer {
            backgroundView.bringSubview(toFront: overlayContainer)
        }
        if let imageView = imageView {
            backgroundView.sendSubview(toBack: imageView)
        }
    }
    
    //MARK: - Setters/Getters
    
    public func setOverlay(forDirection direction: SwipeDirection, overlay: UIView?) {
        guard let overlay = overlay else { return }
        if overlayContainer == nil {
            overlayContainer?.removeFromSuperview()
            overlayContainer = UIView()
            addSubview(overlayContainer!)
        }
        overlays[direction]??.removeFromSuperview()
        overlays[direction] = overlay
        overlays[direction]??.alpha = 0
        overlayContainer?.addSubview(overlay)
        setNeedsLayout()
    }
    
    public func setBackgroundImage(_ image: UIImage?) {
        if imageView == nil {
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            imageView?.contentMode = .scaleAspectFill
            addSubview(imageView!)
            setNeedsLayout()
        }
        imageView?.image = image
    }
    
    public func setFooterView(_ footer: UIView?) {
        guard let footer = footer else { return }
        footerView?.removeFromSuperview()
        footerView = footer
        addSubview(footerView!)
        setNeedsLayout()
    }

    open func setShadow(radius: CGFloat, opacity: Float, offset: CGSize = .zero, color: UIColor = UIColor.black) {
        animationLayer.shadowRadius = radius
        animationLayer.shadowOpacity = opacity
        animationLayer.shadowOffset = offset
        animationLayer.shadowColor = color.cgColor
    }
    
    //MARK: - Swipe Handling
    
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
