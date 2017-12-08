//
//  NibView.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 12/7/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

class NibView: UIView {
    var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView = loadNib()
        addAutoSubview(contentView)
        Layout.pinAllSides(of: contentView, to: self, in: self)
    }
    
    private func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            return view
        } else {
            fatalError("Cannot find nib named \(nibName)")
        }
    }
}
