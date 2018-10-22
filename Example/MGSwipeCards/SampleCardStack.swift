//
//  SampleCardStack.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 10/21/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class SampleCardStack: MGCardStackView {
    
    override init() {
        super.init()
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        options.cardStackInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    }
    
    override func transformForCard(at index: Int) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        if index == 0 { return transform }
        if index % 2 == 0 {
            transform = transform.translatedBy(x: -20 * CGFloat(index), y: 20 * CGFloat(index))
            transform = transform.rotated(by: -CGFloat(Double.pi/12))
        } else {
            transform = transform.translatedBy(x: 20 * CGFloat(index), y: 20 * CGFloat(index))
            transform = transform.rotated(by: CGFloat(Double.pi/12))
        }
        return transform.scaledBy(x: (1 - CGFloat(index) * 0.2), y: (1 - CGFloat(index) * 0.2))
    }
}
