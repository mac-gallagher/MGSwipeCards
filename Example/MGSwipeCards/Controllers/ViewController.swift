//
//  SampleCardStackController.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 5/28/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards
import PopBounceButton

class ViewController: UIViewController {
    private let cardStack = MGCardStackView()
    private let buttonStackView = ButtonStackView()
    
    private let cardModels = [
        SampleCardModel(name: "Michelle", age: 26, occupation: "Graphic Designer", image: UIImage(named: "michelle")),
        SampleCardModel(name: "Joshua", age: 27, occupation: "Business Services Sales Representative", image: UIImage(named: "joshua")),
        SampleCardModel(name: "Daiane", age: 23, occupation: "Graduate Student", image: UIImage(named: "daiane")),
        SampleCardModel(name: "Julian", age: 25, occupation: "Model/Photographer", image: UIImage(named: "julian")),
        SampleCardModel(name: "Andrew", age: 26, occupation: nil, image: UIImage(named: "andrew")),
        SampleCardModel(name: "Bailey", age: 25, occupation: "Software Engineer", image: UIImage(named: "bailey")),
        SampleCardModel(name: "Rachel", age: 27, occupation: "Interior Designer", image: UIImage(named: "rachel"))
    ]
    
    override func viewDidLoad() {
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self

        configureNavigationBar()
        layoutButtonStackView()
        layoutCardStackView()
        configureBackgroundGradient()
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
        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
    }
    
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: buttonStackView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    @objc private func handleShift(_ sender: UIButton) {
        cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
    }
}

//MARK: Data Source + Delegates

extension ViewController: MGCardStackViewDataSource, MGCardStackViewDelegate, ButtonStackViewDelegate {
    func cardStack(_ cardStack: MGCardStackView, cardForIndexAt index: Int) -> SwipeCard {
        return SampleCard(model: cardModels[index])
    }
    
    func numberOfCards(in cardStack: MGCardStackView) -> Int {
        return cardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: MGCardStackView) {
        print("Swiped all cards!")
    }
    
    func cardStack(_ cardStack: MGCardStackView, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(cardModels[index].name)")
    }
    
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("Swiped \(direction) on \(cardModels[index].name)")
    }
    
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, tapCorner: UIRectCorner) {
        var cornerString: String
        switch tapCorner {
        case .topLeft:
            cornerString = "top left"
        case .topRight:
            cornerString = "top right"
        case .bottomRight:
            cornerString = "bottom right"
        case .bottomLeft:
            cornerString = "bottom left"
        default:
            cornerString = ""
        }
        print("Card tapped at \(cornerString)")
    }
    
    func didTapButton(button: TinderButton) {
        switch button.tag {
        case 1:
            cardStack.undoLastSwipe(animated: true)
        case 2:
            cardStack.swipe(.left, animated: true)
        case 3:
            cardStack.swipe(.up, animated: true)
        case 4:
            cardStack.swipe(.right, animated: true)
        default:
            break
        }
    }
}
