//
//  ChatMessage+Type.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import ConnectyCube

enum MessageType: String {
    case text,
    png = "image/png",
    jpg = "image/jpg",
    gif = "image/gif",
    jpeg = "image/jpeg",
    mpg4 = "video/mpg4"
}

enum MessageStatus: String {
    case sending
    case sent
    case read
    case delivered
    case error
}

extension ChatMessage {
    
    func type() -> MessageType {
        if attachments != nil,let type = attachments?.first?.type {
            if (attachments?.first?.url) != nil {
                return MessageType(rawValue: type)!
            }
            return .text
        }
        return .text
    }
}

extension ChatMessage {
    
    var status: MessageStatus? {
        get {
            guard self.senderID == Profile.currentProfile?.id else {
                return nil
            }
            if let readIDs = self.readIDs, readIDs.count > 1 {
                return .read
            }
            if let deliveredIDs = self.deliveredIDs, deliveredIDs.count > 1 {
                return .delivered
            }
            if let status = self.localParameters["status"] as? String {
               return MessageStatus(rawValue: status)
            }
            return .sent
        }
        set {
            self.localParameters["status"] = newValue?.rawValue
        }
    }
}
