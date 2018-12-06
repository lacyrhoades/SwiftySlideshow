//
//  ScreenWatcher.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

public class ScreenWatcher {
    weak var delegate: ExternalScreenDelegateProtocol?
    
    public init(notify: ExternalScreenDelegateProtocol) {
        self.delegate = notify

        NotificationCenter.default.addObserver(self, selector: #selector(screenConnected), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDisconnected), name: UIScreen.didDisconnectNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func screenConnected(_ notification: Notification) {
        if let screen = notification.object as? UIScreen {
            self.delegate?.attachSlideshowController(toScreen: screen)
        }
    }
    
    @objc func screenDisconnected(_ notification: Notification) {
        if let screen = notification.object as? UIScreen {
            self.delegate?.detachSlideshowController(fromScreen: screen)
        }
    }
}
