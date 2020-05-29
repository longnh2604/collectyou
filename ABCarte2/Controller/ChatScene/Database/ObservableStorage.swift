//
//  DialogsStorage.swift
//  db
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import YapDatabase
import ConnectyCube

typealias Sorting<T> = (T, T) -> ComparisonResult
typealias Grouping<T> = (T) -> String

protocol ChangesPresenter: NSObjectProtocol {
    func changeReceive(changes: [YapDatabaseViewRowChange])
}

fileprivate struct Defaults {
    static let collection = "default"
    static let name = "order"
    static let group = "all"
}

class SortedDataProvider<T> {
    
    fileprivate let name: String!
    fileprivate let collection: String!
    fileprivate var sorting: Sorting<T>!
    fileprivate var grouping: Grouping<T>?
    fileprivate var group: String!
    fileprivate var mappings: YapDatabaseViewMappings!
    fileprivate var autoViewConnection: YapDatabaseConnection!
    fileprivate var view: YapDatabaseAutoView!
    fileprivate lazy var presenters: NSHashTable<AnyObject>! =  NSHashTable(options: .weakMemory)
    
    deinit {
        autoViewConnection.database.unregisterExtension(withName: self.name)
        NotificationCenter.default.removeObserver(self)
    }
    
    init(collection: String = Defaults.collection, name: String = Defaults.name, group: String = Defaults.group, grouping: Grouping<T>? = nil, sorting: @escaping Sorting<T>) {
        
        self.name = name
        self.group = group
        self.sorting = sorting
        self.grouping = grouping
        self.collection = collection
        self.mappings = YapDatabaseViewMappings(groups: [self.group], view: self.name)
    }
    
    func addPresenter(_ presenter: ChangesPresenter) {
        self.presenters.add(presenter)
    }
    
    fileprivate func register(forDatabase db: YapDatabase) {
        
        let grouping = YapDatabaseViewGrouping.withObjectBlock { [weak self] (transaction, _collection, key, object) -> String? in
            
            if self?.collection! == _collection {
                return self?.grouping != nil ? self?.grouping!(object as! T) : Defaults.group
            }
            return nil
        }
        let sorting = YapDatabaseViewSorting.withObjectBlock { [weak self] (transaction, group,
            collection1, key1, obj1,
            collection2, key2, obj2) -> ComparisonResult in
            return self?.sorting(obj1 as! T, obj2 as! T) ?? .orderedSame
        }
        view = YapDatabaseAutoView(grouping: grouping, sorting: sorting)
        db.register(view, withName: self.name)
        
        self.autoViewConnection = db.newConnection()
        self.autoViewConnection.objectCacheEnabled = true
        self.autoViewConnection.beginLongLivedReadTransaction()
        
        self.autoViewConnection.read {[weak self] (transaction) in
            self?.mappings.update(with: transaction)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(modified(_:)), name: .YapDatabaseModified, object: self.autoViewConnection.database)
    }
    
    @objc private func modified(_ notification: Notification) {
        
        let notifications = self.autoViewConnection.beginLongLivedReadTransaction()
        guard notifications.count > 0 else { return }
        let view = self.autoViewConnection.ext(self.name) as! YapDatabaseAutoViewConnection
        if !view.hasChanges(for: notifications) {
            self.autoViewConnection.read { (transaction) in
                self.mappings.update(with: transaction)
            }
            return
        }
        
        if self.autoViewConnection.hasChange(forCollection: self.collection, in: notifications) {
            
            var sectionsChanges: NSArray? = []
            var rowChanges: NSArray? = []
            view.getSectionChanges(&sectionsChanges!, rowChanges: &rowChanges!, for: notifications, with: self.mappings)
            guard let rows: [YapDatabaseViewRowChange] = rowChanges as? [YapDatabaseViewRowChange], rows.count > 0 else { return }
            
            self.presenters.allObjects.forEach { (handler) in
                let h = handler as! ChangesPresenter
                h.changeReceive(changes: rowChanges as! [YapDatabaseViewRowChange])
            }
        }
    }
}

extension SortedDataProvider {
    
    func numberOfObjects(inGroup group: String = Defaults.group) -> Int {
        return Int(self.mappings!.numberOfItems(inGroup: group))
    }
    
    func object(_ indexPath: IndexPath, inGroup group: String = Defaults.group) -> T? {
        var result: T! = nil
        autoViewConnection.read { (transaction) in
            result = (transaction.ext(self.name) as! YapDatabaseAutoViewTransaction)
                .object(at: UInt(indexPath.row), inGroup: group) as? T
        }
        return result!
    }
    
    func allObjects(inGroup group: String = Defaults.group) -> [T] {
        var result = [T]()
        self.autoViewConnection.read { (transaction) in
            (transaction.ext(self.name) as! YapDatabaseAutoViewTransaction)
                .enumerateKeysAndObjects(inGroup: group, using: { (_, _, object, _, _) in
                    result.append(object as! T)
                })
        }
        return result
    }
    
    func firstObject(inGroup group: String = Defaults.group) -> T? {
        var result: T? = nil
        self.autoViewConnection.read { (transaction) in
            result = (transaction.ext(self.name) as! YapDatabaseAutoViewTransaction).firstObject(inGroup: group) as? T
        }
        
        return result
    }
    
    func lastObject(inGroup group: String = Defaults.group) -> T? {
        var result: T? = nil
        self.autoViewConnection.read {(transaction) in
            result = (transaction.ext(self.name) as! YapDatabaseAutoViewTransaction).lastObject(inGroup: group) as? T
        }
        
        return result
    }
}

class ObservableStorage: Storage {
    
    private lazy var updaters: NSHashTable<SortedDataProvider<Any>>! =  NSHashTable(options: .weakMemory)
    
    func register<T>(sortedDataProvider: SortedDataProvider<T>) {
        updaters.add(sortedDataProvider as? SortedDataProvider<Any>)
        sortedDataProvider.register(forDatabase: db)
    }
}
