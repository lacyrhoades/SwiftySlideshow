//
//  SlideshowController.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

protocol SlideshowControllerDelegate: class {
    var screenCount: Int { get set }
}

protocol SlideshowControllerDataSource: class {
    var isEmpty: Bool {get}
    func slideshowItemID(afterID: String) -> String?
    func slideshowItem(afterID: String?) -> SlideshowItem?
}

class SlideshowController {
    static var defaultSlideDuration: TimeInterval = 10.0
    static var defaultTransitionDuration: TimeInterval = 1.0
    
    var dataSource: SlideshowControllerDataSource {
        return self.slideTransitionCoordinator.slideshowDataSource
    }
    
    var delegate: SlideshowControllerDelegate?
    
    fileprivate var slideTransitionCoordinator: SlideshowTransitionCoordinator
    
    fileprivate var defaultImage: UIImage?
    
    fileprivate var timer = SlideshowTimer()
    
    init(dataSource: SlideshowControllerDataSource, defaultImage image: UIImage?) {
        self.defaultImage = image
        
        self.slideTransitionCoordinator = SlideshowTransitionCoordinator(dataSource: dataSource)
        
        self.timer.fireBlock = {
            self.slideTransitionCoordinator.showNextSlide() {
                delay in
                self.timer.go(withDelay: delay)
            }
        }
    }
    
    func changeTo(duration: TimeInterval) {
        SlideshowController.defaultSlideDuration = duration
        self.pause()
        self.unpause()
    }
    
    fileprivate func pause() {
        self.timer.stop()
    }
    
    fileprivate func unpause() {
        if (self.timer.isPaused) {
            self.timer.go(withDelay: SlideshowController.defaultSlideDuration)
        }
    }
    
    func resetToBlank() {
        self.pause()
        self.slideTransitionCoordinator.removeAllSlides()
    }
}

extension SlideshowController {
    func attach(toScreen screen: UIScreen) {
        guard self.slideTransitionCoordinator.fullscreenViews[screen] == nil else {
            return
        }
        
        screen.overscanCompensation = .none
        let window = UIWindow(frame: screen.bounds)
        window.isHidden = false
        window.rootViewController = SlideshowViewController(withBlankImage: self.defaultImage)
        window.screen = screen
        self.slideTransitionCoordinator.add(slideshowInView: window, forScreen: screen)
        
        self.unpause()
        
        self.delegate?.screenCount += 1
    }
    
    func detach(fromScreen screen: UIScreen) {
        guard self.slideTransitionCoordinator.fullscreenViews[screen] != nil else {
            return
        }
        
        self.slideTransitionCoordinator.removeSlidehow(forScreen: screen)
        
        self.delegate?.screenCount -= 1
    }
    
    func attach(toView view: UIView) {
        guard self.slideTransitionCoordinator.frameViews.contains(view) == false else {
            return
        }
        
        if let image = self.defaultImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            view.addAutoSubview(imageView)
            Layout.pinAllSides(of: imageView, to: view, in: view)
        }
        
        self.slideTransitionCoordinator.add(slideshowInView: view)
        
        self.unpause()
        
        self.delegate?.screenCount += 1
    }
    
    func detach(fromView view: UIView) {
        guard self.slideTransitionCoordinator.frameViews.contains(view) else {
            return
        }
        
        self.slideTransitionCoordinator.removeSlideshow(forView: view)
        self.delegate?.screenCount -= 1
    }
    
    func detachAll() {
        self.slideTransitionCoordinator.removeAllSlideshows()
        self.delegate?.screenCount = 0
    }
}
