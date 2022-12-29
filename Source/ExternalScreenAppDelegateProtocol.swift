//
//  ExternalScreenAppDelegateProtocol.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

public protocol ExternalScreenDelegateProtocol: AnyObject {
    func attachSlideshowController(toScreens screens: [UIScreen])
    func detachSlideshowController()
    func attachSlideshowController(toScreen screen: UIScreen)
    func detachSlideshowController(fromScreen screen: UIScreen)
}
