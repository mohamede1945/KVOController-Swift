//
//  KVOControllerTests.swift
//  KVOController
//
//  Created by Mohamed Afifi on 07/22/2015.
//  Copyright (c) 2015 mohamede1945. All rights reserved.
//

import UIKit
import XCTest
import KVOController

class Circle : NSObject {
    dynamic var radius = 0

    static let Radius = "radius"
}

class Point: NSObject {
}

class BaseObserver: NSObject {

    var calls = 0
    var isPrior: Bool = false
    var keyPath: String = ""
    var observable: NSObject = NSObject()
    var indexes: NSIndexSet?
}

class RadiusObserver : BaseObserver {
    let circle: Circle
    let options: NSKeyValueObservingOptions

    var newValue: Int?
    var oldValue: Int?

    init(circle: Circle, options: NSKeyValueObservingOptions) {
        self.circle = circle
        self.options = options;
    }

    func startObserving() {
        observe(retainedObservable: circle, keyPath: Circle.Radius, options: options) { [weak self] (observable: Circle, change: ChangeData<Int>) -> () in

            if let strong = self {
                strong.calls++
                strong.observable = observable

                strong.isPrior = strong.isPrior || change.isPrior
                strong.keyPath = change.keyPath
                strong.indexes = change.indexes

                strong.newValue = change.newValue
                strong.oldValue = change.oldValue
            }

        }
    }
}

class KVOControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
    }

    func testObserveRadius() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.New
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")
        XCTAssertEqual(Circle.Radius, radiusObserver.keyPath, "Invalid key path")

        XCTAssertEqual(options, radiusObserver.options, "Invalid options")
        XCTAssertFalse(radiusObserver.isPrior, "Invalid is prior")
        XCTAssertEqual(circle, radiusObserver.observable, "Invalid observable")
        XCTAssertNil(radiusObserver.indexes, "Invalid indexes")
        XCTAssertNil(radiusObserver.oldValue, "Invalid old value")

        NLAssertEqualOptional(radiusObserver.newValue, 2, "Invalid new value")
    }

    func testObserveRadiusOldValue() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")
        XCTAssertEqual(Circle.Radius, radiusObserver.keyPath, "Invalid key path")

        XCTAssertEqual(options, radiusObserver.options, "Invalid options")
        XCTAssertFalse(radiusObserver.isPrior, "Invalid is prior")
        XCTAssertEqual(circle, radiusObserver.observable, "Invalid observable")
        XCTAssertNil(radiusObserver.indexes, "Invalid indexes")

        NLAssertEqualOptional(radiusObserver.oldValue, 0, "Invalid old value")
        NLAssertEqualOptional(radiusObserver.newValue, 2, "Invalid new value")
    }


    func testObserveRadiusInitial() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")
        XCTAssertEqual(Circle.Radius, radiusObserver.keyPath, "Invalid key path")

        XCTAssertEqual(options, radiusObserver.options, "Invalid options")
        XCTAssertFalse(radiusObserver.isPrior, "Invalid is prior")
        XCTAssertEqual(circle, radiusObserver.observable, "Invalid observable")
        XCTAssertNil(radiusObserver.indexes, "Invalid indexes")
        XCTAssertNil(radiusObserver.oldValue, "Invalid old value")

        NLAssertEqualOptional(radiusObserver.newValue, 0, "Invalid new value")
    }

    func testObserveRadiusPiror() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.Prior
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(2, radiusObserver.calls, "Invalid number of calls")
        XCTAssertEqual(Circle.Radius, radiusObserver.keyPath, "Invalid key path")

        XCTAssertEqual(options, radiusObserver.options, "Invalid options")
        XCTAssertTrue(radiusObserver.isPrior, "Invalid is prior")
        XCTAssertEqual(circle, radiusObserver.observable, "Invalid observable")
        XCTAssertNil(radiusObserver.indexes, "Invalid indexes")

        XCTAssertNil(radiusObserver.oldValue, "Invalid old value")
        XCTAssertNil(radiusObserver.newValue, "Invalid new value")
    }

    func testObserveRadiusNoneOptions() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.allZeros
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")
        XCTAssertEqual(Circle.Radius, radiusObserver.keyPath, "Invalid key path")

        XCTAssertEqual(options, radiusObserver.options, "Invalid options")
        XCTAssertFalse(radiusObserver.isPrior, "Invalid is prior")
        XCTAssertEqual(circle, radiusObserver.observable, "Invalid observable")
        XCTAssertNil(radiusObserver.indexes, "Invalid indexes")

        XCTAssertNil(radiusObserver.oldValue, "Invalid old value")
        XCTAssertNil(radiusObserver.newValue, "Invalid new value")
    }

    func testObserveRadiusAllOptions() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.Prior
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(3, radiusObserver.calls, "Invalid number of calls")
        XCTAssertEqual(Circle.Radius, radiusObserver.keyPath, "Invalid key path")

        XCTAssertEqual(options, radiusObserver.options, "Invalid options")
        XCTAssertTrue(radiusObserver.isPrior, "Invalid is prior")
        XCTAssertEqual(circle, radiusObserver.observable, "Invalid observable")
        XCTAssertNil(radiusObserver.indexes, "Invalid indexes")

        NLAssertEqualOptional(radiusObserver.oldValue, 0, "Invalid old value")
        NLAssertEqualOptional(radiusObserver.newValue, 2, "Invalid new value")
    }

}
