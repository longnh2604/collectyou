//
//  AppDelegate.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import UserNotifications
import Alamofire
import ConnectyCube
import FirebaseCore

var AFManager = SessionManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        //ConnectyCube config
        #if AIMB
        Settings.applicationID = 1279
        Settings.authKey = "4xHuf8N3HB55Yhm"
        Settings.authSecret = "gXky7Z7SBTgMamA"
        Settings.accountKey = "qz69qpazXqtWxry-htTa"
        Settings.logLevel = .debug
        //Cachette
//        Settings.applicationID = 2132
//        Settings.authKey = "pXOSrUgDU4-EqQX"
//        Settings.authSecret = "gbeR7tQBCd5XbZm"
//        Settings.accountKey = "3FJJBv7m8DYi5kMK1w9j"
//        Settings.logLevel = .debug
        #elseif ATTENDER
        Settings.applicationID = 1278
        Settings.authKey = "RFAptQ9BcQyQVhy"
        Settings.authSecret = "fdGmQQ6U54QRN5V"
        Settings.accountKey = "_CNsFAiB5BHNZ3eVRrsF"
        Settings.logLevel = .debug
        #elseif ESCOS
        Settings.applicationID = 1474
        Settings.authKey = "Nv3sEsG4Q39va4a"
        Settings.authSecret = "5CjfxNxwmPuLnJu"
        Settings.accountKey = "CAbDuLXFSnyHjyfQtpcU"
        Settings.logLevel = .debug
        #elseif COVISION
        Settings.applicationID = 1823
        Settings.authKey = "LKUZm2cD4Vv8JE3"
        Settings.authSecret = "SCFeXXhyXd9r-FA"
        Settings.accountKey = "ywWwiczwFzc-KssXSoNq"
        Settings.logLevel = .debug
        #else
        Settings.applicationID = 1192
        Settings.authKey = "eDARv4RNVR6HXzt"
        Settings.authSecret = "WnJfHPXKZxLZT9O"
        Settings.accountKey = "bh_byYBvVJrSP3J4RT_a"
        Settings.logLevel = .debug
        #endif
        
        //set Alamofire timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60 // seconds
        configuration.timeoutIntervalForResource = 60 //seconds
        AFManager = Alamofire.SessionManager(configuration: configuration)

        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true

        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
        }
        
        //Solicit permission from the user to receive notifications
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
        }
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 37,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 37) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        UIApplication.shared.statusBarStyle = .lightContent
        //remove if badge exist
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Chat.instance.disconnect()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Chat.instance.disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if Profile.currentProfile != nil {
            ChatApp.connect()
        }
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        let subcription = Subscription()
        subcription.notificationChannel = .APNS
        subcription.deviceToken = deviceToken
        subcription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        Request.createSubscription(subcription, successBlock: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

