//
//  SampleCardView.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 7/10/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

class SampleCardView: UIView {
    
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
        backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        backgroundView.addSubview(imageView)
        imageView.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor)
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
