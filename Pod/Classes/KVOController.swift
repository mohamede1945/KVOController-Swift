//
//  KVOController.swift
//  KVOController
//
//  Created by mohamede1945 on 6/20/15.
//  Copyright (c) 2015 Varaw. All rights reserved.
//

public typealias Observable = NSObject

private var KVOControllerObjectAssociationKey : UInt8 = 0

public extension NSObject {

    public func observe<Observable : NSObject, PropertyType>(
        #retainedObservable: Observable,
        keyPath: String,
        options: NSKeyValueObservingOptions,
        block: ClosureObserverWay<Observable, PropertyType>.ObservingBlock) -> Controller<ClosureObserverWay<Observable, PropertyType>> {

            let closure = ClosureObserverWay(block: block)
            let controller = Controller(retainedObservable: retainedObservable, keyPath: keyPath, options: options, observerWay: closure)
            addObserver(controller)
            return controller
    }

    public func observe<ObservableType : Observable, PropertyType>(
        #nonretainedObservable: ObservableType,
        keyPath: String,
        options: NSKeyValueObservingOptions,
        block: ClosureObserverWay<ObservableType, PropertyType>.ObservingBlock) -> Controller<ClosureObserverWay<ObservableType, PropertyType>> {

            let closure = ClosureObserverWay(block: block)
            let controller = Controller(nonretainedObservable: nonretainedObservable, keyPath: keyPath, options: options, observerWay: closure)
            addObserver(controller)
            return controller
    }

    public func unobserve(observable: Observable, keyPath: String) {
        var observers = listOfObservers()

        for (index, observer) in enumerate(observers) {
            if observer.isObserving(observable, keyPath: keyPath) {
                // stop observing
                observer.unobserve()

                // remove observer
                observers.removeAtIndex(index)
                break
            }
        }

        if observers.count == 0 {
            removeObjectAssociation()
        }
    }

    public func unobserveAll() {
        for observer in listOfObservers() {
            observer.unobserve()
        }
        removeObjectAssociation()
    }

    private func removeObjectAssociation() {
        objc_setAssociatedObject(self, &KVOControllerObjectAssociationKey, nil, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }

    private func listOfObservers() -> [KVOObserver] {
        var associatedObject : AnyObject? =  objc_getAssociatedObject(self, &KVOControllerObjectAssociationKey)
        var observers: [KVOObserver]
        if let associatedObject = associatedObject as? ObjectWrapper,
            observersArray = associatedObject.any as? [KVOObserver] {
            observers = observersArray
        } else {
            observers = [KVOObserver]()
        }
        return observers
    }

    private func addObserver(observer: KVOObserver) {
        var observers = listOfObservers()
        observers.append(observer)

        let wrapper = ObjectWrapper(any: observers)
        objc_setAssociatedObject(self, &KVOControllerObjectAssociationKey, wrapper, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }

    private class ObjectWrapper {
        var any: Any
        init(any: Any) {
            self.any = any
        }
    }
}

public struct ChangeData<T> : Printable {

    public let kind: NSKeyValueChange  // NSKeyValueChangeKindKey

    public let newValue: T?            // NSKeyValueChangeNewKey

    public let oldValue: T?            // NSKeyValueChangeOldKey

    public let indexes: NSIndexSet?    // NSKeyValueChangeIndexesKey

    public let isPrior: Bool           // NSKeyValueChangeNotificationIsPriorKey

    public let keyPath: String

    init(change: [NSObject: AnyObject], keyPath: String) {

        // the key path
        self.keyPath = keyPath

        // mandatory
        kind = NSKeyValueChange(rawValue: change[NSKeyValueChangeKindKey]!.unsignedLongValue)!

        // optional
        newValue = change[NSKeyValueChangeNewKey] as? T
        oldValue = change[NSKeyValueChangeOldKey] as? T
        indexes  = change[NSKeyValueChangeIndexesKey] as? NSIndexSet

        if let prior = change[NSKeyValueChangeNotificationIsPriorKey] as? Bool {
            isPrior  = prior
        } else {
            isPrior = false
        }
    }

    public var description: String {

        var description = "<Change kind: \(kindDescription(kind))"
        if isPrior {
            description += "prior: true"
        }
        if let newValue = newValue {
            description += " new: \(newValue)"
        }
        if let oldValue = oldValue {
            description += " old: \(oldValue)"
        }

        if let indexes = indexes {
            description += " indexes: \(indexes)"
        }
        description += ">"

        return description
    }
}

public protocol ObserverWay {

    typealias ObservableType : Observable
    typealias PropertyType

    func valueChanged(observable: ObservableType, change: ChangeData<PropertyType>)
}

public struct ClosureObserverWay<ObservableType : Observable, PropertyType> : ObserverWay {

    public typealias ObservingBlock = (observable: ObservableType, change: ChangeData<PropertyType>) -> ()

    public let block: ObservingBlock

    public init(block: ObservingBlock) {
        self.block = block
    }

    public func valueChanged(observable: ObservableType, change: ChangeData<PropertyType>) {
        block(observable: observable, change: change)
    }
}

private enum ObservableStorage {
    case Retained
    case Nonretained
}

public class Controller<ObserverWay : ObserverWay> : _KVOObserver, KVOObserver, Printable {

    public let keyPath: String
    public let options: NSKeyValueObservingOptions

    public let observerWay: ObserverWay

    private let store: ObservableStore<ObserverWay.ObservableType>

    public var observable: ObserverWay.ObservableType? {
        return store.observable
    }

    private var proxy: ControllerProxy!

    var observing = true

    private init(
        observable  : ObserverWay.ObservableType,
        observableStorage: ObservableStorage,
        keyPath : String,
        options : NSKeyValueObservingOptions,
        context : UnsafeMutablePointer<Void> = nil,
        observerWay : ObserverWay) {

            assert(!keyPath.isEmpty, "Keypath shouldn't be empty string")

            self.keyPath = keyPath
            self.options = options
            self.observerWay = observerWay
            self.store = ObservableStore(observable: observable, storage: observableStorage)

            self.proxy = ControllerProxy(self)
            SharedObserverController.shared.observe(observable, observer: self.proxy)
    }

    public convenience init(retainedObservable: ObserverWay.ObservableType,
        keyPath : String,
        options : NSKeyValueObservingOptions,
        context : UnsafeMutablePointer<Void> = nil,
        observerWay : ObserverWay) {

            self.init(observable: retainedObservable, observableStorage: .Retained, keyPath : keyPath,
                options : options, context : context, observerWay: observerWay)
    }

    public convenience init(nonretainedObservable: ObserverWay.ObservableType,
        keyPath : String,
        options : NSKeyValueObservingOptions,
        context : UnsafeMutablePointer<Void> = nil,
        observerWay : ObserverWay) {

            self.init(observable: nonretainedObservable, observableStorage: .Nonretained, keyPath : keyPath,
                options : options, context : context, observerWay: observerWay)
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
            let kvoChange = ChangeData<ObserverWay.PropertyType>(change: change, keyPath: keyPath)
            observerWay.valueChanged(observableObject, change: kvoChange)
        }
    }

    public func isObserving(observable: Observable, keyPath: String) -> Bool {

        if let observableObject = self.observable where observing && keyPath == self.keyPath {
            return true
        }
        return false

    }

    public var description: String {
        var description = "<Controller options: \(optionDescription(options)) keyPath: \(keyPath) observable: \(observable) observing: \(observing)>"
        return description
    }
}

// MARK:- Private Classes

@objc
private class ControllerProxy: NSObject, _KVOObserver, Printable {

