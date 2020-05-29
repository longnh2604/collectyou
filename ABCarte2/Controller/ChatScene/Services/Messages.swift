//
//  ChatHandler.swift
//  Chat
//
//  Created by ConnectyCube.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import ConnectyCube

class Messages: NSObject {
    
    private var readQueue = Set<String>()
    
    override init() {
        super.init()
        Chat.instance.addDelegate(self)
    }
    
    //MARK: - Send message
    
    /// Send ChatMessage instnace
    ///
    /// - Parameters:
    ///   - message: Chat message instance
    ///   - dialog: Chat dialog instance
    ///   - completion: Completion handler
    func sendMessage(message: ChatMessage, to dialog: ChatDialog, completion: @escaping() -> Void) {
        dialog.send(message) {(error) in
            if dialog.type == .private {
                self.update(dialog: dialog, with: message, status: error == nil ? .sent : .error)
            }
            completion()
        }
        self.update(dialog: dialog, with: message, status: .sending)
    }
    
    /// Send message with text
    ///
    /// - Parameters:
    ///   - text: Message text
    ///   - dialog: ChatDialog instance
    ///   - completion: Completion handler
    func sendMessage(with text: String, to dialog: ChatDialog, completion: @escaping () -> Void) {
        let message = ChatMessage.markable()
        message.text = text
        sendMessage(message: message, to: dialog, completion: completion)
    }
    
    /// Send message with image
    ///
    /// - Parameters:
    ///   - image: UIImage instance
    ///   - text: Message text
    ///   - dialog: ChatDialog instance
    ///   - completion: Completion handler
    func sendMessage(with image: UIImage, text: String, to dialog: ChatDialog, progress: @escaping (Float) -> Void,  completion: @escaping () -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        Request.uploadFile(with: data, fileName: "image.jpg", contentType: "image/jpg", isPublic: true, progressBlock: { (uploadProgress) in
            progress(uploadProgress)
        }, successBlock: { (blob) in
            //Create text message
            let message = ChatMessage.markable()
            message.text = text
            //Attachment
            let attachment = ChatAttachment()
            attachment.type = blob.contentType
            attachment.url = blob.publicUrl()
            //Set attachement
            message.attachments = [attachment]
            //Send message
            self.sendMessage(message: message, to: dialog, completion: completion)
        })
    }
    
    //MARK: - Read/Delete/Edit Messate
    
    /// Read message
    ///
    /// - Parameter message: Chat message to read
    func readMessage(_ message: ChatMessage) {
        
        guard !readQueue.contains(message.id!), message.readIDs != nil, !message.readIDs!.contains(Profile.currentProfile!.id as NSNumber) else { return }
        Chat.instance.read(message) { (error) in
            self.readQueue.remove(message.id!)
            if error == nil {
                if let dialog: ChatDialog = Cache.dialogs.object(forKey: message.dialogID!) {
                    if dialog.unreadMessagesCount > 0 {
                        dialog.unreadMessagesCount -= 1
                    }
                    Cache.dialogs.insert(dialog)
                }
            }
        }
    }
    
    /// Delete message
    ///
    /// - Parameters:
    ///   - dialog: Chat dialog instance
    ///   - message: Chat message instance to delete
    func deleteMessage(from dialog: ChatDialog, message: ChatMessage) {
        dialog.removeMessage(withID: message.id!) { (error) in
            if error == nil, dialog.type == .private {
                self.updateDialog(dialog: dialog, withRemoved: message)
                Cache.messages.remove(message.id!, inCollection: dialog.id!)
                Cache.dialogs.insert(dialog)
            }
        }
    }
    
    /// Edit message
    ///
    /// - Parameters:
    ///   - dialog: Chat dialog instance
    ///   - message: Chat message to edit
    ///   - newText: New text
    func editMessage(in dialog: ChatDialog, message: ChatMessage, newText: String) {
        dialog.editMessage(withID: message.id!, text: newText, last: true) { (error) in
            if error == nil {
                message.text = newText
                self.updateDialog(dialog: dialog, withEdited: message)
                Cache.messages.insert(message, inCollection: dialog.id!)
            }
        }
    }
    
    //MARK: - Retrieve messages
    
    /// Messages updates with dialogID
    ///
    /// - Parameters:
    ///   - withDialogID: ChatDialog ID
    ///   - afterMessage: ChatMessage instance
    func updates(with dialogID: String) {
        Request.messages(withDialogID: dialogID,
                         extendedRequest: ["sort_desc" : "date_sent", "mark_as_read" : "0"],
                         paginator: Paginator.limit(100, skip: 0),
                         successBlock: { (messages, p) in
                            Cache.messages.removeAllObjects(inCollection: dialogID)
                            Cache.messages.insert(messages, collection: dialogID)
        })
    }
    
