//
//  Clock.swift
//  KVOController
//
//  Created by Mohamed Afifi on 7/23/15.
//  Copyright (c) 2015 mohamede1945. All rights reserved.
//

import UIKit

class Clock : NSObject {

    private var timer: Timer?

    dynamic private (set) var date = NSDate()

    override init() {
        super.init()
        timer = Timer(interval: 1, repeated: true) { [weak self] () -> Void in
            self?.date = NSDate()
        }
    }
}

class Timer {

    private var isCancelled = false
    private let repeated: Bool

    private let timer: dispatch_source_t

    init(interval: NSTimeInterval, repeated: Bool, queue: dispatch_queue_t = dispatch_get_main_queue(), handler: dispatch_block_t) {
        self.repeated = repeated

        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        let dispatchInterval = UInt64(interval * Double(NSEC_PER_SEC))
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, dispatchInterval, 0);

        dispatch_source_set_event_handler(timer) { [weak self] in
            if self?.isCancelled == false {
                handler()
            }
        }
        dispatch_resume(timer);
    }

    func cancel() {
        isCancelled = true
        dispatch_source_cancel(timer)
    }

    deinit {
        cancel()
    }
}