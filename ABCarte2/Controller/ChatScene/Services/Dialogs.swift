//
//  Dialogs.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import Foundation
import ConnectyCube
import YapDatabase

class Dialogs: NSObject {
    
    var sortedData: SortedDataProvider<ChatDialog>!
    
    override init() {
        super.init()
        // Default sorting view
        sortedData = SortedDataProvider(sorting: { (d1, d2) -> ComparisonResult in
            return d2.updatedAt!.compare(d1.updatedAt!)
        })
        // Need for join new dialogs
        sortedData.addPresenter(self)
        // Handle Dialogs updates
        Cache.dialogs.register(sortedDataProvider: sortedData)
        Chat.instance.addDelegate(self)
    }
    
    private let errorHandler : (_ error: Error) -> Void = {
        if let reason = ($0 as NSError).userInfo[NSLocalizedFailureReasonErrorKey] as! [AnyHashable : Any]? {
            if let key = reason.keys.first, let value = (reason[key] as! [String]).first {
                SVProgressHUD.showError(withStatus: "\(key): " + value)
                return
            }
        }
        SVProgressHUD.showError(withStatus: $0.localizedDescription)
    }
}

// MARK: - Create / Get  / Update

extension Dialogs {

    // MARK: Create
    
    /// New dialog
    ///
    /// - Parameters:
    ///   - type: ChatDialogType value (.group, .publicGroup, private)
    ///   - name: Chat dialog name
    ///   - occupantsList: Occupants ids
    fileprivate func newDialog(_ type: ChatDialogType, name: String?, occupantsList: [UInt]? = [], completion: @escaping (ChatDialog) -> Void) {
        let dialog = ChatDialog(dialogID: nil, type: type)
        dialog.occupantIDs = occupantsList!.map{$0 as NSNumber}
        dialog.name = name
        Request.createDialog(dialog, successBlock: { (createdDialog) in
            Cache.dialogs.insert(createdDialog)
            completion(createdDialog)
        }, errorBlock: errorHandler)
    }
    
    /// Create Group dialog
    ///
    /// - Parameters:
    ///   - name: Group dialog name
    ///   - occupantsList: occupatns list
    func createGroup(withNamename name: String?, occupantsList: [UInt], completion: @escaping(ChatDialog) -> Void) {
        newDialog(.group, name: name!, occupantsList: occupantsList, completion: completion)
    }
    
    /// Create Private dialog
    ///
    /// - Parameters:
    ///   - id: Opponent id
    ///   - completion: completion handler
    func createPrivate(withOpponentID id: UInt, completion: @escaping(ChatDialog) -> Void) {
        newDialog(.private, name: nil, occupantsList: [id], completion: completion)
    }
    
    // MARK: Remove dialog
    func removeDilaog(with dialogID: String,  completion: (() -> Void)? = nil) {
        Request.deleteDialogs(withIDs: Set([dialogID]),
                              forAllUsers: false,
                              successBlock: { (_, _, _) in
                                Cache.dialogs.remove(dialogID)
                                Cache.messages.removeAllObjects(inCollection: dialogID)
                                completion?()
        })
    }
    
    // MARK: Get updates
    
    /// Get dialogs updates
    public func getUpdates() {
        let paginator = Paginator.limit(100, skip: 0)
        var extRequest : [String: String] = ["sort_desc" : "lastMessageDate"]
        if let date = Profile.lastDialogsFetchDate {
            extRequest["updated_at[gte]"] = "\(date.timeIntervalSince1970)"
        }

        func Recurcive<T>(_ R: (@escaping (@escaping (T) -> Void) -> (T) -> Void)) -> (T) -> Void {
            return { x in R(Recurcive(R))(x) }
        }

        Recurcive { R in
            { paginator in
                Request.dialogs(with: paginator, extendedRequest: extRequest, successBlock: { (dialogs, _, paginator) in
                    Profile.lastDialogsFetchDate = Date()
                    Cache.dialogs.insert(dialogs)
                    if dialogs.count < paginator.limit { return }
                    paginator.skip += UInt(dialogs.count)
                    R(paginator)
                }, errorBlock: self.errorHandler)
            }
            } (Paginator.limit(100, skip: 0))
    }
    
