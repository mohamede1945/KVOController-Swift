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
    fileprivate let clock = Clock()

    fileprivate var observing = false

    /**
    View did load.
    */
    override func viewDidLoad() {
        super.viewDidLoad()



        startObserve()
                observing = true
    }

    @IBAction func startStopButtonTapped(_ sender: AnyObject) {
        if observing {
            unobserve(clock, keyPath: "date")
            observing = false
            button.setTitle("Start", for: UIControlState())

        } else {
            startObserve()
            observing = true
            button.setTitle("Stop", for: UIControlState())
        }
    }

    func startObserve() {
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.long
        formatter.dateStyle = DateFormatter.Style.none

        observe(retainedObservable: clock, keyPath: "date", options: [.new, .initial])
            { [weak self] (observable: Clock, change: ChangeData<Date>) -> () in

                if let date = change.newValue {
                    self?.timeLabel.text = formatter.string(from: date)
                }
        }
    }
    
}

