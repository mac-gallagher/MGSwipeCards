//
//  CardStackState.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

/**
 An internal data structure used to represent the current state of the card stack.
 
 A new state is created each time a user *swipes*, *shifts*, or *undos* a card on the stack. Each state contains a reference to the state before it.
 */
class CardStackState {
    static var emptyState = CardStackState(remainingIndices: [], previousSwipe: nil, previousState: nil)
    
    /// The indices of the data source which have yet to be swiped by the user. This array reflects the current order of the card stack, with the first element equal to the index of the top card. The order of this array accounts for both previously swiped cards and cards which may have been reordered in the stack.
    var remainingIndices: [Int]
    
    /// The swipe which occured in the previous state. The `index` parameter refers to the index of the card which was swiped.
    var previousSwipe: (index: Int, direction: SwipeDirection)?
    
    /// A reference to the previous card stack state.
    var previousState: CardStackState?
    
    init(remainingIndices: [Int], previousSwipe: (index: Int, direction: SwipeDirection)?, previousState: CardStackState?) {
        self.remainingIndices = remainingIndices
        self.previousSwipe = previousSwipe
        self.previousState = previousState
    }
}
