//
//  ViewController.swift
//  KVOController
//
//  Created by Mohamed Afifi on 07/22/2015.
//  Copyright (c) 2015 mohamede1945. All rights reserved.
//

import UIKit
import KVOController

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!

    private let clock = Clock()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        formatter.dateStyle = NSDateFormatterStyle.NoStyle

        observe(retainedObservable: clock, keyPath: "date", options: .New | .Initial) { [weak self] (observable: Clock, change: Change<NSDate>) -> () in
            if let date = change.newValue {
                self?.timeLabel.text = formatter.stringFromDate(date)
            }
        }
    }

    deinit {
        NSLog("Dealocated")
    }

}