    unowned var observer: _KVOObserver

    init(_ observer: _KVOObserver) {
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

    override var description: String {
        var description = String(format: "<%@:%p observer: \(observer)>", arguments: [NSStringFromClass(self.dynamicType), self])
        return description
    }
}

private class SharedObserverController : NSObject {
    let observers = NSHashTable.weakObjectsHashTable()
    var lock = OS_SPINLOCK_INIT

    static let shared = SharedObserverController()

    func observe(observable: Observable, var observer: ControllerProxy) {

        executeSafely {NSPointerFunctionsOpaqueMemory
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
            assert(observable is NSObject, "Observable object should be of type NSObject")

            let observableObject = observable as! NSObject

            let pointer = UnsafeMutablePointer<ControllerProxy>(context)
            let contextObserver = ControllerProxy.fromPointer(pointer)
            var info: ControllerProxy?
            executeSafely {
                info = observers.member(contextObserver) as? ControllerProxy
            }

            if let info = info {
                info.valueChanged(observableObject, change: change)
            }
    }
    
    private func executeSafely(@noescape block: () -> ()) {
        OSSpinLockLock(&lock)
        block()
        OSSpinLockUnlock(&lock)
    }

    override var description: String {
        var description = String(format: "<%@:%p", arguments: [NSStringFromClass(self.dynamicType), self])
        executeSafely {

            var observersDescriptions = [String]()
            for observer in observers.objectEnumerator() {
                if let proxy = observer as? ControllerProxy {
                    observersDescriptions.append(proxy.description)
                }
            }

            description += " contexts:\(observersDescriptions)>"
        }

        return description
    }
}

public protocol KVOObserver {

    func unobserve()
    func isObserving(observable: Observable, keyPath: String) -> Bool
}

private protocol _KVOObserver : class {
    var keyPath: String { get }
    var options: NSKeyValueObservingOptions { get }
    func valueChanged(observable: Observable, change: [NSObject : AnyObject])
}

private struct ObservableStore<T : Observable> {

    private (set) var storage: ObservableStorage

    private var retainedObservable: T?
    private weak var nonretainedObservable: T?

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

private func optionDescription(option: NSKeyValueObservingOptions) -> String {
    var string = ""

    let options = [(option: NSKeyValueObservingOptions.New, "New"),
        (option: NSKeyValueObservingOptions.Old, "Old"),
        (option: NSKeyValueObservingOptions.Initial, "Initial"),
        (option: NSKeyValueObservingOptions.Prior, "Prior")]

    var varOption = option

    while varOption.rawValue > 0 {
        for (targetOption, desc) in options {
            if varOption & targetOption == targetOption {
                varOption = (~targetOption & varOption)
                string += desc + "|"
            }
        }
    }

    if !string.isEmpty {
        string.removeAtIndex(string.endIndex.predecessor())
    }

    return string;
}

private func kindDescription(kind: NSKeyValueChange) {
    let kinds = [NSKeyValueChange.Insertion: "Insertion",
        NSKeyValueChange.Removal: "Removal", NSKeyValueChange.Replacement : "Replacement", NSKeyValueChange.Setting : "Setting" ]
}
