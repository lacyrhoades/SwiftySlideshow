//
//  SlideshowController.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

public struct ExternalScreen {
    public var description: String
    
    init(_ screen: UIScreen) {
        let size = screen.currentMode?.size ?? .zero
        self.description = String(format: "AirPlay: %.0fx%.0f", size.width, size.height)
    }
    
    init(_ view: UIView) {
        self.description = String(format: "Preview Screen")
    }
}

public protocol SlideshowControllerDelegate: AnyObject {
    var screenCount: Int { get set }
    func addedScreen(_ screen: ExternalScreen)
    func removedScreen(_ screen: ExternalScreen)
    func removedAllScreens()
}

public protocol SlideshowControllerDataSource: AnyObject {
    var isEmpty: Bool {get}
    func slideshowItemID(afterID: SlideshowItemID) -> SlideshowItemID?
    func slideshowItem(afterID: SlideshowItemID?) -> SlideshowItem?
}

public class SlideshowController {
    public enum Orientation: String, Codable, CustomStringConvertible {
        case normal
        case upsideDown
        case left
        case right
        
        public var description: String {
            switch self {
            case .normal:
                return "Normal"
            case .upsideDown:
                return "Rotate 180°"
            case .right:
                return "Rotate 90° CW"
            case .left:
                return "Rotate 90° CCW"
            }
        }
    }
    
    public static var defaultSlideDuration: TimeInterval = 10.0
    public static var defaultTransitionDuration: TimeInterval = 1.0
    public static var slideBackgroundColor: UIColor = .white
    
    public var rotation = Orientation.normal {
        didSet {
            for window in UIApplication.shared.windows {
                if let slideshowVC = window.rootViewController as? SlideshowViewController {
                    slideshowVC.wrapperView.rotation = rotation
                }
            }
        }
    }
    
    public var dataSource: SlideshowControllerDataSource {
        return self.slideTransitionCoordinator.slideshowDataSource
    }
    
    weak public var delegate: SlideshowControllerDelegate?
    
    fileprivate var slideTransitionCoordinator: SlideshowTransitionCoordinator
    
    fileprivate var defaultImage: UIImage?
    
    fileprivate var timer = SlideshowTimer()
    
    fileprivate var screenWatcher: ScreenWatcher?
    
    public init(dataSource: SlideshowControllerDataSource, defaultImage image: UIImage?) {
        self.defaultImage = image
        
        self.slideTransitionCoordinator = SlideshowTransitionCoordinator(dataSource: dataSource)
        
        self.timer.fireBlock = {
            self.slideTransitionCoordinator.showNextSlide() {
                delay in
                self.timer.go(withDelay: delay)
            }
        }
        
        self.screenWatcher = ScreenWatcher(notify: self)
    }
    
    public func changeTo(duration: TimeInterval) {
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
        // without a brief delay here, the screen image will "underscan" sometimes
        // underscannig leaves a blank / black border at the edges of the screen
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {

            guard self.slideTransitionCoordinator.fullscreenViews[screen] == nil else {
                return
            }
            
            screen.overscanCompensation = .none
            
            let window = UIWindow(frame: screen.bounds)
            window.isHidden = false
            let vc = SlideshowViewController(withBlankImage: self.defaultImage)
            vc.wrapperView.rotation = self.rotation
            vc.window = window
            window.rootViewController = vc
            window.screen = screen
            
            self.slideTransitionCoordinator.add(slideshowInView: vc.slideshowView, forScreen: screen)
            
            self.unpause()
            
            self.delegate?.screenCount += 1
            self.delegate?.addedScreen(ExternalScreen(screen))
            
        }
    }
    
    public func detach(fromScreen screen: UIScreen) {
        guard self.slideTransitionCoordinator.fullscreenViews[screen] != nil else {
            return
        }
        
        self.slideTransitionCoordinator.removeSlidehow(forScreen: screen)
        
        self.delegate?.screenCount -= 1
        self.delegate?.removedScreen(ExternalScreen(screen))
    }
    
    public func isAttached(toView view: UIView) -> Bool {
        return self.slideTransitionCoordinator.frameViews.contains(view)
    }
    
    public func attach(toView view: UIView) {
        guard self.isAttached(toView: view) == false else {
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
        self.delegate?.addedScreen(ExternalScreen(view))
    }
    
    public func detach(fromView view: UIView) {
        guard self.isAttached(toView: view) else {
            return
        }
        
        self.slideTransitionCoordinator.removeSlideshow(forView: view)
        self.delegate?.screenCount -= 1
        self.delegate?.removedScreen(ExternalScreen(view))
    }
    
    public func detachAll() {
        self.slideTransitionCoordinator.removeAllSlideshows()
        self.delegate?.screenCount = 0
        self.delegate?.removedAllScreens()
    }
}

extension SlideshowController: ExternalScreenDelegateProtocol {
    public func attachSlideshowController(toScreens screens: [UIScreen]) {
        var screenIndex = 0
        for screen in screens {
            defer {
                screenIndex += 1
            }
            
            guard screenIndex > 0 else {
                continue
            }
            
            self.attachSlideshowController(toScreen: screen)
        }
    }
    
    public func detachSlideshowController() {
        self.detachAll()
    }
    
    public func attachSlideshowController(toScreen screen: UIScreen) {
        self.attach(toScreen: screen)
    }
    
    public func detachSlideshowController(fromScreen screen: UIScreen) {
        self.detach(fromScreen: screen)
    }
}
