//
//  KVOTypes.swift
//  KVOController
//
//  Created by mohamede1945 on 6/30/15.
//  Copyright (c) 2015 Varaw. All rights reserved.
//

public struct Change<T> {

    public let kind: NSKeyValueChange  // NSKeyValueChangeKindKey

    public let newValue: T?            // NSKeyValueChangeNewKey

    public let oldValue: T?            // NSKeyValueChangeOldKey

    public let indexes: NSIndexSet?    // NSKeyValueChangeIndexesKey

    public let isPrior: Bool           // NSKeyValueChangeNotificationIsPriorKey

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

public protocol Observer {

    typealias ObservableType : AnyObject
    typealias PropertyType

    func valueChanged(observable: ObservableType, change: Change<PropertyType>)
}

public struct BlockObserver<ObservableType : AnyObject, PropertyType> : Observer {

    typealias ObservingBlock = (observable: ObservableType, change: Change<PropertyType>) -> ()

    let block: ObservingBlock

    public init(block: ObservingBlock) {
        self.block = block
    }

    public func valueChanged(observable: ObservableType, change: Change<PropertyType>) {
        block(observable: observable, change: change)
    }
}


public enum ObservableStorage {
    case Retained
    case Nonretained
}