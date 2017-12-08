//
//  SlideshowViewController.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

class SlideshowViewController: UIViewController {
    fileprivate(set) var window: UIView?
    fileprivate let slideshowView = UIImageView()
    
    convenience init(withBlankImage image: UIImage?) {
        self.init(nibName: nil, bundle: nil)
        self.slideshowView.contentMode = .scaleAspectFit
        self.slideshowView.image = image
    }
    
    override func viewDidLoad() {
        view.addAutoSubview(self.slideshowView)
        Layout.pinAllSides(of: slideshowView, to: view, in: view)
    }
}

extension SlideshowViewController {
    func attach(toScreen screen: UIScreen) {
        screen.overscanCompensation = .none
        let window = UIWindow(frame: screen.bounds)
        window.isHidden = false
        window.rootViewController = self
        window.screen = screen
        self.window = window
    }
    
    func detach(fromScreen: UIScreen) {
        self.window?.isHidden = true;
        self.window = nil;
    }
    
    func attach(toView: UIView) {
        guard let ourView = self.view else {
            return
        }
        self.window = ourView
        toView.addAutoSubview(ourView)
        Layout.pinAllSides(of: ourView, to: toView, in: toView)
    }
    
    func deteach(fromView view: UIView) {
        self.window?.isHidden = true
        self.window = nil
    }
}
