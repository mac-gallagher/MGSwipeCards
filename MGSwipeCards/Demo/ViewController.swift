//
//  SampleCardStackController.swift
//  Demo
//
//  Created by Mac Gallagher on 5/28/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import MGSwipeCards

class ViewController: UIViewController {
    
    var cards = [MGSwipeCard]()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 244/255, green: 247/255, blue: 250/255, alpha: 1)
        initializeCards()
        initializeCardStackView()
    }
    
    private func initializeCardStackView() {
        let cardStack = MGCardStackView()
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 45, paddingLeft: 0, paddingBottom: 45, paddingRight: 0, width: 0, height: 0)
        cardStack.delegate = self
        cardStack.dataSource = self
    }
    
    private func initializeCards() {
        for model in viewModels {
            let card = SampleMGSwipeCard()
            card.model = model
            card.setBackgroundImage(model.image)
            let footer = SampleCardFooterView(title: "\(model.name), \(model.age)", subtitle: model.occupation)
            card.setFooterView(footer, withHeight: footer.label.intrinsicContentSize.height + 20)
            cards.append(card)
        }
    }
    
}

//MARK: - Data Source + Delegate Methods

extension ViewController: MGCardStackViewDataSource, MGCardStackViewDelegate {
    
    func numberOfCards() -> Int {
        return cards.count
    }
    
    func card(forItemAtIndex index: Int) -> MGSwipeCard {
        return cards[index]
    }
    
    func didSwipeAllCards() {
        print("Swiped all cards!")
    }
    
    func didEndSwipe(on card: MGSwipeCard, withDirection direction: SwipeDirection) {
        print("Swiped \(direction) on \((card as! SampleMGSwipeCard).model?.name ?? "")")
    }
    
}

//MARK: - Card Models

extension ViewController {
    
    var viewModels: [SampleMGSwipeCardModel] {
        var models = [SampleMGSwipeCardModel]()
        
        let michelle = SampleMGSwipeCardModel(name: "Michelle", age: 26, occupation: "Graphic Designer", image: #imageLiteral(resourceName: "michelle"))
        let joshua = SampleMGSwipeCardModel(name: "Joshua", age: 27, occupation: "Business Services Sales Representative", image: #imageLiteral(resourceName: "joshua"))
        let daiane = SampleMGSwipeCardModel(name: "Daiane", age: 23, occupation: "Graduate Student", image: #imageLiteral(resourceName: "daiane"))
        let andrew = SampleMGSwipeCardModel(name: "Andrew", age: 26, occupation: nil, image: #imageLiteral(resourceName: "andrew"))
        let julian = SampleMGSwipeCardModel(name: "Julian", age: 25, occupation: "Model/Photographer", image: #imageLiteral(resourceName: "julian"))
        let bailey = SampleMGSwipeCardModel(name: "Bailey", age: 25, occupation: "Software Engineer", image: #imageLiteral(resourceName: "bailey"))
        let rachel = SampleMGSwipeCardModel(name: "Rachel", age: 27, occupation: "Interior Designer", image: #imageLiteral(resourceName: "rachel"))
        
        for _ in 0..<2 {
            models.append(michelle)
            models.append(joshua)
            models.append(daiane)
            models.append(andrew)
            models.append(julian)
            models.append(bailey)
            models.append(rachel)
        }
        
        return models
    }
    
}

