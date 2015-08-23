//
//  KVOControllerTests.swift
//  KVOController
//
//  Created by Mohamed Afifi on 07/22/2015.
//  Copyright (c) 2015 mohamede1945. All rights reserved.
//

import UIKit
import XCTest
import KVOController_Swift

/**
Represents the circle class.

@author mohamede1945

@version 1.0
*/
class Circle : NSObject {
    /// Represents the radius property.
    dynamic var radius = 0

    /// Represents the radius property.
    static let Radius = "radius"
}

/**
Represents the point class.

@author mohamede1945

@version 1.0
*/
class Point: NSObject {
}

/**
Represents the base observer class.

@author mohamede1945

@version 1.0
*/
class BaseObserver: NSObject {

    /// Represents the calls property.
    var calls = 0
    /// Represents the is prior property.
    var isPrior: Bool = false
    /// Represents the key path property.
    var keyPath: String = ""
    /// Represents the observable property.
    var observable: NSObject = NSObject()
    /// Represents the indexes property.
    var indexes: NSIndexSet?
}

/**
Represents the base circle observer class.

@author mohamede1945

@version 1.0
*/
class BaseCircleObserver : BaseObserver {
    let circle: Circle
    let options: NSKeyValueObservingOptions

    init(circle: Circle, options: NSKeyValueObservingOptions) {
        self.circle = circle
        self.options = options;
    }
}

/**
Represents the radius observer class.

@author mohamede1945

@version 1.0
*/
class RadiusObserver : BaseCircleObserver {

    var newValue: Int?
    var oldValue: Int?

    func startObserving() -> Controller<ClosureObserverWay<Circle, Int>> {
        let controller = observe(retainedObservable: circle, keyPath: Circle.Radius, options: options) { [weak self] (observable: Circle, change: ChangeData<Int>) -> () in

            if let strong = self {
                strong.calls++
                strong.observable = observable

                strong.isPrior = strong.isPrior || change.isPrior
                strong.keyPath = change.keyPath
                strong.indexes = change.indexes

                strong.newValue = change.newValue
                strong.oldValue = change.oldValue
            } else {
                XCTFail("Observe called for a deallocated object")
            }
        }
        return controller
    }
}

/**
Represents the empty radus observer class.

@author mohamede1945

@version 1.0
*/
class EmptyRadusObserver : BaseCircleObserver {

    func startObserving() {
        observe(retainedObservable: circle, keyPath: "", options: options) { [weak self] (observable: Circle, change: ChangeData<Int>) -> () in

            if let strong = self {
                strong.calls++
                strong.observable = observable

                strong.isPrior = strong.isPrior || change.isPrior
                strong.keyPath = change.keyPath
                strong.indexes = change.indexes
            }
        }
    }

}

/**
Represents the kvo controller tests class.

@author mohamede1945

@version 1.0
*/
class KVOControllerTests: XCTestCase {

    /**
    Test observe radius.
    */
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

    /**
    Test observe radius old value.
    */
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

    /**
    Test observe radius initial.
    */
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

    /**
    Test observe radius piror.
    */
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

    /**
    Test observe radius none options.
    */
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

    /**
    Test observe radius all options.
    */
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

    /**
    Test unobserve.
    */
    func testUnobserve() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.New
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")

        radiusObserver.unobserve(circle, keyPath: Circle.Radius)

        // change value
        circle.radius = 5

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")

    }

    /**
    Test unobserve all.
    */
    func testUnobserveAll() {

        // start observing
        let circle = Circle()
        let options = NSKeyValueObservingOptions.New
        let radiusObserver = RadiusObserver(circle: circle, options: options)
        radiusObserver.startObserving()

        // change value
        circle.radius = 2

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")

        radiusObserver.unobserveAll()

        // change value
        circle.radius = 5

        // assert
        XCTAssertEqual(1, radiusObserver.calls, "Invalid number of calls")
    }

    /**
    Test deallocated observer.
    */
    func testDeallocatedObserver() {

        // start observing
        let circle = Circle()

        autoreleasepool {
            let options = NSKeyValueObservingOptions.New
            var radiusObserver: RadiusObserver? = RadiusObserver(circle: circle, options: options)
            radiusObserver?.startObserving()

            // change value
            circle.radius = 5

            radiusObserver = nil // deallocate
        }

        // change again, should pass as RadiusObserver will fail if block is called when deallocated
        circle.radius = 1
    }

    /**
    Test deallocated controller.
    */
    func testDeallocatedController() {

        // start observing
        let circle = Circle()

        var calls = 0

        let closure = ClosureObserverWay() { (observable: Circle, change: ChangeData<Int>) -> () in
            calls++
        }

        autoreleasepool {
            let options = NSKeyValueObservingOptions.New

            var controller: Controller<ClosureObserverWay<Circle, Int>>? = Controller(retainedObservable: circle, keyPath: Circle.Radius, options: options, observerWay: closure)

            // change value
            circle.radius = 5

            controller = nil // deallocated

            // assert
            XCTAssertEqual(1, calls, "Invalid number of calls")
        }

        // change again, should pass as RadiusObserver will fail if block is called when deallocated
        circle.radius = 1

        // assert, calls shouldn't change
        XCTAssertEqual(1, calls, "Invalid number of calls")
    }


}
