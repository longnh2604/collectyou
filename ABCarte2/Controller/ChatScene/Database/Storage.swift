//
//  BaseDB.swift
//  db
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import Foundation
import YapDatabase

class Storage {
    
    private let rConnection: YapDatabaseConnection!
    private let wConnection: YapDatabaseConnection!
    
    let db: YapDatabase!

    init(withFileName fileName: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let baseDir = paths.count > 0 ? paths[0] : NSTemporaryDirectory()
        let path = URL(fileURLWithPath: baseDir).appendingPathComponent(fileName).path
        
        db = YapDatabase(path: path)
        db.connectionDefaults.objectCacheLimit = 10000
        db.connectionDefaults.metadataCacheEnabled = false
        db.connectionDefaults.objectCacheEnabled = false
        db.connectionDefaults.objectPolicy = .share
        
        rConnection = db.newConnection()
        rConnection.objectCacheEnabled = true

        wConnection = db.newConnection()
    }
}

extension Storage {
    
    //MARK: - Insert object(s)
    
    func insert<T>(_ object: T, inCollection: String = "default") where T: KeyedObject {
        wConnection.readWrite { (transaction) in
            transaction.setObject(object, forKey: object.key, inCollection: inCollection)
        }
    }
    
    func insert(_ object: Any, forKey key: String, collection: String = "default")  {
        wConnection.readWrite { (transaction) in
            transaction.setObject(object, forKey: key, inCollection: collection)
        }
    }
    
    func insert<T>(_ objects: [T], collection: String = "default") where T: KeyedObject {
        wConnection.readWrite { (transaction) in
            objects.forEach({ (object) in
                transaction.setObject(object, forKey: object.key, inCollection: collection)
            })
        }
    }
    
    //MARK: Get object(s)
    
    func object<T>(forKey key: String, inCollection collection: String = "default") -> T? {
        var result: T? = nil
        rConnection.read { (transaction) in
            result = transaction.object(forKey: key, inCollection: collection) as? T
        }
        return result
    }

    
    func allObjects<T>(inCollection collection: String = "default") -> [T] {
        var result = [T]()
        rConnection.read { (transaction) in
            transaction.enumerateKeysAndObjectsInAllCollections({ (collection, key, object, stop) in
                result.append(object as! T)
            })
        }
        return result
    }
    
    //MARK: Remove object(s)
    
    /// Remove for key
    ///
    /// - Parameters:
    ///   - forKey: Object key
    ///   - inCollection: Collection name
    func remove(_ forKey: String, inCollection: String = "default") {
        wConnection.readWrite { (transaction) in
            transaction.removeObject(forKey: forKey, inCollection: inCollection)
        }
    }
    
    func remove<T>(_ object: T, fromCollection: String = "default") where T: KeyedObject  {
        wConnection.readWrite { (transaction) in
            transaction.removeObject(forKey: object.key, inCollection: fromCollection)
        }
    }
    
    /// Remove all objects
    ///
    /// - Parameter inCollection: Collection name
    func removeAllObjects(inCollection: String = "default") {
        wConnection.readWrite { (transaction) in
            transaction.removeAllObjects(inCollection: inCollection)
        }
    }
    
    /// Remvoe all objects in all collections
    func removeAllObjectsInAllCollections() {
        wConnection.readWrite { (transaction) in
            transaction.removeAllObjectsInAllCollections()
        }
    }
    
    func allKeys(_ collection: String = "default") -> [String] {
        var result = [String]()
        rConnection.read { (transaction) in
          result.append(contentsOf: transaction.allKeys(inCollection: collection))
        }
        return result
    }
}
