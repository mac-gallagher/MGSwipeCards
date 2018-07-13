//
//  SampleMGSwipeCard.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 7/12/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class SampleMGSwipeCard: MGSwipeCard {
    
    var model: SampleCardModel? {
        didSet {
            configureCard()
        }
    }
    
    private func configureCard() {
        footerIsTransparent = true
        footerHeight = 80
        swipeDirections = [.left, .up, .right]
        setContentView(SampleCardView(image: model?.image))
        setFooterView(SampleCardFooterView(title: "\(model?.name ?? ""), \(model?.age ?? 0)", subtitle: model?.occupation))
        swipeDirections.forEach { direction in
            setOverlay(forDirection: direction, overlay: overlay(for: direction))
        }
    }
    
    private func overlay(for direction: SwipeDirection) -> UIView? {
        switch direction {
        case .left:
            let leftView = UIView()
            let leftOverlay = SampleCardOverlay(title: "NOPE", color: .sampleRed, rotationAngle: CGFloat.pi/10)
            leftView.addSubview(leftOverlay)
            leftOverlay.anchor(top: leftView.topAnchor, left: nil, bottom: nil, right: leftView.rightAnchor, paddingTop: 30, paddingRight: 14)
            return leftView
        case .up:
            let upView = UIView()
            let upOverlay = SampleCardOverlay(title: "LOVE", color: .sampleBlue, rotationAngle: -CGFloat.pi/20)
            upView.addSubview(upOverlay)
            upOverlay.anchor(top: nil, left: nil, bottom: upView.bottomAnchor, right: nil, paddingBottom: 20)
            upOverlay.centerXAnchor.constraint(equalTo: upView.centerXAnchor).isActive = true
            return upView
        case .right:
            let rightView = UIView()
            let rightOverlay = SampleCardOverlay(title: "LIKE", color: .sampleGreen, rotationAngle: -CGFloat.pi/10)
            rightView.addSubview(rightOverlay)
            rightOverlay.anchor(top: rightView.topAnchor, left: rightView.leftAnchor, bottom: nil, right: nil, paddingTop: 26, paddingLeft: 14)
            return rightView
        case .down:
            return nil
        }
    }
    
}
