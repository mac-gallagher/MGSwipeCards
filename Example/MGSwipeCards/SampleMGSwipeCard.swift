//
//  FooterView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 6/2/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class SampleMGSwipeCard: MGSwipeCard {
    
    var model: SampleMGSwipeCardModel?
    
    override init() {
        super.init()
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        layer.cornerRadius = 10
        swipeDirections = [.left, .up, .right]
        setShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2), color: .black)
        configureOverlays()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradientLayer()
    }
    
    private func configureGradientLayer() {
        let height: CGFloat = 150
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.01).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, below: footerView?.layer)
    }
    
    private func configureOverlays() {
        //left overlay
        let leftView = UIView()
        let leftOverlay = SampleOverlay(title: "NOPE", color: .sampleRed)
        leftView.addSubview(leftOverlay)
        leftOverlay.anchor(top: leftView.topAnchor, left: nil, bottom: nil, right: leftView.rightAnchor, paddingTop: 30, paddingRight: 14)
        leftOverlay.transform = CGAffineTransform(rotationAngle: CGFloat.pi/10)
        setOverlay(forDirection: .left, overlay: leftView)
        
        //right overlay
        let rightView = UIView()
        let rightOverlay = SampleOverlay(title: "LIKE", color: .sampleGreen)
        rightView.addSubview(rightOverlay)
        rightOverlay.anchor(top: rightView.topAnchor, left: rightView.leftAnchor, bottom: nil, right: nil, paddingTop: 26, paddingLeft: 14)
        rightOverlay.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/10)
        setOverlay(forDirection: .right, overlay: rightView)
        
        //up overlay
        let upView = UIView()
        let upOverlay = SampleOverlay(title: "LOVE", color: .sampleBlue)
        upView.addSubview(upOverlay)
        upOverlay.anchor(top: nil, left: nil, bottom: upView.bottomAnchor, right: nil, paddingBottom: 20)
        upOverlay.centerXAnchor.constraint(equalTo: upView.centerXAnchor).isActive = true
        upOverlay.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/20)
        setOverlay(forDirection: .up, overlay: upView)
    }
    
}
