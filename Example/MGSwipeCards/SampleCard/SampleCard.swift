//
//  SampleMGSwipeCard.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 7/12/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class SampleCard: MGSwipeCard {
    var model: SampleCardModel?
    
    private var leftOverlay: UIView = {
        let leftView = UIView()
        let leftOverlay = SampleCardOverlay(title: "NOPE", color: .sampleRed, rotationAngle: CGFloat.pi/10)
        leftView.addSubview(leftOverlay)
        leftOverlay.anchor(top: leftView.topAnchor, left: nil, bottom: nil, right: leftView.rightAnchor, paddingTop: 30, paddingRight: 14)
        return leftView
    }()
    
    private var upOverlay: UIView = {
        let upView = UIView()
        let upOverlay = SampleCardOverlay(title: "LOVE", color: .sampleBlue, rotationAngle: -CGFloat.pi/20)
        upView.addSubview(upOverlay)
        upOverlay.anchor(top: nil, left: nil, bottom: upView.bottomAnchor, right: nil, paddingBottom: 20)
        upOverlay.centerXAnchor.constraint(equalTo: upView.centerXAnchor).isActive = true
        return upView
    }()
    
    private var rightOverlay: UIView = {
        let rightView = UIView()
        let rightOverlay = SampleCardOverlay(title: "LIKE", color: .sampleGreen, rotationAngle: -CGFloat.pi/10)
        rightView.addSubview(rightOverlay)
        rightOverlay.anchor(top: rightView.topAnchor, left: rightView.leftAnchor, bottom: nil, right: nil, paddingTop: 26, paddingLeft: 14)
        return rightView
    }()
    
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
    
    private func initialize() {
        swipeDirections = [.left, .up, .right]
        isFooterTransparent = true
        footerHeight = 80
    }
    
    override func contentView() -> UIView? {
        return SampleCardContentView(image: model?.image)
    }
    
    override func footerView() -> UIView? {
        return SampleCardFooterView(title: "\(model?.name ?? ""), \(model?.age ?? 0)", subtitle: model?.occupation)
    }
    
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
        switch direction {
        case .left:
            return leftOverlay
        case .up:
           return upOverlay
        case .right:
            return rightOverlay
        case .down:
            return nil
        }
    }
}
