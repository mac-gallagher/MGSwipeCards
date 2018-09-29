//
//  SampleCardFooterView.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 6/3/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

class SampleCardFooterView: UIView {
    
    var title: String?
    var subtitle: String?
    var label = UILabel()
    
    private var gradientLayer: CAGradientLayer?
    
    //MARK: - Initialization
    
    init(title: String?, subtitle: String?) {
        super.init(frame: CGRect.zero)
        self.title = title
        self.subtitle = subtitle
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = .clear
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 10 //only do bottom corners
        clipsToBounds = true
        initializeLabel()
    }
    
    private func initializeLabel() {
        let attributedText = NSMutableAttributedString(string: (title ?? "") + "\n", attributes: NSAttributedString.Key.titleAttributes)
        
        if subtitle != nil && subtitle != "" {
            attributedText.append(NSMutableAttributedString(string: subtitle!, attributes: NSAttributedString.Key.subtitleAttributes))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attributedText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            label.numberOfLines = 2
        }
        
        label.attributedText = attributedText
        addSubview(label)
    }
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        let padding: CGFloat = 20
        label.frame = CGRect(x: padding, y: bounds.height - label.intrinsicContentSize.height - padding, width: bounds.width - 2 * padding, height: label.intrinsicContentSize.height)
    }
    
}

extension NSAttributedString.Key {
    
    static var shadowAttribute: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
        return shadow
    }()
    
    static var titleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 24)!,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
    
    static var subtitleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "Arial", size: 17)!,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
    
}

