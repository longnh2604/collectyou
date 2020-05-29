//
//  KeyedObject.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import ConnectyCube

protocol KeyedObject {
    var key: String {get}
}

extension User : KeyedObject {
    var key: String { return "\(id)" }
}

extension ChatDialog : KeyedObject {
    var key: String { return id! }
}

extension ChatMessage : KeyedObject {
    var key: String { return id! }
}
