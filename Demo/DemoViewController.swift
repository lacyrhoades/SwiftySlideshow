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
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var selectionLabel: UILabel?
    
    @IBOutlet var previewView: DemoPreviewView?
    @IBOutlet var tableView: UITableView?
    
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
            self.slideshowDataSource?.assetIDs = self.backend.selectedAssetIDs
        }
        
        previewView?.startButton?.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        resetButton?.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
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
}

