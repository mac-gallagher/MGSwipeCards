//
//  UIViewHelper.swift
//  MGSwipeCards
//
//  Created by Mac Gallagher on 11/2/18.
//

open class UIViewHelper: UIView {
    public init() {
        super.init(frame: .zero)
        initialize()
    }
    
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
