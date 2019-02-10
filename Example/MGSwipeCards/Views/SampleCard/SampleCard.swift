//
//  SampleCard.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 7/12/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class SampleCard: SwipeCard {
    init(model: SampleCardModel) {
        super.init(frame: .zero)
        initialize()
        configure(model: model)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        swipeDirections = [.left, .up, .right]
        isFooterTransparent = true
        footerHeight = 80
    
//        setOverlay(SampleCardOverlay.left(), forDirection: .left)
        setOverlay(SampleCardOverlay.right(), forDirection: .right)
        setOverlay(SampleCardOverlay.up(), forDirection: .up)
    }
    
    private func configure(model: SampleCardModel) {
        content = SampleCardContentView(image: model.image)
        footer = SampleCardFooterView(title: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
}
