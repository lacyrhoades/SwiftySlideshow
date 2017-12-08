//
//  SlideshowSlide.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

struct SlideshowSlide {
    var item: SlideshowItem
    var imageView: UIView
    var constraint: NSLayoutConstraint
    var duration: TimeInterval = SlideshowController.defaultSlideDuration
    var transitionDuration: TimeInterval = SlideshowController.defaultTransitionDuration
    
    init(item: SlideshowItem, imageView: UIView, constraint: NSLayoutConstraint) {
        self.item = item
        self.imageView = imageView
        self.constraint = constraint
    }
    
    var waitGroup = DispatchGroup()
    
    func prepareToAppear() {
        self.waitGroup.enter()
        self.item.fetchMediaDatas?() {
            datas in
            
            defer {
                self.waitGroup.leave()
            }
            
            guard let data = datas.first else {
                DispatchQueue.main.async {
                    self.imageView.backgroundColor = .clear
                }
                return
            }
            
            if let imageView = self.imageView as? UIImageView,
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else if let videoView = self.imageView as? WebVideoView {
                videoView.playFrom(data: data)
            }
        }
    }
    
    func startPlaying() {
        let result = self.waitGroup.wait(timeout: DispatchTime.now() + 1.0)
        
        switch result {
        case .success:
            break
        case .timedOut:
            assert(false, "startPlaying() did time out")
        }
        
        if let videoView = self.imageView as? WebVideoView {
            DispatchQueue.main.async {
                videoView.play()
            }
        }
    }
}
