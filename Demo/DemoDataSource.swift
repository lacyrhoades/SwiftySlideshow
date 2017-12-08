//
//  DemoDataSource.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation
import Photos

class DemoDataSource: SlideshowControllerDataSource {
    var assetIDs: [String] = []
    
    var isEmpty: Bool {
        return self.assetIDs.isEmpty
    }
    
    func slideshowItemID(afterID: String) -> String? {
        if let id = self.assetIDs.after(afterID) {
            return id
        }
        
        return self.assetIDs.first
    }
    
    func slideshowItem(afterID: String?) -> SlideshowItem? {
        var maybeID: String? = nil
        
        if let afterID = afterID {
            maybeID = self.slideshowItemID(afterID: afterID)
        } else {
            maybeID = self.assetIDs.first
        }
        
        guard let nextID = maybeID else {
            return nil
        }
        
        guard let asset: PHAsset = AssetFetcher.asset(forAssetID: nextID) else {
            return nil
        }
        
        guard let type = SlideshowItem.type(forMediaType: asset.mediaType) else {
            assert(false, "Invalid PHAsset mediaType! Only image and video are supported for slideshow :)")
            return nil
        }
        
        return SlideshowItem(id: nextID, type: type, fetch: { (done) in
            AssetFetcher.slideshowItemData(forAsset: asset, withItemType: type) {
                datas in
                
                done(datas)
                
            }
        })
    }
}
