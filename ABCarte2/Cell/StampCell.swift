//
//  StampCell.swift
//  ABCarte2
//
//  Created by Long on 2018/08/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StampCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    //Variable
    var selectedCell: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(title: String) {
        lblTitle.text = title
        
        if selectedCell == true {
            lblTitle.backgroundColor = COLOR_SET.kYELLOW
        } else {
            lblTitle.backgroundColor = UIColor.clear
        }
    }
    
    func update() {
        if selectedCell == true {
            lblTitle.backgroundColor = COLOR_SET.kYELLOW
        } else {
            lblTitle.backgroundColor = UIColor.clear
        }
    }
}
