//
//  Array+Shift.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

extension Array {
    func shift(withDistance distance: Int = 1) -> Array<Element> {
        let offsetIndex = distance >= 0 ? self.index(startIndex, offsetBy: distance, limitedBy: endIndex) : self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
        guard let index = offsetIndex else { return self }
        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
}
