//
//  SlideshowItem.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

typealias SlideshowItemLoadCompletionBlock = ([Data]) -> ()
typealias MediaFetchBlock = ((_: @escaping SlideshowItemLoadCompletionBlock) -> ())

enum SlideshowItemType {
    case image
    case video
}

struct SlideshowItem {
    var id: String
    var type: SlideshowItemType
    var fetchMediaDatas: MediaFetchBlock? = nil
    
    init(id: String, type: SlideshowItemType, fetch: @escaping MediaFetchBlock) {
        self.id = id
        self.type = type
        self.fetchMediaDatas = fetch
    }
}

extension SlideshowItem: Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }
}

extension SlideshowItem: Equatable {
    static func ==(lhs: SlideshowItem, rhs: SlideshowItem) -> Bool {
        return lhs.id == rhs.id
    }
}
