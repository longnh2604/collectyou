//
//  Profile.swift
//  Chat
//
//  Created by ConnectyCube.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import ConnectyCube

class Profile {
    
    /// Current User profile
    static var currentProfile : User? {
        set {Cache.keyValue.insert(newValue!, forKey: "currentProfile")}
        get {
            let user: User? = Cache.keyValue.object(forKey: "currentProfile")
            user?.password = DefaultUserPassword
            return user
        }
    }
    
    /// Last users fetch date
    static var lastUsersFetchDate : Date? {
        set {Cache.keyValue.insert(newValue!, forKey: "lastUsersFetchDate")}
        get {return Cache.keyValue.object(forKey: "lastUsersFetchDate")}
    }
    
    /// Last dialogs fetch date
    static var lastDialogsFetchDate : Date? {
        set {Cache.keyValue.insert(newValue!, forKey: "lastDialogsFetchDate")}
        get {return Cache.keyValue.object(forKey: "lastDialogsFetchDate")}
    }
}
