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
    fileprivate var timer: Timer?

    /// Represents the date property.
    dynamic fileprivate (set) var date = Date()

    /**
    Initialize new instance.

    - returns: The new created instance.
    */
    override init() {
        super.init()
        timer = Timer(interval: 1, repeated: true) { [weak self] () -> Void in
            self?.date = Date()
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
    fileprivate var isCancelled = false
    /// Represents the repeated property.
    fileprivate let repeated: Bool

    /// Represents the timer property.
    fileprivate let timer: DispatchSourceTimer

    /**
    Initialize new instance with interval, repeated, queue and handler.

    - parameter interval: The interval parameter.
    - parameter repeated: The repeated parameter.
    - parameter queue:    The queue parameter.
    - parameter handler:  The handler parameter.

    - returns: The new created instance.
    */
    init(interval: TimeInterval, repeated: Bool, queue: DispatchQueue = DispatchQueue.main, handler: @escaping ()->()) {
        self.repeated = repeated

        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)

        timer.scheduleRepeating(deadline: DispatchTime.now(), interval: .seconds(1), leeway: .milliseconds(0))

        timer.setEventHandler { [weak self] in
            if self?.isCancelled == false {
                handler()
            }
        }
        timer.resume();
    }

    /**
    Cancel.
    */
    func cancel() {
        isCancelled = true
        timer.cancel()
    }

    /**
    Deallocate the instance.
    */
    deinit {
        cancel()
    }
}
