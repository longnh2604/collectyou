//
//  MainListCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/18.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class MainListCell: UITableViewCell {

    @IBOutlet weak var PointGender: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblHiragana: UILabel!
    @IBOutlet weak var lblKanji: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblLastCome: UILabel!
    @IBOutlet weak var lblCusID: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var lblCusStatus: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var btnNewMessage: RoundButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            contentView.backgroundColor = COLOR_SET.kOCEANGREEN
        } else {
            contentView.backgroundColor = UIColor.clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imvCus.image = nil
    }
    
    func configure(with customer: CustomerData,accName:String) {
        
        setupLayout()
        
        lblCusID.text = customer.customer_no
        lblShopName.text = customer.acc_name
        
        if customer.birthday != 0 {
            lblBirthday.text = Utils.convertUnixTimestamp(time: customer.birthday)
        } else {
            lblBirthday.text = ""
        }

        if customer.last_daycome != 0 {
            let dayCome = Utils.convertUnixTimestamp(time: customer.last_daycome)
            lblLastCome.text = dayCome
        } else {
            lblLastCome.text = ""
        }

        lblKanji.text = customer.last_name + " " + customer.first_name
        lblHiragana.text = customer.last_name_kana + " " + customer.first_name_kana
        
        if customer.gender == 0 {
            lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
            PointGender.backgroundColor = UIColor.lightGray
        } else if customer.gender == 1 {
            lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: "")
            PointGender.backgroundColor = COLOR_SET.kMALE_COLOR
        } else {
            lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: "")
            PointGender.backgroundColor = COLOR_SET.kFEMALE_COLOR
        }
        
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, completed: nil)
        } else {
            imvCus.image = UIImage(named: "icon_no_avatar")
        }
        
        if customer.cus_msg_inbox > 0 {
            btnNewMessage.isHidden = false
        } else {
            btnNewMessage.isHidden = true
        }
    }
    
    fileprivate func setupLayout() {
        PointGender.layer.cornerRadius = 5
        PointGender.clipsToBounds = true
        
        lblCusStatus.layer.cornerRadius = 5
        lblCusStatus.layer.backgroundColor = COLOR_SET000.kSELECT_BACKGROUND_COLOR.cgColor
        
        imvCus.layer.borderWidth = 1
        imvCus.layer.borderColor = UIColor.black.cgColor
        imvCus.layer.cornerRadius = 35
        imvCus.clipsToBounds = true
    }
}
