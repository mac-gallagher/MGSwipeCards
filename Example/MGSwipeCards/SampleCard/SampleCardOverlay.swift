//
//  SampleCardOverlay.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 11/14/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

class SampleCardOverlay: UIView {
    private var title: String?
    private var color: UIColor?
    private var rotationAngle: CGFloat = 0
    
    init(title: String?, color: UIColor?, rotationAngle: CGFloat) {
        super.init(frame: CGRect.zero)
        self.title = title
        self.color = color
        self.rotationAngle = rotationAngle
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
        transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
    
    private func initializeLabel() {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: title ?? "", attributes: NSAttributedString.Key.overlayAttributes)
        label.textColor = color
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 3, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
    }
}

extension NSAttributedString.Key {
    static var overlayAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
        NSAttributedString.Key.kern: 5.0
    ]
}

extension UIColor {
    static var sampleRed = UIColor(red: 252/255, green: 70/255, blue: 93/255, alpha: 1)
    static var sampleGreen = UIColor(red: 49/255, green: 193/255, blue: 109/255, alpha: 1)
    static var sampleBlue = UIColor(red: 52/255, green: 154/255, blue: 254/255, alpha: 1)
}
