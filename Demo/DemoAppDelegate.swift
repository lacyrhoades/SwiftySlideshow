//
//  AppDelegate.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

@UIApplicationMain
class DemoAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Controls the slides
    var slideshowController: SlideshowController?
    
    // Watches for screens as they attach / detach
    var screenWatcher: ScreenWatcher?
    
    var mainVC: DemoViewController? {
        return (self.window?.rootViewController as? DemoViewController)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let slideshowDataSource = DemoDataSource()
        
        self.slideshowController = SlideshowController(
            dataSource: slideshowDataSource,
            defaultImage: UIImage(named: "default-slide")
        )
        
        self.slideshowController?.delegate = self.mainVC
        
        self.screenWatcher = ScreenWatcher(notify: self)
        
        self.mainVC?.slideshowDataSource = slideshowDataSource
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.attachSlideshowController(toScreens: UIScreen.screens)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.detachSlideshowController()
    }
}

extension DemoAppDelegate: ExternalScreenDelegateProtocol {
    func attachSlideshowController(toScreens screens: [UIScreen]) {
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
    
    func detachSlideshowController() {
        self.slideshowController?.detachAll()
    }
    
    func attachSlideshowController(toScreen screen: UIScreen) {
        self.slideshowController?.attach(toScreen: screen)
    }
    
    func detachSlideshowController(fromScreen screen: UIScreen) {
        self.slideshowController?.detach(fromScreen: screen)
    }
}

