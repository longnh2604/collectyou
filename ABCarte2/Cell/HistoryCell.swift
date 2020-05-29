//
//  HistoryCell.swift
//  ABCarte2
//
//  Created by Long on 2018/12/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol HistoryCellDelegate: class {
    func onSelectDetail(index: Int)
}

class HistoryCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblCusNameKana: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblRepresentativeName: UILabel!
    @IBOutlet weak var lblBedNo: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet weak var lblVisitTime: UILabel!
    
    //Variable
    weak var delegate: HistoryCellDelegate?
    
    deinit {
        print("Memory release")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setupLayout() {
        viewGender.layer.cornerRadius = 5
        imvCus.layer.borderColor = UIColor.black.cgColor
        imvCus.layer.borderWidth = 1
        imvCus.layer.cornerRadius = 35
        imvCus.clipsToBounds = true
    }
    
    func configure(data: CarteData){
        
        setupLayout()
        
        if data.cus[0].gender == 0 {
            lblGender.text = "不明"
            viewGender.backgroundColor = UIColor.lightGray
        } else if data.cus[0].gender == 1 {
            lblGender.text = "男性"
            viewGender.backgroundColor = COLOR_SET.kMALE_COLOR
        } else {
            lblGender.text = "女性"
            viewGender.backgroundColor = COLOR_SET.kFEMALE_COLOR
        }
        
        lblCusName.text = data.cus[0].last_name + " " + data.cus[0].first_name
        lblCusNameKana.text = data.cus[0].last_name_kana + " " + data.cus[0].first_name_kana
        
        lblShopName.text = data.account_name
        
        if data.cus[0].pic_url == "" {
            imvCus.image = UIImage(named: "img_no_photo")
        } else {
            let url = URL(string: data.cus[0].pic_url)
            imvCus.sd_setImage(with: url) { (image, error, cache, url) in
            }
        }
        Utils.setButtonColorStyle(button: btnDetail,type: 1)
        
        let visitTime = Utils.convertUnixTimestampHMOnly(time: data.select_date)
        lblVisitTime.text = visitTime
        
        if data.staff_name == "" {
            lblRepresentativeName.text = "未登録"
        } else {
            lblRepresentativeName.text = data.staff_name
        }
        
        if data.bed_name == "" {
            lblBedNo.text = "未登録"
        } else {
            lblBedNo.text = data.bed_name
        }
        
        if data.carte_mark == 1 {
            self.backgroundColor = COLOR_SET.kOCEANGREEN
        } else {
            self.backgroundColor = UIColor.clear
        }
        
        checkCondition()
    }
    
    private func checkCondition() {
        if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteTime.rawValue) {
            lblVisitTime.text = "----"
        }
        if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kStaffManagement.rawValue) {
            lblRepresentativeName.text = "----"
        }
        if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kBedManagement.rawValue) {
            lblBedNo.text = "----"
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSelectDetail(_ sender: UIButton) {
        delegate?.onSelectDetail(index: sender.tag)
    }
}
