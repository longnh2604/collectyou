//
//  photoCollectCell.swift
//  ABCarte2
//
//  Created by Long on 2018/10/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage

protocol photoCollectCellDelegate: class {
    func didZoom(index:Int)
}

class photoCollectCell: UICollectionViewCell {
    
    //IBOutlet
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var lblTime: RoundLabel!
    @IBOutlet weak var btnZoom: RoundButton!
    
    //Variable
    weak var delegate:photoCollectCellDelegate?
    
    var imageId: String!
    var type: Int?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 5.0
                layer.borderColor = UIColor(red:56/255, green:192/255, blue:201/255, alpha:1.0).cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureSentPhoto(photoURL:String,time:Date) {
        let url = URL(string: photoURL)
        imvPhoto.sd_setImage(with: url, completed: nil)
    
        let format = DateFormatter()
        format.dateFormat = "yyyy年MM月dd日"
        let formattedDate = format.string(from: time)
        lblTime.text = formattedDate
        
        btnZoom.isHidden = true
    }
    
    func configure(media: MediaData) {

        if media.thumb != "" {
            let url = URL(string: media.url)
            imvPhoto.sd_setImage(with: url, completed: nil)
        } else {
            imvPhoto.image = UIImage(named: "img_no_photo")
        }
        
        btnZoom.tag = media.id
        
        imageId = media.media_id
        
        if let type = type {
            if type == 1 {
                btnZoom.isHidden = false
                let date = Utils.convertUnixTimestampDT(time: media.date)
                lblTime.text = date
            } else {
                btnZoom.isHidden = true
                let date = Utils.convertUnixTimestampT(time: media.date)
                lblTime.text = date
            }
        }
    
        Utils.setButtonColorStyle(button: btnZoom, type: 1)
    }
    
    @IBAction func onZoom(_ sender: UIButton) {
        delegate?.didZoom(index: sender.tag)
    }
}
