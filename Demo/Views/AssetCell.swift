//
//  AssetCell.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 12/7/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

class AssetCell: UITableViewCell {
    static let identifier: String = "AssetCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var isDownloading: Bool = false {
        didSet {
            self.backgroundColor = isDownloading ? .lightGray : .white
        }
    }
}
