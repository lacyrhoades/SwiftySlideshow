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
    let slideshowView = UIImageView()
    
    convenience init(withBlankImage image: UIImage?) {
        self.init(nibName: nil, bundle: nil)
        
        self.slideshowView.contentMode = .scaleAspectFit
        self.slideshowView.image = image
        
        wrapperView = RotatingWrapperView(slideshowView)
    }
    
    var wrapperView: RotatingWrapperView!
    
    override func loadView() {
        view = wrapperView
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = SlideshowController.slideBackgroundColor
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

class RotatingWrapperView: UIView {
    var wrapped: UIView
    
    var onRotate: (() -> ())? = nil
    
    init(_ wrappedView: UIView) {
        wrapped = wrappedView
        
        super.init(frame: .zero)
        
        self.addSubview(wrappedView)
        wrappedView.frame = self.bounds
        wrappedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var rotation: SlideshowController.Orientation = .normal {
        didSet {
            var transform: CGAffineTransform
            var flipped = false
            
            switch rotation {
            case .normal:
                transform = CGAffineTransform(rotationAngle: 0.0)
            case .upsideDown:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            case .left:
                flipped = true
                transform = CGAffineTransform(rotationAngle: CGFloat.pi * 3.0 / 2.0)
            case .right:
                flipped = true
                transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1.0 / 2.0)
            }
            
            DispatchQueue.main.async {
                self.wrapped.transform = CGAffineTransform.identity
                
                if flipped {
                    self.wrapped.frame = self.bounds.flipped
                } else {
                    self.wrapped.frame = self.bounds
                }
                
                self.wrapped.transform = transform
                
                self.onRotate?()
            }
        }
    }
}

extension CGRect {
    public var flipped: CGRect {
        let xOffset = (width - height) / 2.0
        let yOffset = (height - width) / 2.0
        
        return CGRect(x: xOffset, y: yOffset, width: self.size.height, height: self.size.width)
    }
}
