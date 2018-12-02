//
//  SampleCard.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 7/12/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class SampleCard: MGSwipeCard {
    init(model: SampleCardModel) {
        super.init()
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
    
        leftOverlay = SampleCardOverlay.left()
        rightOverlay = SampleCardOverlay.right()
        upOverlay = SampleCardOverlay.up()
    }
    
    private func configure(model: SampleCardModel) {
        content = SampleCardContentView(image: model.image)
        footer = SampleCardFooterView(title: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
}
