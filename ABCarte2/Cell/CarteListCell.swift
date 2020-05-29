//
//  CarteListCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/12/12.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class CarteListCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvCheckBox: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            imvCheckBox.image = UIImage(named: "icon_tick_box_color")
            contentView.backgroundColor = COLOR_SET.kBACKGROUND_LIGHT_GRAY
        } else {
            imvCheckBox.image = UIImage(named: "icon_untick_box_color")
            contentView.backgroundColor = UIColor.clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(carteData:CarteData) {
        lblDate.text = Utils.convertUnixTimestamp(time: carteData.select_date)
    }
    
    func configureShopData(name:String) {
        lblDate.text = name
    }
}
