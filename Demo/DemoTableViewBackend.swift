//
//  DemoTableViewBackend.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 12/7/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Photos

class DemoTableViewBackend: NSObject {
    static func setup(tableView: UITableView) {
        tableView.allowsMultipleSelection = true
        tableView.register(AssetCell.self, forCellReuseIdentifier: AssetCell.identifier)
    }
    
    var selectedChanged: (() -> ())?
    var assetsChanged: (() -> ())?
    
    var allAssets: PHFetchResult<PHAsset>?
    
    func assetID(at index: IndexPath) -> String? {
        guard let assets = self.allAssets else {
            return nil
        }
        
        guard index.row < assets.count else {
            return nil
        }
        
        return assets[index.row].localIdentifier
    }
    
    func refresh() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.allAssets = PHAsset.fetchAssets(with: options)
        assetsChanged?()
    }
    
    var selected: Set<IndexPath> = Set()
    var selectedAssetIDs: [String] {
        return selected.sorted().reversed().compactMap({ (eachIndex) -> String? in
            return self.assetID(at: eachIndex)
        })
    }
}

extension DemoTableViewBackend: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected.insert(indexPath)
        self.selectedChanged?()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selected.remove(indexPath)
        self.selectedChanged?()
    }
}

extension DemoTableViewBackend: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAssets?.count ?? 0
    }
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AssetCell.identifier)!
        
        if cell.tag != 0 {
            let fetchID = cell.tag
            (PHCachingImageManager.default() as? PHCachingImageManager)?.cancelImageRequest(PHImageRequestID(fetchID))
        }
        
        if let assetID = self.assetID(at: indexPath) {
            let fetchID = DemoTableViewBackend.fetchThumbnail(forID: assetID, size: CGSize(width: 200, height: 200)) { (thumbnail, date) in
                cell.imageView?.image = thumbnail
                if let date = date {
                    cell.textLabel?.text = DemoTableViewBackend.dateFormatter.string(from: date)
                } else {
                    cell.textLabel?.text = "Unknown Date"
                }
                cell.setNeedsLayout()
            }
            
            cell.tag = Int(fetchID ?? 0)
        }
        
        return cell
    }
    
    static func fetchThumbnail(forID assetID: String, size: CGSize?, andThen: @escaping (_: UIImage?, _: Date?) -> ()) -> PHImageRequestID? {
        
        let options = PHFetchOptions()
        let request = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: options)
        
        guard let asset = request.firstObject else {
            DispatchQueue.main.async {
                andThen(nil, nil)
            }
            return nil
        }
        
        let size = size ?? CGSize(width: 100, height: 100)
        
        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isNetworkAccessAllowed = true
        fetchOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        fetchOptions.isSynchronous = false
        
        let imageRequest = (PHCachingImageManager.default() as? PHCachingImageManager)?.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: fetchOptions) { (maybeImage, info) in
            DispatchQueue.main.async {
                andThen(maybeImage, asset.creationDate)
            }
        }
        
        return imageRequest
    }
}

