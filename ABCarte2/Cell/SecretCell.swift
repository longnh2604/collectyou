//
//  SecretCell.swift
//  ABCarte2
//
//  Created by Long on 2018/08/30.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class SecretCell: UITableViewCell {
    
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
            lblTitle.backgroundColor = .red
            self.backgroundColor = .darkGray
        } else {
            lblTitle.backgroundColor = .clear
            self.backgroundColor = .white
        }
    }
    
    func configure(content: String){
        lblTitle.text = content
    }
    
}
