//
//  ViewController.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    @IBOutlet var previewLabel: UILabel?
    @IBOutlet var statusLabel: UILabel?
    @IBOutlet var rotateButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var selectionLabel: UILabel?
    
    @IBOutlet var previewView: DemoPreviewView?
    @IBOutlet var tableView: UITableView?
    
    var rotation: UIInterfaceOrientation = .portrait
    
    @objc func didTapRotate(_ button: UIButton) {
        switch rotation {
        case .portrait:
            rotation = .landscapeRight
        case .landscapeRight:
            rotation = .portraitUpsideDown
        case .portraitUpsideDown:
            rotation = .landscapeLeft
        case .landscapeLeft:
            rotation = .portrait
        case .unknown:
            rotation = .portrait
        }
        
        rotateButton?.setTitle(self.rotateButtonTitle, for: .normal)
        
        (UIApplication.shared.delegate as? DemoAppDelegate)?.slideshowController?.rotation = rotation
    }
    
    @objc func didTapReset(_ button: UIButton) {
        button.isEnabled = false
        (UIApplication.shared.delegate as? DemoAppDelegate)?.resetExternalScreens() {
            button.isEnabled = true
        }
    }
    
    @objc func didTapStart() {
        self.previewView?.startButton?.isHidden = true
        if let previewView = self.previewView?.innerView,
            let slideshowController = (UIApplication.shared.delegate as? DemoAppDelegate)?.slideshowController {
            slideshowController.attach(toView: previewView)
        }
    }
    
    var slideshowDataSource: DemoDataSource?
    private var backend = DemoTableViewBackend()
    
    var numberOfScreens: Int = 0 {
        didSet {
            var text: String
            
            switch numberOfScreens {
            case 0:
                text = "Slideshow is not playing"
            default:
                text = String(format: "Slideshow is playing on %d screens", numberOfScreens)
            }
            
            DispatchQueue.main.async {
                self.statusLabel?.text = text
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewLabel?.text = "Slideshow preview:"
        statusLabel?.text = "Slideshow is not playing"
        resetButton?.setTitle("Reset external displays", for: .normal)
        self.updateSelectionLabel()
        
        if let tableView = tableView {
            DemoTableViewBackend.setup(tableView: tableView)
            tableView.delegate = backend
            tableView.dataSource = backend
            
            backend.assetsChanged = {
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        backend.selectedChanged = {
            self.updateSelectionLabel()
            self.slideshowDataSource?.setAssetIDs(self.backend.selectedAssetIDs)
        }
        
        previewView?.startButton?.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        
        rotateButton?.addTarget(self, action: #selector(didTapRotate), for: .touchUpInside)
        
        rotateButton?.setTitle(self.rotateButtonTitle, for: .normal)
        
        resetButton?.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
    }
    
    var rotateButtonTitle: String {
        switch rotation {
        case .portrait:
            return "No rotation"
        case .portraitUpsideDown:
            return "Rotated 180 degrees"
        case .landscapeRight:
            return "Rotated 90 degrees CW"
        case .landscapeLeft:
            return "Rotated 90 degrees CCW"
        case .unknown:
            return "Rotation unknown"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backend.refresh()
    }
    
    func updateSelectionLabel() {
        DispatchQueue.main.async {
            self.selectionLabel?.text = "\(self.backend.selected.count) assets selected"
        }
    }
}

extension DemoViewController: SlideshowControllerDelegate {
    var screenCount: Int {
        set {
            self.numberOfScreens = newValue
        }
        get {
            return self.numberOfScreens
        }
    }
    
    func addedScreen(_ screen: ExternalScreen) {
        
    }
    
    func removedScreen(_ screen: ExternalScreen) {
        
    }
    
    func removedAllScreens() {
        
    }
}

