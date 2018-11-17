//
//  ButtonStackView.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 11/17/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import PopBounceButton

//MARK: - ButtonStackViewDelegate

protocol ButtonStackViewDelegate {
    func didTapUndo()
    func didTapPass()
    func didTapSuperLike()
    func didTapLike()
    func didTapBoost()
}

//MARK: - ButtonStackView

class ButtonStackView: UIStackView {
    
    var delegate: ButtonStackViewDelegate?
    
    private let undoButton: ButtonStackViewButton = {
        let button = ButtonStackViewButton()
        button.setImage(UIImage(named: "undo"))
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 1
        return button
    }()
    
    private let passButton: ButtonStackViewButton = {
        let button = ButtonStackViewButton()
        button.setImage(UIImage(named: "pass"))
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    
    private let superLikeButton: ButtonStackViewButton = {
        let button = ButtonStackViewButton()
        button.setImage(UIImage(named: "star"))
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    
    private let likeButton: ButtonStackViewButton = {
        let button = ButtonStackViewButton()
        button.setImage(UIImage(named: "heart"))
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 4
        return button
    }()
    
    private let boostButton: ButtonStackViewButton = {
        let button = ButtonStackViewButton()
        button.setImage(UIImage(named: "lightning"))
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 5
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        distribution = .equalSpacing
        alignment = .center
        configureButtonStackView()
    }
    
    private func configureButtonStackView() {
        addArrangedSubview(undoButton)
        addArrangedSubview(passButton)
        addArrangedSubview(superLikeButton)
        addArrangedSubview(likeButton)
        addArrangedSubview(boostButton)
    }
    
    //MARK: - Layout
    
    private var buttonConstraints = [NSLayoutConstraint]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
    
    private func layoutButtons() {
        NSLayoutConstraint.deactivate(buttonConstraints)
        buttonConstraints.removeAll()
        
        let largeMultiplier: CGFloat = 66/414 //based on width of iPhone 8+
        let smallMultiplier: CGFloat = 54/414 //based on width of iPhone 8+
        layoutButton(undoButton, diameterMultiplier: smallMultiplier)
        layoutButton(passButton, diameterMultiplier: largeMultiplier)
        layoutButton(superLikeButton, diameterMultiplier: smallMultiplier)
        layoutButton(likeButton, diameterMultiplier: largeMultiplier)
        layoutButton(boostButton, diameterMultiplier: smallMultiplier)
        
        NSLayoutConstraint.activate(buttonConstraints)
    }
    
    private func layoutButton(_ button: PopBounceButton, diameterMultiplier: CGFloat) {
        button.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = button.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: diameterMultiplier)
        let widthConstraint = button.heightAnchor.constraint(equalTo: button.widthAnchor)
        buttonConstraints.append(contentsOf: [heightConstraint, widthConstraint])
    }
    
    @objc func handleTap(_ sender: PopBounceButton) {
        switch sender.tag {
        case 1:
            delegate?.didTapUndo()
        case 2:
            delegate?.didTapPass()
        case 3:
            delegate?.didTapSuperLike()
        case 4:
            delegate?.didTapLike()
        case 5:
            delegate?.didTapBoost()
        default:
            break
        }
    }
}

//MARK: - ButtonStackViewButton

fileprivate class ButtonStackViewButton: PopBounceButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.width / 2
        setShadow(radius: 0.2 * frame.width, opacity: 0.05, offset: CGSize(width: 0, height: 0.15 * frame.width))
    }
}
