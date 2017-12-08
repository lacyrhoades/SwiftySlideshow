//
//  SlideshowController.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

public protocol SlideshowControllerDelegate: class {
    var screenCount: Int { get set }
}

public protocol SlideshowControllerDataSource: class {
    var isEmpty: Bool {get}
    func slideshowItemID(afterID: String) -> String?
    func slideshowItem(afterID: String?) -> SlideshowItem?
}

public class SlideshowController {
    public static var defaultSlideDuration: TimeInterval = 10.0
    public static var defaultTransitionDuration: TimeInterval = 1.0
    public static var slideBackgroundColor: UIColor = .white
    
    var dataSource: SlideshowControllerDataSource {
        return self.slideTransitionCoordinator.slideshowDataSource
    }
    
    var delegate: SlideshowControllerDelegate?
    
    fileprivate var slideTransitionCoordinator: SlideshowTransitionCoordinator
    
    fileprivate var defaultImage: UIImage?
    
    fileprivate var timer = SlideshowTimer()
    
    public init(dataSource: SlideshowControllerDataSource, defaultImage image: UIImage?) {
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
    public func attach(toScreen screen: UIScreen) {
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
    
    public func detach(fromScreen screen: UIScreen) {
        guard self.slideTransitionCoordinator.fullscreenViews[screen] != nil else {
            return
        }
        
        self.slideTransitionCoordinator.removeSlidehow(forScreen: screen)
        
        self.delegate?.screenCount -= 1
    }
    
    public func attach(toView view: UIView) {
        guard self.slideTransitionCoordinator.frameViews.contains(view) == false else {
            return
        }
        
        if let image = self.defaultImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                ])
        }
        
        self.slideTransitionCoordinator.add(slideshowInView: view)
        
        self.unpause()
        
        self.delegate?.screenCount += 1
    }
    
    public func detach(fromView view: UIView) {
        guard self.slideTransitionCoordinator.frameViews.contains(view) else {
            return
        }
        
        self.slideTransitionCoordinator.removeSlideshow(forView: view)
        self.delegate?.screenCount -= 1
    }
    
    public func detachAll() {
        self.slideTransitionCoordinator.removeAllSlideshows()
        self.delegate?.screenCount = 0
    }
}
