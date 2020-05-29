//
//  PlayerCell.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    
    var data:VideoData? {
        didSet {
            if let thumb = data?.thumbnail {
                let url = URL(string: thumb)
                let urlData = try? Data(contentsOf: url!)
                self.imgView.image = UIImage(data: urlData!)
            }
            self.labTitle.text = data?.title
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full
            formatter.accessibilityLanguage = "ja"
            
            if let dur = data?.video_duration,let last = data?.last_updated {
                self.lblDuration.text = "動画の長さ:" + Utils.formatSecondsToString(TimeInterval(dur)) + " ---  最終更新:" + Utils.convertUnixTimestampDT(time: last)
            }
            
            
        }
    }
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.isHidden = false
        data = nil
    }
}
