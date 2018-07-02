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
    
    init(title: String?, subtitle: String?) {
        super.init(frame: CGRect.zero)
        self.title = title
        self.subtitle = subtitle
        initializeLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    private func initializeLabel() {
        let attributedText = NSMutableAttributedString(string: (title ?? "") + "\n", attributes: NSAttributedStringKey.titleAttributes)
        
        if subtitle != nil && subtitle != "" {
            attributedText.append(NSMutableAttributedString(string: subtitle!, attributes: NSAttributedStringKey.subtitleAttributes))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attributedText.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
            label.numberOfLines = 2
        }
        
        label.attributedText = attributedText

        addSubview(label)
    }
    
    override func layoutSubviews() {
        let padding: CGFloat = 20
        label.frame = CGRect(x: padding, y: bounds.height - label.intrinsicContentSize.height - padding, width: bounds.width - 2 * padding, height: label.intrinsicContentSize.height)
    }
    
}

extension NSAttributedStringKey {
    
    static var shadowAttribute: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
        return shadow
    }()
    
    static var titleAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font: UIFont(name: "ArialRoundedMTBold", size: 24)!,
        NSAttributedStringKey.foregroundColor: UIColor.white,
        NSAttributedStringKey.shadow: NSAttributedStringKey.shadowAttribute
    ]
    
    static var subtitleAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font: UIFont(name: "Arial", size: 17)!,
        NSAttributedStringKey.foregroundColor: UIColor.white,
        NSAttributedStringKey.shadow: NSAttributedStringKey.shadowAttribute
    ]
    
}

