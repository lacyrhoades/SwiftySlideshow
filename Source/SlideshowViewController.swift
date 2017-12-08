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
        slideshowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slideshowView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: slideshowView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slideshowView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slideshowView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slideshowView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            ])
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
        ourView.translatesAutoresizingMaskIntoConstraints = false
        toView.addSubview(ourView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: ourView, attribute: .leading, relatedBy: .equal, toItem: toView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ourView, attribute: .trailing, relatedBy: .equal, toItem: toView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ourView, attribute: .top, relatedBy: .equal, toItem: toView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ourView, attribute: .bottom, relatedBy: .equal, toItem: toView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    func deteach(fromView view: UIView) {
        self.window?.isHidden = true
        self.window = nil
    }
}
