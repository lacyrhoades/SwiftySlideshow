//
//  AssetFetcher.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 12/7/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Photos
import AVFoundation

class AssetFetcher {
    public static func asset(forAssetID assetID: AssetID) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [assetID.rawValue], options: nil).firstObject
    }
    
    public static func slideshowItemData(forAsset asset: PHAsset, withItemType itemType: SlideshowItemType, andThen: @escaping SlideshowItemLoadCompletionBlock) {
        switch itemType {
        case .image:
            AssetFetcher.imageData(forAsset: asset, andThen: andThen)
        case .video:
            AssetFetcher.videoData(forAsset: asset, andThen: andThen)
        }
    }
    
    private static func imageData(forAsset asset: PHAsset, andThen: @escaping SlideshowItemLoadCompletionBlock) {
        PHImageManager.default().requestImageData(for: asset, options: nil) { (maybeData, _, _, _) in
            if let data = maybeData {
                andThen([data])
            } else {
                andThen([])
            }
        }
    }
    
    private static func videoData(forAsset asset: PHAsset, andThen: @escaping SlideshowItemLoadCompletionBlock) {
        
        let options = PHVideoRequestOptions()
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset, _, _) in
            guard let avAsset = avAsset else {
                assert(false, "Nil asset from manager")
                return
            }
            
            guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality) else {
                assert(false, "Cannot create export sesssion")
                return
            }
            
            let filename = asset.localIdentifier.replacingOccurrences(of: "/", with: "-") .appending(".mov")
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let tempFileURL = url.appendingPathComponent(filename)
            
            if FileManager.default.fileExists(atPath: tempFileURL.path) {
                do {
                    let data = try Data(contentsOf: tempFileURL)
                    andThen([data])
                    return
                } catch {
                    assert(false, "Data was corrupted on disk")
                }
            }
            
            exportSession.outputURL = tempFileURL
            exportSession.outputFileType = .mov
            
            exportSession.exportAsynchronously {
                if exportSession.status == AVAssetExportSessionStatus.completed {
                    do {
                        let data = try Data(contentsOf: tempFileURL)
                        andThen([data])
                    } catch {
                        assert(false, "Invalid data back from export session")
                    }
                } else {
                    assert(false, "Export session did not complete")
                }
            }
        })
    }
}
