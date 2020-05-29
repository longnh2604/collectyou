//
//  ImageLeftTableViewCell.swift
//  Chat
//
//  Created by None on 8/8/19.
//  Copyright © 2019 ConnectyCube. All rights reserved.
//

import UIKit

class ImageLeftTableViewCell: TextMessageCell {
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundImageView?.incomingTail = false
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
