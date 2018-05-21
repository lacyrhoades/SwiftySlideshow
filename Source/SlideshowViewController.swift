//
//  SlideshowViewController.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

class SlideshowViewController: UIViewController {
    var window: UIView?
    fileprivate let slideshowView = UIImageView()
    
    convenience init(withBlankImage image: UIImage?) {
        self.init(nibName: nil, bundle: nil)
        self.slideshowView.contentMode = .scaleAspectFit
        self.slideshowView.image = image
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = SlideshowController.slideBackgroundColor
        
        slideshowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slideshowView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: slideshowView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slideshowView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slideshowView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slideshowView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("viewWillTransitionToSize")
    }
}
