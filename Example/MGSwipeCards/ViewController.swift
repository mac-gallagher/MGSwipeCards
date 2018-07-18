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
    
    //MARK: - Subviews
    
    lazy var cards: [SampleMGSwipeCard] = {
        var finishedCards = [SampleMGSwipeCard]()
        for model in cardModels {
            let card = SampleMGSwipeCard()
            card.model = model
            finishedCards.append(card)
        }
        return finishedCards
    }()
    
    let cardStack = MGCardStackView()
    
    var backgroundGradient: UIView?
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .equalSpacing
        sv.alignment = .center
        return sv
    }()
    
    let undoButton: PopBounceButton = {
        let button = PopBounceButton()
        button.setImage(#imageLiteral(resourceName: "undo"))
        button.tag = 1
        return button
    }()
    
    let passButton: PopBounceButton = {
        let button = PopBounceButton()
        button.setImage(#imageLiteral(resourceName: "pass"))
        button.tag = 2
        return button
    }()
    
    let superLikeButton: PopBounceButton = {
        let button = PopBounceButton()
        button.setImage(#imageLiteral(resourceName: "star"))
        button.tag = 3
        return button
    }()
    
    let likeButton: PopBounceButton = {
        let button = PopBounceButton()
        button.setImage(#imageLiteral(resourceName: "heart"))
        button.tag = 4
        return button
    }()
    
    let boostButton: PopBounceButton = {
        let button = PopBounceButton()
        button.setImage(#imageLiteral(resourceName: "lightning"))
        button.tag = 5
        return button
    }()
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        configureNavigationBar()
        initializeButtonStackView()
        setupButtons()
        initializeCardStackView()
    }
    
    func configureNavigationBar() {
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
    
    @objc func handleShift(_ sender: UIButton) {
        if sender.tag == 1 {
            cardStack.shift(withDistance: -1)
        } else {
            cardStack.shift()
        }
    }
    
    func initializeButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
        buttonStackView.addArrangedSubview(undoButton)
        buttonStackView.addArrangedSubview(passButton)
        buttonStackView.addArrangedSubview(superLikeButton)
        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(boostButton)
    }
    
    func setupButtons() {
        let largeMultiplier: CGFloat = 66/414 //based on width of iPhone 8+
        let smallMultiplier: CGFloat = 54/414 //based on width of iPhone 8+
        configureButton(button: undoButton, diameterMultiplier: smallMultiplier)
        configureButton(button: passButton, diameterMultiplier: largeMultiplier)
        configureButton(button: superLikeButton, diameterMultiplier: smallMultiplier)
        configureButton(button: likeButton, diameterMultiplier: largeMultiplier)
        configureButton(button: boostButton, diameterMultiplier: smallMultiplier)
    }
    
    func configureButton(button: PopBounceButton, diameterMultiplier: CGFloat) {
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: diameterMultiplier).isActive = true
        button.widthAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: diameterMultiplier).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    func initializeCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: buttonStackView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
        cardStack.delegate = self
        cardStack.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        for button in buttonStackView.subviews as! [PopBounceButton] {
            let diameter = button.bounds.width
            button.layer.cornerRadius = diameter / 2
            button.setShadow(radius: 0.2 * diameter, opacity: 0.05, offset: CGSize(width: 0, height: 0.15 * diameter))
        }
        configureBackgroundGradient()
    }
    
    func configureBackgroundGradient() {
        backgroundGradient?.removeFromSuperview()
        backgroundGradient = UIView()
        view.insertSubview(backgroundGradient!, at: 0)
        backgroundGradient?.frame = CGRect(origin: .zero, size: view.bounds.size)
        
        let myGrey = UIColor(red: 244/255, green: 247/255, blue: 250/255, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, myGrey.cgColor]
        gradientLayer.frame = backgroundGradient!.frame
        backgroundGradient?.layer.addSublayer(gradientLayer)
    }
    
    @objc func handleTap(_ sender: PopBounceButton) {
        switch sender.tag {
        case 1:
            cardStack.undoLastSwipe()
        case 2:
            cardStack.swipe(.left)
        case 3:
            cardStack.swipe(.up)
        case 4:
            cardStack.swipe(.right)
        default:
            break
        }
    }
    
}

//MARK: - Data Source

extension ViewController: MGCardStackViewDataSource {
    
    func cardStack(_ cardStack: MGCardStackView, cardForIndexAt index: Int) -> MGSwipeCard {
        let card = SampleMGSwipeCard()
        card.model = cardModels[index]
        return card
//        return cards[index]
    }
    
    func numberOfCards(in cardStack: MGCardStackView) -> Int {
        return cards.count
    }
    
}

//MARK: - Delegate

extension ViewController: MGCardStackViewDelegate {
    
    func didSwipeAllCards(_ cardStack: MGCardStackView) {
        print("Swiped all cards!")
    }
    
    func additionalOptions(_ cardStack: MGCardStackView) -> MGCardStackViewOptions {
        let options = MGCardStackViewOptions()
        options.cardStackInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        return options
    }
    
    func cardStack(_ cardStack: MGCardStackView, didUndoSwipeOnCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(cards[index].model?.name ?? "")")
    }
    
    func shouldDisableShiftAnimation(_ cardStack: MGCardStackView) -> Bool {
        return false
    }
    
    func cardStack(_ cardStack: MGCardStackView, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("Swiped \(direction) on \(cards[index].model?.name ?? "")")
    }
    
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, touchPoint: CGPoint) {
        print("Tapped with location \(touchPoint)")
    }
    
}


//MARK: - Card Models

extension ViewController {
    
    var cardModels: [SampleCardModel] {
        var models = [SampleCardModel]()
        
        let michelle = SampleCardModel(name: "Michelle", age: 26, occupation: "Graphic Designer", image:#imageLiteral(resourceName: "michelle"))
        let joshua = SampleCardModel(name: "Joshua", age: 27, occupation: "Business Services Sales Representative", image: #imageLiteral(resourceName: "joshua"))
        let daiane = SampleCardModel(name: "Daiane", age: 23, occupation: "Graduate Student", image: #imageLiteral(resourceName: "daiane"))
        let andrew = SampleCardModel(name: "Andrew", age: 26, occupation: nil, image: #imageLiteral(resourceName: "andrew"))
        let julian = SampleCardModel(name: "Julian", age: 25, occupation: "Model/Photographer", image: #imageLiteral(resourceName: "julian"))
        let bailey = SampleCardModel(name: "Bailey", age: 25, occupation: "Software Engineer", image: #imageLiteral(resourceName: "bailey"))
        let rachel = SampleCardModel(name: "Rachel", age: 27, occupation: "Interior Designer", image: #imageLiteral(resourceName: "rachel"))
        
        models.append(michelle)
        models.append(joshua)
        models.append(daiane)
        models.append(andrew)
        models.append(julian)
        models.append(bailey)
        models.append(rachel)
        
        return models
    }
    
    
}







