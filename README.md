# MGSwipeCards
A modern swipeable card interface inspired by Tinder and built with Facebook's Pop animation library.

<img src="https://github.com/mac-gallagher/MGSwipeCards/blob/master/Screenshots/swipe_example.gif?raw=true">

## Features
* Modern user interface
* Maximum customizability - create your own card template!
* Accurate swipe recognition based on velocity and card position
* Smooth overlay image transitions
* Dynamic card loading using data source/delegate pattern

## Installation

### CocoaPods
MGSwipeCards is available through [CocoaPods](<https://cocoapods.org/>). To install it, simply add the following line to your `Podfile`:

	pod 'MGSwipeCards', '~> 1.0'


### Manual
1. Download and drop the `Sources` directory into your project. 
2. Install Facebook's [Pop](<https://github.com/facebook/pop>) library via CocoaPods by adding the following line to your `Podfile`: 

	    pod 'pop', '~> 1.0'

## Usage
The framework `MGSwipeCards` is comprised two main classes:

* `MGSwipeCard` - the base class for all animated swipeable cards.
* `MGSwipeCardStackView` - the view which handles the displaying and loading of cards.

### Creating cards
1. Create your own card by subclassing `MGSwipeCard`. Add any subviews you like; you have complete control over your card's appearance!
2. Set your card's swipeable directions with the `swipeDirections` attribute.
3. Create your overlay views and attach them using the `setOverlay` function. By default, each overlay covers the entire card. To change this behavior, simply layout your overlay in another view and attach this view your card instead.

    ```swift
    class MyMGSwipeCard: MGSwipeCard {
   
        override init(frame: CGRect) {
            super.init(frame: frame)
            swipeDirections = [.left, .right] //default is [.left, .up, .right, .down]
            configureOverlays()
        }
        
        func configureOverlays() {
            let redView = UIView()
            redView.backgroundColor = .red
            setOverlay(forDirection: .left, overlay: redView)
            
            let greenView = UIView()
            greenView.backgroundColor = .green
            setOverlay(forDirection: .right, overlay: greenView)
        }
        
    }
    ```
    
    | <img src="https://raw.githubusercontent.com/mac-gallagher/MGSwipeCards/master/Screenshots/one_direction_example.gif" width="250"/> |  <img src="https://raw.githubusercontent.com/mac-gallagher/MGSwipeCards/master/Screenshots/three_directions_example.gif" width="250"/> | 
    |:---:|:---:|
    | **Figure 1:** Overlay Transitions with<br> One Swipe Direction | **Figure 2:** Overlay Transitions with<br> Three Swipe Directions |
    
    
  
 
### Creating a card stack  

1. Add a `MGSwipeCardStackView` to your view.

    ```swift
    class ViewController: UIViewController {
    
        var cards = [MyMGSwipeCard]()
        
        var cardStack = MGCardStackView()
        
        override func viewDidLoad() {
            view.addSubview(cardStack)
        }
        
        override func layoutSubviews() {
            cardStack.frame = view.bounds.insetBy(dx: 50, dy: 50)
        }
        
    }
    ```

2. Conform your view controller to the protocols `MGSwipeCardStackViewDataSource` and  `MGSwipeCardStackViewDelegate` and complete all required functions.

    ```swift
    extension ViewController: MGSwipeCardDataSource, MGSwipeCardDelegate {
    
        // MARK: - Data Source Methods
    
        func numberOfCards() -> Int {
            return cards.count
        }
        
        func card(forItemAtIndex index: Int) -> MGSwipeCard {
            return cards[index]
        }
        
        // MARK: - Delegate Methods
        
        func didSwipeAllCards() {
            print("Swiped all cards")
        }
    
        func didEndSwipe(on card: MGSwipeCard, withDirection direction: SwipeDirection) {
            print("Swiped \(direction)")
        }
        
    }
    ```

## Customization

### Card appearance
Each `MGSwipeCard` has the following built-in properties:

* **Background Image** - Set with `setBackgroundImage(_ image: UIImage)`.
* **Footer** - Set with `setFooterView(_ footer: UIView?, withHeight height: CGFloat)`. The card's background image is displayed above the footer unless the footer is transparent.
* **Shadow** - Set with `setShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor)`.

### Swipe recognition settings

Attribute  | Description
|:------------- |:-------------
`minimumSwipeSpeed`  | The minimum required speed on the intended direction to trigger a swipe. Expressed in points per second. Defaults to 1600.
`minimumSwipeMargin` | The minimum required drag distance on the intended direction to trigger a swipe. Measured from the initial touch point. Defined as a value in the range [0, 2]. Defaults to 0.5.

### Animation settings

Attribute  | Description
|:------------- |:-------------
`maximumRotationAngle`           | The maximum rotation angle of the card. Measured in radians. Defined as a value in the range [0, `CGFloat.pi`/2]. Defaults to `CGFloat.pi`/10.
`swipeAnimationMinimumDuration`  | The minimum duration of the off-screen swipe animation. Measured in seconds. Defaults to 0.8.
`resetAnimationSpringBounciness` | The effective bounciness of the swipe spring animation upon a cancelled swipe. Higher values increase spring movement range resulting in more oscillations and springiness. Defined as a value in the range [0, 20]. Defaults to 12.
`resetAnimationSpringSpeed`      | The effective speed of the spring animation upon a cancelled swipe. Higher values increase the dampening power of the spring. Defined as a value in the range [0, 20]. Defaults to 20.

### MGCardStackView
Each `MGCardStackView` has the attributes `horizontalInset` and `verticalInset` which adjust the padding between the view and its contained cards. Measured in points. Both values are defaulted to 10.

## Other Methods
* `shift(withDistance distance: Int)` - Shifts the card stack by the given distance. The indices of any previously swiped cards are ignored.

## Requirements
* iOS 8.0+
* Xcode 9.0+

## Sources
* [Pop](<https://github.com/facebook/pop>): Facebook's iOS animation framework.
* *"Building a Tinder-esque Card Interface"* by Phill Farrugia (on [Medium](https://medium.com/@phillfarrugia/building-a-tinder-esque-card-interface-5afa63c6d3db))

## Author
Mac Gallagher, jmgallagher36@gmail.com

## License
MGSwipeCards is available under the [MIT License](LICENSE), see LICENSE for more infomation.
