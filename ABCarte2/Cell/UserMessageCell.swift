//
//  UserMessageCell.swift
//  ABCarte2
//
//  Created by Long on 2019/08/23.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import ConnectyCube
import SDWebImage

class UserMessageCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    //Variable
    var selectedCell: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            btnCheckBox.setImage(UIImage(named: "icon_check_box"), for: .normal)
            contentView.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
        } else {
            btnCheckBox.setImage(UIImage(named: "icon_uncheck_box"), for: .normal)
            contentView.backgroundColor = UIColor.clear
        }
    }
    
    fileprivate func setupLayout() {
        imvCus.layer.cornerRadius = 30
        imvCus.layer.borderWidth = 2
        imvCus.layer.borderColor = UIColor.gray.cgColor
    }
    
    func configureCell(dialog:ChatDialog,index:Int) {
        btnCheckBox.tag = index
        
        if let photo = dialog.photo {
            imvCus.sd_setImage(with: URL(string: photo), completed: nil)
        }
        
        lblCusName.text = dialog.name
    }
    
}
