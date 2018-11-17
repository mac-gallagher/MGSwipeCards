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

//MARK: - ViewController

class ViewController: UIViewController {
    let cardStack = MGCardStackView()
    let buttonStackView = ButtonStackView()
    
    private let cardModels: [SampleCardModel] = [
        SampleCardModel(name: "Michelle", age: 26, occupation: "Graphic Designer", image: UIImage(named: "michelle")),
        SampleCardModel(name: "Joshua", age: 27, occupation: "Business Services Sales Representative", image: UIImage(named: "joshua")),
        SampleCardModel(name: "Julian", age: 25, occupation: "Model/Photographer", image: UIImage(named: "julian")),
        SampleCardModel(name: "Bailey", age: 25, occupation: "Software Engineer", image: UIImage(named: "bailey")),
        SampleCardModel(name: "Rachel", age: 27, occupation: "Interior Designer", image: UIImage(named: "rachel"))
    ]
    
    override func viewDidLoad() {
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self
        setupUI()
    }
    
    @objc func handleShift(_ sender: UIButton) {
        if sender.tag == 1 {
            cardStack.shift(withDistance: -1, animated: true)
        } else {
            cardStack.shift(animated: true)
        }
    }
}

//MARK: - MGCardStackViewDataSource

extension ViewController: MGCardStackViewDataSource {
    func cardStack(_ cardStack: MGCardStackView, cardForIndexAt index: Int) -> MGSwipeCard {
        return SampleCard(model: cardModels[index])
    }
    
    func numberOfCards(in cardStack: MGCardStackView) -> Int {
        return cardModels.count
    }
}

//MARK: - MGCardStackViewDelegate

extension ViewController: MGCardStackViewDelegate {
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
}

//MARK - ButtonStackViewDelegate

extension ViewController: ButtonStackViewDelegate {
    func didTapUndo() {
        cardStack.undoLastSwipe()
    }

    func didTapPass() {
        cardStack.swipe(.left)
    }
    
    func didTapSuperLike() {
        cardStack.swipe(.up)
    }
    
    func didTapLike() {
        cardStack.swipe(.right)
    }
    
    func didTapBoost() { }
}
