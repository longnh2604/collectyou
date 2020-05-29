//
//  ChatApp.swift
//  Chat
//
//  Created by ConnectyCube.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import ConnectyCube
import YapDatabase
import UserNotifications

struct ChatApp {
    /// Users service
    static let users = Users()
    /// Dialogs Servcie
    static let dialogs = Dialogs()
    /// Messages messages
    static let messages = Messages()
}

// MARK: Connect / Disconnect

extension ChatApp {
    
    /// Connect to chat / Login if needed / Dialogs updates
    static func connect() {
        //Validate session
        let user: User = Profile.currentProfile!
        users.login(withUser: user) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
            }
            dialogs.getUpdates()
            users.getUpdates()
        }
        NotificationBar.showStatus(with: "接続中...")
        Chat.instance.connect(withUserID: user.id, password: user.password!){ (error) in
            NotificationBar.hideAll()
        }
    }
    
    /// Connect to chat / Login if needed / Dialogs updates
    static func connectWithSelectedDialogs(dialogsID:[String],completion: @escaping () -> Void) {
        //Validate session
        let user: User = Profile.currentProfile!
        users.login(withUser: user) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
            }
            dialogs.getUpdatesDialogWithSelectedDialog(dialogSelected: dialogsID)
            users.getUpdates()
        }
        NotificationBar.showStatus(with: "接続中...")
        Chat.instance.connect(withUserID: user.id, password: user.password!){ (error) in
            NotificationBar.hideAll()
            completion()
        }
    }
    
    /// Logout from app
    ///
    /// - Parameter completion: completion handler
    static func logOut(completion: @escaping () -> Void) {
        Chat.instance.disconnect(completionBlock: { (error) in
            // Clearing cache
            Cache.removeAll()
        })
        Request.unregisterSubscription(forUniqueDeviceIdentifier: UIDevice.current.identifierForVendor!.uuidString, successBlock: nil)
        Request.logOut(successBlock: {
            completion()
        }) { (error) in
            completion()
        }
    }
}

struct Cache {
    
    static let keyValue = Storage(withFileName:"storage.sqlite")
    static let users = ObservableStorage(withFileName: "users.sqlite")
    static let dialogs = ObservableStorage(withFileName: "dialogs.sqlite")
    static let messages = ObservableStorage(withFileName: "messages.sqlite")

    static func removeAll() {
        keyValue.removeAllObjectsInAllCollections()
        users.removeAllObjectsInAllCollections()
        dialogs.removeAllObjectsInAllCollections()
        messages.removeAllObjectsInAllCollections()
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
