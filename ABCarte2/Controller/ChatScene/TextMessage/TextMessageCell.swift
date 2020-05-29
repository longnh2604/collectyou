//
//  TextMessageCell.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import SwiftDate

class TextMessageCell: BaseCell {
    
    @IBOutlet weak var messageTextLabel: ContextLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundImageView?.incomingTail = true
    }
    
    func setText(text: String?, dateSent date: Date, status: MessageStatus?) {
        messageTextLabel?.text = text
        dateLabel.text = date.toLocalTime().toFormat(#"MM/dd"# + "\nHH:mm", locale: Locale.current)
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessageInfo.rawValue) {
            updateMessageStatus(status: status)
        } else {
            statusLabel.text = ""
        }
        
        messageTextLabel?.didTouch = { (touchResult) in
            switch touchResult.state {
            case .ended:
                switch touchResult.linkResult?.detectionType {
                case .phoneNumber:
                    self.pressDelegate?.didPhonePress(no: touchResult.linkResult?.text ?? "")
                case .url:
                    self.pressDelegate?.didLinkPress(url: touchResult.linkResult?.text ?? "")
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    fileprivate func updateMessageStatus(status: MessageStatus?) {
        if (status != nil) {
            switch status {
            case .sending:
                statusLabel?.text = ""
            case .delivered:
                statusLabel?.text = ""
            case .sent:
                statusLabel?.text = ""
            case .read:
                statusLabel?.text = "既読"
            case .error:
                statusLabel?.text = "送信失敗"
            default:
                statusLabel?.text = ""
                break
            }
        } else {
            statusLabel?.text = ""
        }
    }
}
