//
//  Clock.swift
//  KVOController
//
//  Created by Mohamed Afifi on 7/23/15.
//  Copyright (c) 2015 mohamede1945. All rights reserved.
//

import UIKit

class Clock : NSObject {

    private var timer: NSTimer?

    dynamic private (set) var date = NSDate()

    override init() {
        super.init()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    func timerFired(timer: NSTimer) {
        if timer != self.timer {
            return
        }

        self.date = NSDate()
    }
}