//
//  SampleOverlayView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 6/3/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

class SampleOverlay: UIView {
    
    private var title: String?
    
    private var color: UIColor?
    
    init(title: String?, color: UIColor?) {
        super.init(frame: CGRect.zero)
        self.title = title
        self.color = color
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layer.borderColor = color?.cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 4
        initializeLabel()
    }
    
    private func initializeLabel() {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: title ?? "", attributes: NSAttributedStringKey.overlayAttributes)
        label.textColor = color
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 3, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
    }

}

extension NSAttributedStringKey {

    static var overlayAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
        NSAttributedStringKey.kern: 5.0
    ]

}








