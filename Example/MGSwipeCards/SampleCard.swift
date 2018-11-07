//
//  SampleMGSwipeCard.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 7/12/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

struct SampleCardModel {
    let name: String
    let age: Int
    let occupation: String?
    let image: UIImage?
}

class SampleCard: MGSwipeCard {
    
    override var isFooterTransparent: Bool { return true }
    override var footerHeight: CGFloat { return 80 }
    override var swipeDirections: [SwipeDirection] { return [.left, .up, .right] }
    
    var model: SampleCardModel?
    
    override func contentView() -> UIView? {
        return SampleCardContentView(image: model?.image)
    }
    
    override func footerView() -> UIView? {
        return SampleCardFooterView(title: "\(model?.name ?? ""), \(model?.age ?? 0)", subtitle: model?.occupation)
    }
    
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
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

class SampleCardContentView: UIView {
    
    let backgroundView: UIView = {
        let background = UIView()
        background.clipsToBounds = true
        background.layer.cornerRadius = 10
        return background
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    var gradientLayer: CAGradientLayer?
    
    init(image: UIImage?) {
        super.init(frame: .zero)
        imageView.image = image
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.addSubview(imageView)
        imageView.anchorToSuperview()
        configureShadow()
    }
    
    private func configureShadow() {
        layer.shadowRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureGradientLayer()
    }
    
    private func configureGradientLayer() {
        let heightFactor: CGFloat = 0.35
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = CGRect(x: 0, y: (1 - heightFactor) * bounds.height, width: bounds.width, height: heightFactor * bounds.height)
        gradientLayer?.colors = [UIColor.black.withAlphaComponent(0.01).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundView.layer.insertSublayer(gradientLayer!, above: imageView.layer)
    }
}

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


class SampleCardFooterView: UIView {
    
    var title: String?
    var subtitle: String?
    var label = UILabel()
    
    private var gradientLayer: CAGradientLayer?
    
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
        layer.cornerRadius = 10 //only modify bottom corners
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
    
    override func layoutSubviews() {
        let padding: CGFloat = 20
        label.frame = CGRect(x: padding, y: bounds.height - label.intrinsicContentSize.height - padding, width: bounds.width - 2 * padding, height: label.intrinsicContentSize.height)
    }
}

extension NSAttributedString.Key {
    
    static var overlayAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
        NSAttributedString.Key.kern: 5.0
    ]
    
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

extension UIColor {
    static var sampleRed = UIColor(red: 252/255, green: 70/255, blue: 93/255, alpha: 1)
    static var sampleGreen = UIColor(red: 49/255, green: 193/255, blue: 109/255, alpha: 1)
    static var sampleBlue = UIColor(red: 52/255, green: 154/255, blue: 254/255, alpha: 1)
}
