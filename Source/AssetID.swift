//
//  AssetID.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 4/9/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import Foundation

struct AssetID: Hashable {
    private let rawValue: String
    
    var string: String {
        return self.rawValue
    }
    
    var hashValue: Int {
        return self.rawValue.hashValue
    }
    
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    init?(_ rawValue: String?) {
        guard let val = rawValue else {
            return nil
        }
        
        self.init(val)
    }
}
