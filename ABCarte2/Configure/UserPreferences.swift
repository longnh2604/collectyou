//
//  UserPreferences.swift
//  ABCarte2
//
//  Created by Long on 2019/07/11.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation

enum AppColorSet: Int {
    case romanpink = 0
    case hisul = 1
    case gardenparty = 2
    case standard = 3
    case jbsattender = 4
    case lavender = 5
    case pinkgold = 6
    case mysteriousnight = 7
}

enum AppHierarchy: String {
    case open = "openend"
    case unopen = "unopened"
}

enum AccStatus: String {
    case login = "logined"
    case logout = "logout"
}

enum AppDrawType: String {
    case finger = "finger"
    case pencil = "pencil"
}

enum AppDrawColor: Int {
    case black = 1
    case red = 2
    case blue = 3
    case green = 4
    case purple = 5
}

class UserPreferences: NSObject {
    
    static private let prefix: String = Bundle.main.bundleIdentifier ?? "co.jp.ABCarte2"

    // MARK: App Color Style
    static private var kAppColorSet: String {
        get {
            let key: String = "\(prefix).app.colorset"
            return key
        }
    }
    
    // MARK: Hierarchy View
    static private var kAppHierarchy: String {
        get {
            let key: String = "\(prefix).app.hierarchy"
            return key
        }
    }
    
    // MARK: Acc Status
    static private var kAccStatus: String {
        get {
            let key: String = "\(prefix).acc.status"
            return key
        }
    }
    
    // MARK: App Drawing Type
    static private var kAppDrawType: String {
        get {
            let key: String = "\(prefix).app.drawtype"
            return key
        }
    }
    
    // MARK: App Drawing Color
    static private var kAppDrawColor: String {
        get {
            let key: String = "\(prefix).app.drawcolor"
            return key
        }
    }
    
    static var appColorSet: Int? {
        get {
            return UserDefaults.standard.integer(forKey: kAppColorSet)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: Int = newValue {
                userDefaults.set(theNewValue, forKey: kAppColorSet)
            }
            else {
                userDefaults.removeObject(forKey: kAppColorSet)
            }
            userDefaults.synchronize()
        }
    }
    
    static var appHierarchy: String? {
        get {
            return UserDefaults.standard.string(forKey: kAppHierarchy)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: String = newValue {
                userDefaults.set(theNewValue, forKey: kAppHierarchy)
            }
            else {
                userDefaults.removeObject(forKey: kAppHierarchy)
            }
            userDefaults.synchronize()
        }
    }
    
    static var accStatus: String? {
        get {
            return UserDefaults.standard.string(forKey: kAccStatus)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: String = newValue {
                userDefaults.set(theNewValue, forKey: kAccStatus)
            }
            else {
                userDefaults.removeObject(forKey: kAccStatus)
            }
            userDefaults.synchronize()
        }
    }
    
    static var appDrawType: String? {
        get {
            return UserDefaults.standard.string(forKey: kAppDrawType)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: String = newValue {
                userDefaults.set(theNewValue, forKey: kAppDrawType)
            }
            else {
                userDefaults.removeObject(forKey: kAppDrawType)
            }
            userDefaults.synchronize()
        }
    }
    
    static var appDrawColor: Int? {
        get {
            return UserDefaults.standard.integer(forKey: kAppDrawColor)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: Int = newValue {
                userDefaults.set(theNewValue, forKey: kAppDrawColor)
            }
            else {
                userDefaults.removeObject(forKey: kAppDrawColor)
            }
            userDefaults.synchronize()
        }
    }
    
    static func removeUserInfo() {
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: kAppColorSet)
        userDefaults.removeObject(forKey: kAppHierarchy)
        userDefaults.removeObject(forKey: kAccStatus)
        userDefaults.removeObject(forKey: kAppDrawType)
        userDefaults.removeObject(forKey: kAppDrawColor)
        userDefaults.synchronize()
    }
}
