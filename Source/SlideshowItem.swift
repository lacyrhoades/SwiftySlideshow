//
//  SlideshowItem.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

public typealias SlideshowItemLoadCompletionBlock = ([Data]) -> ()
public typealias MediaFetchBlock = ((_: @escaping SlideshowItemLoadCompletionBlock) -> ())

public enum SlideshowItemType {
    case image
    case video
}

public struct SlideshowItem {
    var id: SlideshowItemID
    var type: SlideshowItemType
    var fetchMediaDatas: MediaFetchBlock? = nil
    
    public init(id: SlideshowItemID, type: SlideshowItemType, fetch: @escaping MediaFetchBlock) {
        self.id = id
        self.type = type
        self.fetchMediaDatas = fetch
    }
}

extension SlideshowItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id.string)
    }
}

extension SlideshowItem: Equatable {
    public static func ==(lhs: SlideshowItem, rhs: SlideshowItem) -> Bool {
        return lhs.id == rhs.id
    }
}
