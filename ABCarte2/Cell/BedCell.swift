//
//  BedCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/15.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class BedCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var lblBedName: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            contentView.backgroundColor = COLOR_SET.kBACKGROUND_LIGHT_GRAY
        } else {
            contentView.backgroundColor = UIColor.clear
        }
    }
    
    func configure(bed:BedData) {
        btnNo.setTitle("\(bed.display_num)", for: .normal)
        lblBedName.text = bed.bed_name
        lblNote.text = bed.note
    }
    
}
