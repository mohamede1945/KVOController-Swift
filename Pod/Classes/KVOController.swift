//
//  KVOController.swift
//  KVOController
//
//  Created by mohamede1945 on 6/20/15.
//  Copyright (c) 2015 Varaw. All rights reserved.
//

public typealias Observable = AnyObject

public class Controller<Observer : Observer> : KVOObserver {

    public let keyPath: String
    public let options: NSKeyValueObservingOptions

    public let observer: Observer

    private let store: ObservableStore<Observer.ObservableType>

    public var observable: Observer.ObservableType? {
        return store.observable
    }

    private var proxy: ControllerProxy!

    var observing = true

    init(
        observable  : Observer.ObservableType,
        obserableStorage: ObservableStorage = .Retained,
        keyPath : String,
        options : NSKeyValueObservingOptions,
        context : UnsafeMutablePointer<Void> = nil,
        observer : Observer) {

            self.keyPath = keyPath
            self.options = options
            self.observer = observer
            self.store = ObservableStore(observable: observable, storage: obserableStorage)

            self.proxy = ControllerProxy(self)
            SharedObserverController.shared.observe(observable, observer: self.proxy)
    }

    deinit {
        unobserve()
    }

    public func unobserve() {
        if let observable = observable where observing {
            SharedObserverController.shared.unobserve(observable, keyPath: keyPath, observer: self.proxy)
            observing = false
        }
    }

    private func valueChanged(observable: Observable, change: [NSObject : AnyObject]) {
        if let observableObject = self.observable where observing {
            let kvoChange = Change<Observer.PropertyType>(change: change)
            observer.valueChanged(observableObject, change: kvoChange)
        }
    }
}

@objc
private class ControllerProxy: NSObject, KVOObserver {

    unowned var observer: KVOObserver

    init(_ observer: KVOObserver) {
        self.observer = observer
    }

    var keyPath: String {
        return observer.keyPath
    }

    var options: NSKeyValueObservingOptions {
        return observer.options
    }

    func valueChanged(observable: Observable, change: [NSObject : AnyObject]) {
        return observer.valueChanged(observable, change: change)
    }

    lazy var pointer: UnsafeMutablePointer<ControllerProxy> = {
        return UnsafeMutablePointer<ControllerProxy>(Unmanaged<ControllerProxy>.passUnretained(self).toOpaque())
        }()

    class func fromPointer(pointer: UnsafeMutablePointer<ControllerProxy>) -> ControllerProxy {
        return Unmanaged<ControllerProxy>.fromOpaque(COpaquePointer(pointer)).takeUnretainedValue()
    }
}

private class SharedObserverController : NSObject {
    let observers = NSHashTable.weakObjectsHashTable()
    var lock = OS_SPINLOCK_INIT

    static let shared = SharedObserverController()

    func observe(observable: Observable, var observer: ControllerProxy) {

        executeSafely {
            observers.addObject(observer)
        }

        observable.addObserver(self, forKeyPath: observer.keyPath, options: observer.options, context: observer.pointer)
    }

    func unobserve(observable: Observable, keyPath: String, var observer: ControllerProxy) {
        executeSafely {
            observers.removeObject(observer)
        }

        observable.removeObserver(self, forKeyPath: keyPath)
    }

    override func observeValueForKeyPath(keyPath: String, ofObject observable: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {

            assert(context != nil,
                "Context is missing for keyPath:'\(keyPath)' of observable:'\(observable)', change:'\(change)'")

            let pointer = UnsafeMutablePointer<ControllerProxy>(context)
            let contextObserver = ControllerProxy.fromPointer(pointer)
            var info: ControllerProxy?
            executeSafely {
                info = observers.member(contextObserver) as? ControllerProxy
            }

            if let info = info {
                info.valueChanged(observable, change: change)
            }
    }
    
    private func executeSafely(@noescape block: () -> ()) {
        OSSpinLockLock(&lock)
        block()
        OSSpinLockUnlock(&lock)
    }
}


private protocol KVOObserver : class {
    var keyPath: String { get }
    var options: NSKeyValueObservingOptions { get }
    func valueChanged(observable: Observable, change: [NSObject : AnyObject])
}

private struct ObservableStore<T : Observable> {

    var storage: ObservableStorage

    var retainedObservable: T?
    weak var nonretainedObservable: T?

    init(observable: T, storage: ObservableStorage) {
        self.storage = storage

        switch storage {
        case .Retained:     retainedObservable = observable
        case .Nonretained:  nonretainedObservable = observable
        }
    }

    var observable : T? {
        switch storage {
        case .Retained: return retainedObservable
        case .Nonretained: return nonretainedObservable
        }
    }
}