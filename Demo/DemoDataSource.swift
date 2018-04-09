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
    private var assetIDs: [AssetID] = []
    
    public func setAssetIDs(_ newValue: [String]) {
        self.assetIDs = newValue.map({ (eachID) -> AssetID in
            return AssetID(eachID)
        })
    }
    
    var isEmpty: Bool {
        return self.assetIDs.isEmpty
    }
    
    func slideshowItemID(afterID: SlideshowItemID) -> SlideshowItemID? {
        let assetID = AssetID(afterID.string)
        
        if let next = self.assetIDs.after(assetID)?.string {
            return SlideshowItemID(next)
        }
        
        return SlideshowItemID(self.assetIDs.first?.string)
    }
    
    func slideshowItem(afterID: SlideshowItemID?) -> SlideshowItem? {
        
        // The asset the slideshow has now
        let maybeAssetID = AssetID(afterID?.string)
        
        // The next asset in our list
        var nextAssetID: AssetID?
        
        // If the slideshow asked for an asset
        if let assetID = maybeAssetID {
            // look for next
           nextAssetID = self.assetIDs.after(assetID)
        }
        
        // If we found nothing
        if nextAssetID == nil {
            // go with first
            nextAssetID = self.assetIDs.first
        }
        
        // Did we find anything at all?
        guard let someAssetID = nextAssetID else {
            return nil
        }
        
        // Can the AssetFetcher provide this data?
        guard let asset: PHAsset = AssetFetcher.asset(forAssetID: someAssetID) else {
            return nil
        }
        
        // Recognized type?
        guard let type = SlideshowItem.type(forMediaType: asset.mediaType) else {
            assert(false, "Invalid PHAsset mediaType! Only image and video are supported for slideshow :)")
            return nil
        }
        
        // Build and return the item
        let id = SlideshowItemID(someAssetID.string)
        return SlideshowItem(id: id, type: type, fetch: { (done) in
            AssetFetcher.slideshowItemData(forAsset: asset, withItemType: type) {
                datas in
                
                done(datas)
                
            }
        })
    }
}
