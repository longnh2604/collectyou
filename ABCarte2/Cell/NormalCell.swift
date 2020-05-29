//
//  NormalCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/02.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class NormalCell: UITableViewCell {

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
}
