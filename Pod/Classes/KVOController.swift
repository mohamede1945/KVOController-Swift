//
//  KVOController.swift
//  VuPoint
//
//  Created by TCSASSEMBLER on 4/7/15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import UIKit

public struct KVOChange<T> {

    let kind: NSKeyValueChange  // NSKeyValueChangeKindKey

    let newValue: T?            // NSKeyValueChangeNewKey

    let oldValue: T?            // NSKeyValueChangeOldKey

    let indexes: NSIndexSet?    // NSKeyValueChangeIndexesKey

    let isPrior: Bool           // NSKeyValueChangeNotificationIsPriorKey

    init(change: [NSObject: AnyObject]) {

        // mandatory
        kind = NSKeyValueChange(rawValue: change[NSKeyValueChangeKindKey]!.unsignedLongValue)!
        isPrior  = change[NSKeyValueChangeNotificationIsPriorKey] as! Bool

        // optional
        newValue = change[NSKeyValueChangeNewKey] as? T
        oldValue = change[NSKeyValueChangeOldKey] as? T
        indexes  = change[NSKeyValueChangeIndexesKey] as? NSIndexSet
    }
}

private protocol Observer : class {
    var keyPath: String { get }
    var options: NSKeyValueObservingOptions { get }
    func valueChanged(observable: AnyObject, change: [NSObject : AnyObject])
}

public enum ObservableStorage<T : AnyObject> {
    case Retained(T)
    case Nonretained(T)
}

public class KVOController<ObservableType: AnyObject, PropertyType> : Observer {

    typealias KVOObservingBlock = (observable: ObservableType, change: KVOChange<PropertyType>) -> ()

    let keyPath: String
    let options: NSKeyValueObservingOptions

    let block: KVOObservingBlock

    let context: UnsafeMutablePointer<Void>

    weak var observable: ObservableType?

    private var proxy: KVOControllerProxy!

    init(
        observable  : ObservableType,
        keyPath : String,
        options : NSKeyValueObservingOptions,
        block   : KVOObservingBlock,
        context : UnsafeMutablePointer<Void> = nil) {

            self.keyPath = keyPath
            self.options = options
            self.block = block
            self.context = context
            self.observable = observable

            self.proxy = KVOControllerProxy(self)
            KVOSingletonController.singleton.observe(observable, observer: self.proxy)
    }

    deinit {
        if let observable = observable {
            KVOSingletonController.singleton.unobserve(observable, keyPath: keyPath, observer: self.proxy)
        }
    }

    func valueChanged(observable: AnyObject, change: [NSObject : AnyObject]) {
        if let observableObject = self.observable {
            let kvoChange = KVOChange<PropertyType>(change: change)
            block(observable: observableObject, change: kvoChange)
        }
    }

}

@objc
private class KVOControllerProxy: NSObject, Observer {

    unowned var observer: Observer

    init(_ observer: Observer) {
        self.observer = observer
    }

    var keyPath: String {
        return observer.keyPath
    }

    var options: NSKeyValueObservingOptions {
        return observer.options
    }

    func valueChanged(observable: AnyObject, change: [NSObject : AnyObject]) {
        return observer.valueChanged(observable, change: change)
    }

    lazy var pointer: UnsafeMutablePointer<KVOControllerProxy> = {
        return UnsafeMutablePointer<KVOControllerProxy>(Unmanaged<KVOControllerProxy>.passUnretained(self).toOpaque())
        }()

    class func fromPointer(pointer: UnsafeMutablePointer<KVOControllerProxy>) -> KVOControllerProxy {
        return Unmanaged<KVOControllerProxy>.fromOpaque(COpaquePointer(pointer)).takeUnretainedValue()
    }
}

private class KVOSingletonController : NSObject {
    let observers = NSHashTable.weakObjectsHashTable()
    var lock = OS_SPINLOCK_INIT

    static let singleton = KVOSingletonController()

    func observe(object: AnyObject, var observer: KVOControllerProxy) {

        OSSpinLockLock(&lock)
        observers.addObject(observer)
        OSSpinLockUnlock(&lock)

        object.addObserver(self, forKeyPath: observer.keyPath, options: observer.options, context: observer.pointer)
    }

    func unobserve(object: AnyObject, keyPath: String, var observer: KVOControllerProxy) {
        OSSpinLockLock(&lock)
        observers.removeObject(observer)
        OSSpinLockUnlock(&lock)

        object.removeObserver(self, forKeyPath: keyPath)
    }

    override func observeValueForKeyPath(keyPath: String, ofObject observable: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {

            assert(context != nil,
                "Context is missing for keyPath:'\(keyPath)' of observable:'\(observable)', change:'\(change)'")


            let pointer = UnsafeMutablePointer<KVOControllerProxy>(context)
            let contextObserver = KVOControllerProxy.fromPointer(pointer)
            var info: KVOControllerProxy!
            OSSpinLockLock(&lock)
            info = observers.member(contextObserver) as? KVOControllerProxy
            OSSpinLockUnlock(&lock)

            if let info = info {
                info.valueChanged(observable, change: change)
            }
    }
}