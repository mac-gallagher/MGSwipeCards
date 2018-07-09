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
        cardStack.verticalInset = 14
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
            let card = cardStack.undoLastSwipe()
            if card != nil {
                let name = (card as! SampleMGSwipeCard).model?.name ?? ""
                print("Undo swipe on \(name)")
            }
        case 2:
            cardStack.swipe(withDirection: .left)
        case 3:
            cardStack.swipe(withDirection: .up)
        case 4:
            cardStack.swipe(withDirection: .right)
        default:
            break
        }
    }
    
}

//MARK: - Data Source

extension ViewController: MGCardStackViewDataSource {
    
    func numberOfCards(in cardStack: MGCardStackView) -> Int {
        return cardModels.count
    }
    
    func cardStack(_ cardStack: MGCardStackView, viewforCardAt index: Int) -> UIView? {
        return UIView()
    }
    
    func cardStack(_ cardStack: MGCardStackView, viewForCardFooterAt index: Int) -> UIView? {
        let footer = UIView()
        if index % 2 == 0 {
            footer.backgroundColor = .blue
        } else {
            footer.backgroundColor = .red
        }
        return footer
    }
    
    func cardStack(_ cardStack: MGCardStackView, heightForCardFooterAt index: Int) -> CGFloat {
        return 150
    }
    
}

//MARK: - Delegate

extension ViewController: MGCardStackViewDelegate {
 
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int, recognizer: UITapGestureRecognizer) {
        print("tapped, location \(recognizer.location(in: cardStack))")
    }
    
    func cardStack(_ cardStack: MGCardStackView, didSelectCardAt index: Int) {
        print("tapped")
    }
    
}


//MARK: - Card Models

extension ViewController {
    
    var cardModels: [SampleMGSwipeCardModel] {
        var models = [SampleMGSwipeCardModel]()
        
        let michelle = SampleMGSwipeCardModel(name: "Michelle", age: 26, occupation: "Graphic Designer", image:#imageLiteral(resourceName: "michelle"))
        let joshua = SampleMGSwipeCardModel(name: "Joshua", age: 27, occupation: "Business Services Sales Representative", image: #imageLiteral(resourceName: "joshua"))
        let daiane = SampleMGSwipeCardModel(name: "Daiane", age: 23, occupation: "Graduate Student", image: #imageLiteral(resourceName: "daiane"))
        let andrew = SampleMGSwipeCardModel(name: "Andrew", age: 26, occupation: nil, image: #imageLiteral(resourceName: "andrew"))
        let julian = SampleMGSwipeCardModel(name: "Julian", age: 25, occupation: "Model/Photographer", image: #imageLiteral(resourceName: "julian"))
        let bailey = SampleMGSwipeCardModel(name: "Bailey", age: 25, occupation: "Software Engineer", image: #imageLiteral(resourceName: "bailey"))
        let rachel = SampleMGSwipeCardModel(name: "Rachel", age: 27, occupation: "Interior Designer", image: #imageLiteral(resourceName: "rachel"))
        
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

