//
//  MessageTemplateCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/26.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class MessageTemplateCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

        if selected {
            self.backgroundColor = .lightGray
        } else {
            self.backgroundColor = .white
        }
    }
    
    func configure(content: String){
        lblTitle.text = content
    }
}
