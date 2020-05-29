//
//  AppSelectionCell.swift
//  ABCarte2
//
//  Created by Long on 2018/08/21.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class AppSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var lblAppTitle: UILabel!
    @IBOutlet weak var imvAppPhoto: UIImageView!
    
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
    
    func configure() {
        
    }
}
