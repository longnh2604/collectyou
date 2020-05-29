//
//  CITreeViewCell.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

protocol CITreeViewCellDelegate: class {
    func onCheckBoxSelect(id:Int)
}

class CITreeViewCell: UITableViewCell {
    
    //IBOutlet
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var viewContains: UIImageView!
    
    //Variable
    var selectedCell: Bool?
    weak var delegate:CITreeViewCellDelegate?
    
    let leadingValueForChildrenCell:CGFloat = 30
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(level:Int)
    {
        self.leadingConstraint.constant = leadingValueForChildrenCell * CGFloat(level + 1)
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2
        switch level {
        case 0:
            self.avatarImageView.image = UIImage(named: "icon_head")
        case 1:
            self.avatarImageView.image = UIImage(named: "icon_shop")
        case 2:
            self.avatarImageView.image = UIImage(named: "icon_small_shop")
        default:
            self.avatarImageView.image = UIImage(named: "icon_small_shop")
        }
        update()
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update() {
        if selectedCell == true {
            btnCheckBox.setImage(UIImage(named: "icon_check_box"), for: .normal)
        } else {
            btnCheckBox.setImage(UIImage(named: "icon_uncheck_box"), for: .normal)
        }
    }
    
    @IBAction func onCheck(_ sender: UIButton) {
        self.delegate?.onCheckBoxSelect(id: sender.tag)
    }
}
