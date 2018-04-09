//
//  AssetID.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 4/9/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import Foundation

struct AssetID: Hashable {
    var rawValue: String
    
    var hashValue: Int {
        return self.rawValue.hashValue
    }
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    init?(rawValue: String?) {
        guard let val = rawValue else {
            return nil
        }
        
        self.init(rawValue: val)
    }
}