    /// Load more
    ///
    /// - Parameters:
    ///   - message: Chat message instance
    ///   - dialogID: Chat Dialog id
    func loadMore(before message: ChatMessage, dialogID: String) {
        var ext = [String:String]()
        if let date = message.updatedAt != nil ? message.updatedAt : message.dateSent {
            ext["updated_at[lt]"] = "\(UInt(date.timeIntervalSince1970))"
        }
        ext["sort_desc"] = "date_sent"
        ext["mark_as_read"] = "0"
        
        Request.messages(withDialogID: dialogID,
                         extendedRequest: ext,
                         paginator: Paginator.limit(100, skip: 0),
                         successBlock: { (messages, p) in
                            Cache.messages.insert(messages, collection: dialogID)
        })
    }
}

//MARK: Dialog updates

fileprivate extension Messages {
    
    func updateDialog(dialog: ChatDialog, withEdited message: ChatMessage) {
        
        if let cachedMessage: ChatMessage = Cache.messages.object(forKey: message.id!, inCollection: dialog.id!) {
            message.dateSent = cachedMessage.dateSent
            message.attachments = cachedMessage.attachments
            //Sorted all keys
            let messagesIDs = Cache.messages.allKeys(dialog.id!).sorted{ $0 < $1 }
            let index = messagesIDs.firstIndex(of: message.id!)!
            let isLastMessage = index + 1 == messagesIDs.count
            if (isLastMessage) {
                dialog.lastMessageText = message.text
            }
        }
    }
    
    func updateDialog(dialog: ChatDialog, withRemoved message: ChatMessage) {
        //Sorted all keys
        let messagesIDs = Cache.messages.allKeys(dialog.id!).sorted{ $0 < $1 }
        if messagesIDs.count > 1 {
            let index = messagesIDs.firstIndex(of: message.id!)!
            let isLastMessage = index + 1 == messagesIDs.count
            if (isLastMessage) {
                let previousMessageID = messagesIDs[index-1]
                let previousMessage: ChatMessage = Cache.messages.object(forKey: previousMessageID, inCollection: dialog.id!)!
                dialog.lastMessageText = previousMessage.text
            }
        }
        else if messagesIDs.count == 1 {
            dialog.lastMessageText = nil
        }
        
        if let cachedMessage: ChatMessage = Cache.messages.object(forKey: message.id!, inCollection: dialog.id!) {
            if cachedMessage.readIDs != nil,
                !cachedMessage.readIDs!.contains(NSNumber(value:Profile.currentProfile!.id)),
                dialog.unreadMessagesCount > 0 {
                dialog.unreadMessagesCount -= 1
            }
        }
    }
    
    func update(dialog: ChatDialog, with message: ChatMessage, status: MessageStatus) {
        
        message.status = status
        
        if message.removed {
            self.updateDialog(dialog: dialog, withRemoved: message)
            Cache.messages.remove(message, fromCollection: dialog.id!)
        }
        else if message.edited {
            self.updateDialog(dialog: dialog, withEdited: message)
            Cache.messages.insert(message, inCollection: dialog.id!)
        }
        else {
            dialog.lastMessageText = message.text
            dialog.updatedAt = message.dateSent
            if let id = Profile.currentProfile?.id {
                if message.senderID != id, !message.delayed {
                    dialog.unreadMessagesCount += 1
                }
                Cache.messages.insert(message, inCollection: dialog.id!)
            }
        }
        
        Cache.dialogs.insert(dialog)
    }
}

// MARK: - ChatDelegate

extension Messages: ChatDelegate {
    
    //MARK: Did Receive
    func chatRoomDidReceive(_ message: ChatMessage, fromDialogID dialogID: String) {
        let dialog: ChatDialog? = Cache.dialogs.object(forKey: dialogID)
        if let cachedMessage: ChatMessage = Cache.messages.object(forKey: message.id!, inCollection: dialogID) {
            message.status = cachedMessage.status
        }
        
        update(dialog: dialog!, with: message, status: .sent)
    }
    
    func chatDidReceive(_ message: ChatMessage) {
        var dialog: ChatDialog? = Cache.dialogs.object(forKey: message.dialogID!)
        if dialog == nil {
            dialog = ChatDialog(dialogID: message.dialogID, type: .private)
            dialog!.occupantIDs = [message.senderID] as [NSNumber]
            let user: User? = Cache.users.object(forKey: "\(message.senderID)")
            dialog!.name = user?.fullName ?? "Unknown"
        }
        update(dialog: dialog!, with: message, status: .sent)
    }
    
    //MARK: Read / Deliver
    
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if let dialog: ChatDialog? = Cache.dialogs.object(forKey: dialogID) {
            if let message: ChatMessage = Cache.messages.object(forKey: messageID, inCollection:dialogID) {
                var readIDs = message.readIDs ?? [NSNumber]()
                readIDs.append(NSNumber(value: readerID))
                message.readIDs = readIDs
                update(dialog: dialog!, with: message, status: .read)
            }
        }
    }
    
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if let dialog: ChatDialog? = Cache.dialogs.object(forKey: dialogID) {
            if let message: ChatMessage = Cache.messages.object(forKey: messageID, inCollection:dialogID) {
                var deliveredIDs = message.deliveredIDs ?? [NSNumber]()
                deliveredIDs.append(NSNumber(value: userID))
                message.deliveredIDs = deliveredIDs
                update(dialog: dialog!, with: message, status: .delivered)
            }
        }
    }
}
