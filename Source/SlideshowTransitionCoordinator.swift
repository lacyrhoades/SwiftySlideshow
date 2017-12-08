//
//  SlideshowTransitionCoordinator.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

class SlideshowTransitionCoordinator {
    fileprivate var oldSlides: [SlideshowSlide] = []
    fileprivate var currentSlides: [SlideshowSlide] = []
    fileprivate var nextSlides: [SlideshowSlide] = []
    
    var assetPreloadQueue = DispatchQueue(label: "com.fobo.slideshow.PreLoadAssets")
    var assetStartPlayingQueue = DispatchQueue(label: "com.fobo.slideshow.StartPlayingAsset")
    
    var slideshowDataSource: SlideshowControllerDataSource {
        didSet {
            self.nextSlides = self.makeNextSlides(afterID: nil)
        }
    }
    
    init(dataSource: SlideshowControllerDataSource) {
        self.slideshowDataSource = dataSource
    }
    
    fileprivate(set) var frameViews: [UIView] = []
    fileprivate(set) var fullscreenViews: [UIScreen: UIView] = [:]
    
    func add(slideshowInView view: UIView) {
        self.frameViews.append(view)
    }
    
    func removeSlideshow(forView view: UIView) {
        if self.frameViews.contains(view) {
            view.removeFromSuperview()
        }
        self.frameViews = self.frameViews.filter({ (eachView) -> Bool in
            eachView != view
        })
    }
    
    func add(slideshowInView view: UIView, forScreen screen: UIScreen) {
        self.frameViews.append(view)
        self.fullscreenViews[screen] = view
    }
    
    func removeSlidehow(forScreen screen: UIScreen) {
        if let view = self.fullscreenViews[screen] {
            view.isHidden = true
            self.frameViews = self.frameViews.filter({ (eachView) -> Bool in
                eachView != view
            })
            view.removeFromSuperview()
        }
        self.fullscreenViews[screen] = nil
    }
    
    func removeAllSlides() {
        for slide in oldSlides {
            slide.imageView.removeFromSuperview()
        }
        for slide in currentSlides {
            slide.imageView.removeFromSuperview()
        }
        for slide in nextSlides {
            slide.imageView.removeFromSuperview()
        }
        
        oldSlides.removeAll()
        oldSlides = []
        currentSlides.removeAll()
        currentSlides = []
        nextSlides.removeAll()
        nextSlides = []
    }
    
    func removeAllSlideshows() {
        for (_, view) in self.fullscreenViews {
            view.isHidden = true
            self.frameViews = self.frameViews.filter({ (eachView) -> Bool in
                return eachView != view
            })
            view.removeFromSuperview()
        }
        self.fullscreenViews.removeAll()
    }
    
    // 1. Destroy/hide the OLD slide
    // 2. NEXT becomes CURRENT, CURRENT becomes OLD
    // 3. Create NEXT and start loading it
    // 4. Animate CURRENT into position
    // 5. Call completion
    func showNextSlide(andThen: @escaping (_: TimeInterval) -> ()) {
        // 1.
        for oldSlide in self.oldSlides {
            oldSlide.imageView.removeFromSuperview()
        }
        self.oldSlides.removeAll()
        
        // 2.
        oldSlides = currentSlides
        currentSlides = nextSlides
        
        // 3.
        nextSlides = self.makeNextSlides(afterID: self.currentSlides.first?.item.id)
        for slide in self.nextSlides {
            self.assetPreloadQueue.async {
                slide.prepareToAppear()
            }
        }
        
        // 4.
        let waitGroup = DispatchGroup()
        
        for currentSlide in self.currentSlides {
            waitGroup.enter()
            self.assetStartPlayingQueue.async {
                currentSlide.startPlaying()
                DispatchQueue.main.async {
                    currentSlide.constraint.constant = 0
                    UIView.animate(withDuration: self.transitionDuration, animations: {
                        currentSlide.imageView.superview?.layoutIfNeeded()
                    }) { (done) in
                        waitGroup.leave()
                    }
                }
            }
        }
        
        waitGroup.notify(queue: DispatchQueue.main) {
            andThen(self.currentSlideDuration)
        }
        
    }
    
    private var currentSlideDuration: TimeInterval {
        return self.currentSlides.first?.duration ?? SlideshowController.defaultSlideDuration
    }
    
    private var transitionDuration: TimeInterval {
        return self.currentSlides.first?.transitionDuration ?? SlideshowController.defaultTransitionDuration
    }
    
    private func makeNextSlides(afterID current: String?) -> [SlideshowSlide] {
        guard self.slideshowDataSource.isEmpty == false else {
            return []
        }
        
        guard let item = self.slideshowDataSource.slideshowItem(afterID: current) else {
            if let current = current {
                let next = self.slideshowDataSource.slideshowItemID(afterID: current)
                if next != current {
                    return self.makeNextSlides(afterID: next)
                }
            }
            
            return []
        }
        
        var results: [SlideshowSlide] = []
        
        for frameView in self.frameViews {
            let mediaView = self.mediaView(forItem: item)
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            frameView.addSubview(mediaView)
            
            #if DEBUG
            mediaView.layer.borderWidth = 2.0
            mediaView.layer.borderColor = UIColor.purple.cgColor
            #endif
            
            let centerYConstraint = NSLayoutConstraint(item: mediaView, attribute: .centerY, relatedBy: .equal, toItem: frameView, attribute: .centerY, multiplier: 1, constant: frameView.bounds.height * -1)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: mediaView, attribute: .height, relatedBy: .equal, toItem: frameView, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: mediaView, attribute: .width, relatedBy: .equal, toItem: frameView, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: mediaView, attribute: .centerX, relatedBy: .equal, toItem: frameView, attribute: .centerX, multiplier: 1, constant: 0)
            ])
            frameView.addConstraint(centerYConstraint)
            frameView.layoutIfNeeded()
            
            results.append(SlideshowSlide(item: item, imageView: mediaView, constraint: centerYConstraint))
        }
        
        return results
    }
    
    private func mediaView(forItem item: SlideshowItem) -> UIView {
        switch item.type {
        case .image:
            let imageView = UIImageView()
            imageView.backgroundColor = .white
            imageView.contentMode = .scaleAspectFit
            return imageView
        case .video:
            let mediaView = WebVideoView()
            mediaView.backgroundColor = .white
            return mediaView
        }
    }
}
