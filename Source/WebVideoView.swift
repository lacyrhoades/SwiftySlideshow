//
//  WebVideoView.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit
import AVFoundation

public typealias OnPlayBlock = () -> ()

public class WebVideoView: UIView {
    var player: AVQueuePlayer?
    var playerLooper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    
    public var naturalSize: CGSize? {
        return self.player?.currentItem?.asset.tracks(withMediaType: AVMediaType.video).first?.naturalSize
    }
    
    private static let dataParseQueue = DispatchQueue.global(qos: .utility)

    private var observerContext = 0
    
    convenience init(data: Data) {
        self.init(frame: CGRect.zero)
        WebVideoView.dataParseQueue.async {
            self.playFrom(data: data)
        }
    }
    
    deinit {
        self.player?.removeObserver(self, forKeyPath: "status", context: &observerContext)
    }
    
    public func playFrom(data: Data) {
        let tempPath = NSTemporaryDirectory().appending(
            String(format: "%d.mov", data.hashValue)
        )
        
        let fileURL = URL(fileURLWithPath: tempPath)
        
        if FileManager.default.fileExists(atPath: tempPath) == false {
            do {
                try data.write(to: fileURL, options: .atomic)
            } catch {
                return
            }
        }
        
        DispatchQueue.main.async {
            self.playFrom(url: fileURL)
        }
    }
    
    func playFrom(url: URL) {
        self.player?.pause()
        self.playerLayer?.removeFromSuperlayer()
        
        self.player = nil
        self.playerLayer = nil
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(items: [item])
        self.player = player
        
        self.playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        player.addObserver(
            self,
            forKeyPath: "status",
            options: .new,
            context: &self.observerContext
        )
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        self.playerLayer = playerLayer
        player.seek(to: kCMTimeZero)
        playerLayer.frame = self.layer.bounds
        self.layer.insertSublayer(playerLayer, at: 0)
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
    }
    
    var wantsToPlay: Bool = false
    var onPlay: ActionBlock? = nil
    public func play(andThen: OnPlayBlock? = nil) {
        self.wantsToPlay = true
        
        guard let player = player else {
            if andThen != nil {
                onPlay = andThen
            }
            return
        }
        
        switch player.status {
        case .readyToPlay:
            player.play()
            onPlay?()
            onPlay = nil
        case .failed:
            return
        case.unknown:
            return
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if (wantsToPlay && keyPath == "status") {
            if let newValue = change![.newKey] as? Int, AVPlayerStatus(rawValue: newValue) == AVPlayerStatus.readyToPlay {
                self.play()
            }
        }
    }
}

