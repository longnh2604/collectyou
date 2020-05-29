//
//  ReservationNoCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/14.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class ReservationNoCell: UICollectionViewCell {

    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 5.0
                layer.borderColor = UIColor(red:56/255, green:192/255, blue:201/255, alpha:1.0).cgColor
                viewBackground.backgroundColor = UIColor.green
            } else {
                layer.borderColor = UIColor.clear.cgColor
                viewBackground.backgroundColor = UIColor(red:255/255, green:211/255, blue:241/255, alpha:1.0)
            }
        }
    }

    func configure(index:Int) {
        lblNo.text = "\(index)"
    }
}
