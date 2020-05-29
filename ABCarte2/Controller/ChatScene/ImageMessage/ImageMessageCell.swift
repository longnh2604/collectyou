//
//  ImageMessageCell.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import PINRemoteImage

class ImageMessageCell: TextMessageCell {
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundImageView?.incomingTail = true
        imagePreview.layer.cornerRadius = 5
        imagePreview.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imagePreview.image = nil
    }
    
    func previewImage(withUrl url: String!) {
        imagePreview.pin_updateWithProgress = true
        imagePreview.pin_setImage(from: URL(string:  url))
    }
}
