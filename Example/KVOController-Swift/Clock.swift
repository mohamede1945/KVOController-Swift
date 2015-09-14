//
//  Clock.swift
//  KVOController
//
//  Created by Mohamed Afifi on 7/23/15.
//  Copyright (c) 2015 mohamede1945. All rights reserved.
//

import UIKit

/**
Represents the clock class.

@author mohamede1945

@version 1.0
*/
class Clock : NSObject {

    /// Represents the timer property.
    private var timer: Timer?

    /// Represents the date property.
    dynamic private (set) var date = NSDate()

    /**
    Initialize new instance.

    - returns: The new created instance.
    */
    override init() {
        super.init()
        timer = Timer(interval: 1, repeated: true) { [weak self] () -> Void in
            self?.date = NSDate()
        }
    }
}

/**
Represents the timer class.

@author mohamede1945

@version 1.0
*/
class Timer {

    /// Represents the is cancelled property.
    private var isCancelled = false
    /// Represents the repeated property.
    private let repeated: Bool

    /// Represents the timer property.
    private let timer: dispatch_source_t

    /**
    Initialize new instance with interval, repeated, queue and handler.

    - parameter interval: The interval parameter.
    - parameter repeated: The repeated parameter.
    - parameter queue:    The queue parameter.
    - parameter handler:  The handler parameter.

    - returns: The new created instance.
    */
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

    /**
    Cancel.
    */
    func cancel() {
        isCancelled = true
        dispatch_source_cancel(timer)
    }

    /**
    Deallocate the instance.
    */
    deinit {
        cancel()
    }
}