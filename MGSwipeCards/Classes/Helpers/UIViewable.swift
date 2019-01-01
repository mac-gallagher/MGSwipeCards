//
//  UIViewHelper.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

open class UIViewable: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {}
}
