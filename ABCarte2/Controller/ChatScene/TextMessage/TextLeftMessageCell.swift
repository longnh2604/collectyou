//
//  TextLeftMessageCell.swift
//  Chat
//
//  Created by None on 8/8/19.
//  Copyright © 2019 ConnectyCube. All rights reserved.
//

import UIKit

class TextLeftMessageCell: TextMessageCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundImageView?.incomingTail = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
