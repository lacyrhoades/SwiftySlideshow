//
//  SlideshowItemID.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 4/9/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import Foundation

public struct SlideshowItemID: Hashable, Equatable {
    private let rawValue: String
    
    public var string: String {
        return rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    init?(_ rawValue: String?) {
        guard let val = rawValue else {
            return nil
        }
        
        self.init(val)
    }
    
    public static func == (lhs: SlideshowItemID, rhs: SlideshowItemID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public var hashValue: Int {
        return self.rawValue.hashValue
    }
}

