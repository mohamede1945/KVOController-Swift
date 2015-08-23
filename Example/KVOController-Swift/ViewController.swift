//
//  ViewController.swift
//  KVOController-Swift
//
//  Created by Mohamed Afifi on 08/23/2015.
//  Copyright (c) 2015 Mohamed Afifi. All rights reserved.
//

import UIKit
import KVOController_Swift

/**
Represents the view controller class.

@author mohamede1945

@version 1.0
*/
class ViewController: UIViewController {

    /// Represents the button property.
    @IBOutlet weak var button: UIButton!

    /// Represents the time label property.
    @IBOutlet weak var timeLabel: UILabel!

    /// Represents the clock property.
    private let clock = Clock()

    private var observing = false

    /**
    View did load.
    */
    override func viewDidLoad() {
        super.viewDidLoad()



        startObserve()
                observing = true
    }

    @IBAction func startStopButtonTapped(sender: AnyObject) {
        if observing {
            unobserve(clock, keyPath: "date")
            observing = false
            button.setTitle("Start", forState: .Normal)

        } else {
            startObserve()
            observing = true
            button.setTitle("Stop", forState: .Normal)
        }
    }

    func startObserve() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        formatter.dateStyle = NSDateFormatterStyle.NoStyle

        observe(retainedObservable: clock, keyPath: "date", options: .New | .Initial)
            { [weak self] (observable: Clock, change: ChangeData<NSDate>) -> () in

                if let date = change.newValue {
                    self?.timeLabel.text = formatter.stringFromDate(date)
                }
        }
    }
    
}

