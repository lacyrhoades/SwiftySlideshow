//
//  SlideshowItem+Photos.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 12/7/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Photos

extension SlideshowItem {
    public static func type(forMediaType mediaType: PHAssetMediaType) -> SlideshowItemType? {
        switch mediaType {
        case .image:
            return .image
        case .video:
            return .video
        default:
            return nil
        }
    }
}
