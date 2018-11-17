//
//  ViewController+UI.swift
//  MGSwipeCards_Example
//
//  Created by Mac Gallagher on 11/17/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

extension ViewController {
    func setupUI() {
        configureNavigationBar()
        configureBackgroundGradient()
        layoutButtonStackView()
        layoutCardStackView()
    }
    
    private func configureNavigationBar() {
        let leftButton = UIBarButtonItem(title: "Shift Back", style: .plain, target: self, action: #selector(handleShift))
        leftButton.tintColor = .lightGray
        leftButton.tag = 1
        let rightButton = UIBarButtonItem(title: "Shift Forward", style: .plain, target: self, action: #selector(handleShift))
        rightButton.tintColor = .lightGray
        rightButton.tag = 2
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationController?.navigationBar.layer.zPosition = -1
    }
    
    private func configureBackgroundGradient() {
        let myGrey = UIColor(red: 244/255, green: 247/255, blue: 250/255, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, myGrey.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func layoutButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
    }
    
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: buttonStackView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
}
