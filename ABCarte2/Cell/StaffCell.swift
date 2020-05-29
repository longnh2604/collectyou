//
//  StaffCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/08.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class StaffCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var imvStaff: UIImageView!
    
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
    
    func configure(staff:StaffData) {
        lblName.text = staff.staff_name
        lblCompany.text = staff.company_name
        lblGender.text = checkGender(gender: staff.gender)
        btnNo.setTitle("\(staff.display_num)", for: .normal)
        
        if staff.avatar_url != "" {
            imvStaff.sd_setImage(with: URL(string: staff.avatar_url), completed: nil)
        } else {
            imvStaff.image = UIImage(named: "icon_no_avatar")
        }
        
        var per = ""
        let arr = staff.permission.components(separatedBy: ",")
        let permission = arr.map { Int($0)!}
        if permission.contains(1) {
            per.append("・新規顧客\n")
        }
        if permission.contains(2) {
            per.append("・カルテ\n")
        }
        if permission.contains(3) {
            per.append("・概要書面\n")
        }
        if permission.contains(4) {
            per.append("・契約")
        }
        lblRole.text = per
    }
    
    private func checkGender(gender:Int)->String {
        switch gender {
        case 0:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
        case 1:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: "")
        case 2:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: "")
        default:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
        }
    }
    
    private func checkRole(role:Int)->String {
        switch role {
        case 0:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
        case 1:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "パート", comment: "")
        case 2:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "通常", comment: "")
        case 3:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "医師", comment: "")
        default:
            return LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
        }
    }
    
}
