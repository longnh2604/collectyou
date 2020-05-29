//
//  DialogCell.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import SwiftDate
import BadgeSwift
import ConnectyCube

protocol DialogCellDelegate: class {
    func onMoveChat(dialog:ChatDialog)
}

class DialogCell: BaseCell {

    //IBOutlet
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeSwift!
    
    //Variable
    var dialog = ChatDialog(dialogID: nil, type: .private)
    weak var delegate:DialogCellDelegate?
    
    public func setLastMessageText(lastMessageText: String?, date: Date, unreadMessageCount: UInt) {
        messageTextLabel.text = lastMessageText
        dateLabel.text = date.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.current)
         badgeView.text = "1+"
        badgeView.isHidden = unreadMessageCount == 0
    }
    
    @IBAction func onMoveChatScreen(_ sender: UIButton) {
        delegate?.onMoveChat(dialog: self.dialog)
    }
}
