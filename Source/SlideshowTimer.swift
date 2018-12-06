//
//  SlideshowTimer.swift
//  SwiftySlideshow
//
//  Created by Lacy Rhoades on 11/17/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation

class SlideshowTimer {
    fileprivate var timer: Timer?
    fileprivate var timerLoop = RunLoop.main
    
    var isPaused: Bool = true
    
    var fireBlock: ActionBlock? = nil
    
    func stop() {
        self.timer?.invalidate()
        self.timer = nil
        self.isPaused = true
    }
    
    func go(withDelay delay: TimeInterval) {
        self.timer?.invalidate()
        self.timer = nil
        
        self.isPaused = false
        
        let timer = Timer(timeInterval: delay, repeats: false, block: { timer in
            guard self.isPaused == false else {
                return
            }
            
            self.fireBlock?()
        })
        self.timer = timer
        self.timerLoop.add(timer, forMode: .common)
    }
    
}
