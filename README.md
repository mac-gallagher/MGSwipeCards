# MGSwipeCards
![Swift-Version](https://img.shields.io/badge/Swift-4.1-orange.svg)
![CocoaPods](https://img.shields.io/cocoapods/v/MGSwipeCards.svg)
![license](https://img.shields.io/cocoapods/l/MGSwipeCards.svg)
![CocoaPods](https://img.shields.io/cocoapods/p/MGSwipeCards.svg)

🔥 A modern swipeable card interface inspired by Tinder and built with Facebook's Pop animation library.

![Tinder Demo](https://raw.githubusercontent.com/mac-gallagher/MGSwipeCards/master/Images/swipe_example.gif)

## Features
- [x] Maximum customizability - create your own card template!
- [x] Accurate swipe recognition based on velocity and card position
- [x] Programmatic swiping
- [x] Undo and card stack reordering
- [x] Smooth overlay view transitions
- [x] Dynamic card loading using data source/delegate pattern

## Table of Contents

- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [Contributing](#contributing)
- [Quick Start](#quick-start)
- [Useful Methods](#useful-methods)
- [Customization](#customization)
- [Sources](#sources)
- [Author](#author)
- [License](#license)

## Example
To run the example project, clone the repo and run the `MGSwipeCards-Example` target. 

The example project uses the Tinder-inspired framework [PopBounceButton](<https://github.com/mac-gallagher/PopBounceButton>), make sure to check it out!

## Requirements
* iOS 9.0+
* Xcode 9.0+
* Swift 4.0+

## Installation

### CocoaPods
MGSwipeCards is available through [CocoaPods](<https://cocoapods.org/>). To install it, simply add the following line to your `Podfile`:

	pod 'MGSwipeCards'

### Manual
1. Download and drop the `MGSwipeCards` directory into your project. 
2. Install Facebook's [Pop](<https://github.com/facebook/pop>) library.

## Contributing
- If you **found a bug**, open an issue and tag as bug.
- If you **have a feature request**, open an issue and tag as feature.
- If you **want to contribute**, submit a pull request.
	- In order to submit a pull request, please fork this repo and submit a pull request from your forked repo.
	- Have a detailed message as to what your pull request fixes/enhances/adds.

## Quick Start
1. Create your own card by subclassing `MGSwipeCard`.

    ```swift
    class SampleCard: MGSwipeCard {

	     var model: SampleCardModel? {
	         didSet {
	             configureModel()
	         }
	     }
	     
	     func configureModel() {
	         guard let model = model else { return }
	         self.setBackgroundImage(model.image)
	     }
    
    }
    
    struct SampleCardModel {
	     var image: UIImage
    }
    ```

2. Add a `MGCardStackView` to your view and implement to the protocol `MGCardStackViewDataSource`.

    ```swift
    class ViewController: UIViewController {
    
        var cards = [MyMGSwipeCard]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let cardStack = MGCardStackView()
            view.addSubview(cardStack)
            cardStack.frame = view.safeAreaLayoutGuide.bounds.insetBy(dx: 10, dy: 50)
            cardStack.dataSource = self
            
            for model in cardModels {
                let card = MyMGSwipeCard()
                card.model = model
                cards.append(card)
            }
        }
        
    }

    //MARK: - Data Source Methods
	
        extension ViewController: MGCardStackViewDataSource {

	    func numberOfCards() -> Int {
		    return cards.count
        }
        
	    func card(forItemAtIndex index: Int) -> MGSwipeCard {
		    return cards[index]
	    }
	
    }

    //MARK: - Card Models

    extension ViewController {

	    var cardModels: [SampleMGSwipeCardModel] {
            var models = [SampleMGSwipeCardModel]()
        
            let model1 = MyModel(image: UIImage(named: "cardImage1"))
            let model2 = MyModel(image: UIImage(named: "cardImage2"))
            let model3 = MyModel(image: UIImage(named: "cardImage3"))
                
            models.append(model1)
            models.append(model2)
            models.append(model3)
        
            return models
        }
    
    }
    ```
    
3. Happy swiping!


## Useful Methods
The following methods can be accessed from `MGCardStackView`.

### Swipe
Performs a swipe programmatically in the given direction. Any delegate methods are called as usual.

```swift
func swipe(withDirection direction: SwipeDirection)
```

![Shift](Images/swipe.gif)

### Undo
Restores the card stack to its state before the last swipe. Returns the newly restored card.

```swift
func undoLastSwipe() -> MGSwipeCard?
```

![Shift](Images/undo.gif)

### Shift
Shifts the card stack's cards by the given distance. Any previously swiped cards are skipped over.

```swift
func shift(withDistance distance: Int = 1)
```

![Shift](Images/shift.gif)

## Customization
Each `MGSwipeCard` has the following built-in UI properties. Other subviews can be added to make your own unique card template.

### Background image
The background image can be set with 

```swift 
func setBackgroundImage(_ image: UIImage)
```

### Footer
The footer can be set with 

```swift 
func setFooterView(_ footer: UIView?)
```
The footer's height should be modified with `footerHeight`. The card's background image is displayed above the footer unless the footer is transparent.

### Overlays
An *overlay* is the view whose alpha value reacts to the user's dragging. The card's overlays can be set with

```swift 
func setOverlay(forDirection direction: SwipeDirection, overlay: UIView?)
```
The overlays will always be laid out above the footer.

### Shadow
The card's shadow can be set with

```swift 
func setShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor)
```

## Sources
- [Pop](<https://github.com/facebook/pop>): Facebook's iOS animation framework.
- *"Building a Tinder-esque Card Interface"* by Phill Farrugia (on [Medium](https://medium.com/@phillfarrugia/building-a-tinder-esque-card-interface-5afa63c6d3db))

## Author
Mac Gallagher, jmgallagher36@gmail.com

## License
MGSwipeCards is available under the [MIT License](LICENSE), see LICENSE for more infomation.