    /// Get dialogs updates
    public func getUpdatesDialogWithSelectedDialog1(dialogs:String) {
        let paginator = Paginator.limit(100, skip: 0)
        var extRequest : [String: String] = ["sort_desc" : "lastMessageDate"]
        if let date = Profile.lastDialogsFetchDate {
            extRequest["updated_at[gte]"] = "\(date.timeIntervalSince1970)"
        }
        extRequest["id[all]"] = dialogs
        
        func Recurcive<T>(_ R: (@escaping (@escaping (T) -> Void) -> (T) -> Void)) -> (T) -> Void {
            return { x in R(Recurcive(R))(x) }
        }

        Recurcive { R in
            { paginator in
                Request.dialogs(with: paginator, extendedRequest: extRequest, successBlock: { (dialogs, _, paginator) in
                    Profile.lastDialogsFetchDate = Date()
                    Cache.dialogs.insert(dialogs)
                    if dialogs.count < paginator.limit { return }
                    paginator.skip += UInt(dialogs.count)
                    R(paginator)
                }, errorBlock: self.errorHandler)
            }
            } (Paginator.limit(100, skip: 0))
    }
    
    public func getUpdatesDialogWithSelectedDialog(dialogSelected:[String]) {
        let paginator = Paginator.limit(100, skip: 0)
        var extRequest : [String: String] = ["sort_desc" : "lastMessageDate"]
        if let date = Profile.lastDialogsFetchDate {
            extRequest["updated_at[gte]"] = "\(date.timeIntervalSince1970)"
        }
        
        func Recurcive<T>(_ R: (@escaping (@escaping (T) -> Void) -> (T) -> Void)) -> (T) -> Void {
            return { x in R(Recurcive(R))(x) }
        }

        Recurcive { R in
            { paginator in
                Request.dialogs(with: paginator, extendedRequest: extRequest, successBlock: { (dialogs, _, paginator) in
                    Profile.lastDialogsFetchDate = Date()
                    let dialog = dialogs as [ChatDialog]
                    var checkDialog = [ChatDialog]()
                    var i = 0
                    repeat {
                        for j in 0 ..< dialogSelected.count {
                            if dialogSelected[j] == dialog[i].id! {
                                checkDialog.append(dialog[i])
                            }
                        }
                        i += 1
                    } while i < dialog.count
                    Cache.dialogs.insert(checkDialog)
                    if dialogs.count < paginator.limit { return }
                    paginator.skip += UInt(dialogs.count)
                    R(paginator)
                }, errorBlock: self.errorHandler)
            }
            } (Paginator.limit(100, skip: 0))
    }
    
    // MARK: Update dialog
    
    func upadateDialog(withImageData data: Data, dialog: ChatDialog, progress: @escaping (Float) -> Void) {
        //Upload image
        Request.uploadFile(with: data, fileName: "image.png", contentType: "image/png", isPublic: true, progressBlock: progress ,successBlock: { (blob) in
            //Update dialog with new photo
            let parameters = UpdateChatDialogParameters()
            parameters.photo = blob.publicUrl()
            
            Request.updateDialog(withID: dialog.id!, update: parameters, successBlock: { (updatedDialog) in
                //Cache updated dialog
                Cache.dialogs.insert(updatedDialog)
            }, errorBlock: self.errorHandler)
        }, errorBlock: errorHandler)
    }
    
    func markDialogAsRead(_ dialog: ChatDialog, completion: (() -> Void)? = nil) {
        Request.markMessages(asRead: nil, dialogID: dialog.id!, successBlock: {
            dialog.unreadMessagesCount = 0
            Cache.dialogs.insert(dialog)
            completion?()
        })
    }
}

// MARK: - ChatDelegate

extension Dialogs: ChatDelegate {
    
    func chatDidConnect() {
        /// Joing in to group dialog
        let dialogs : [ChatDialog] = Cache.dialogs.allObjects()
        dialogs.forEach({ (dialog) in
            if dialog.type == .group, !dialog.isJoined() {
                dialog.join()
            }
        })
    }
}

// MARK: ChangesPresenter

extension Dialogs: ChangesPresenter {
    
    func changeReceive(changes: [YapDatabaseViewRowChange]) {
        changes.forEach { (change) in
            //Join if new dialog
            if change.type == .insert,
                let dialog: ChatDialog = Cache.dialogs.object(forKey: change.collectionKey.key)!,
                dialog.type == .group {
                    dialog.join()
                }
            }
    }
}

extension ChatDialog {
    var dialogPhoto: String? {
        let userID = occupantIDs?.filter{ $0.intValue != Profile.currentProfile!.id}.first
        guard userID != nil else {return nil}
        let user: User? =  Cache.users.object(forKey: "\(userID!.uint32Value)")
        let imageUrl = type == .group ? photo : user?.avatar
        return imageUrl
    }
}
