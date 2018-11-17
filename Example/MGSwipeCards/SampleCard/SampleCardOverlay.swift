//
//  SampleCardOverlay.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 11/14/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

//MARK: - SampleCardOverlay

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

//MARK: - Sample Overlays

extension SampleCardOverlay {
    static func left() -> UIView {
        let leftView = UIView()
        let leftOverlay = SampleCardOverlay(title: "NOPE", color: .sampleRed, rotationAngle: CGFloat.pi/10)
        leftView.addSubview(leftOverlay)
        leftOverlay.anchor(top: leftView.topAnchor, left: nil, bottom: nil, right: leftView.rightAnchor, paddingTop: 30, paddingRight: 14)
        return leftView
    }
    
    static func up() -> UIView {
        let upView = UIView()
        let upOverlay = SampleCardOverlay(title: "LOVE", color: .sampleBlue, rotationAngle: -CGFloat.pi/20)
        upView.addSubview(upOverlay)
        upOverlay.anchor(top: nil, left: nil, bottom: upView.bottomAnchor, right: nil, paddingBottom: 20)
        upOverlay.centerXAnchor.constraint(equalTo: upView.centerXAnchor).isActive = true
        return upView
    }
    
    static func right() -> UIView {
        let rightView = UIView()
        let rightOverlay = SampleCardOverlay(title: "LIKE", color: .sampleGreen, rotationAngle: -CGFloat.pi/10)
        rightView.addSubview(rightOverlay)
        rightOverlay.anchor(top: rightView.topAnchor, left: rightView.leftAnchor, bottom: nil, right: nil, paddingTop: 26, paddingLeft: 14)
        return rightView
    }
}

//MARK: - Extensions

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
