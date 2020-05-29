//
//  SubVideoCell.swift
//  ABCarte2
//
//  Created by Long on 2019/07/22.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class SubVideoCell: UICollectionViewCell {

    @IBOutlet weak var imvCell: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(video:VideoData) {
        lblTitle.text = video.title
        lblDesc.text = video.desc
        
        imvCell.sd_setImage(with: URL(string: video.thumbnail), completed: nil)
    }
}
