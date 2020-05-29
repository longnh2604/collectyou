//
//  StaffPermissionCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/02/07.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

protocol StaffPermissionCellDelegate: class {
    func onSelectCheckbox(index: Int, position: Int)
}

class StaffPermissionCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblStaffName: UILabel!
    @IBOutlet weak var imvStaff: UIImageView!
    @IBOutlet weak var btnCustomer: UIButton!
    @IBOutlet weak var btnKarte: UIButton!
    @IBOutlet weak var btnBrochure: UIButton!
    @IBOutlet weak var btnContract: UIButton!
    
    //Variable
    weak var delegate: StaffPermissionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imvStaff.image = nil
    }
    
    func configure(staff:StaffData,permission:[Int]) {
        lblStaffName.text = staff.staff_name
        if staff.avatar_url != "" {
            imvStaff.sd_setImage(with: URL(string: staff.avatar_url), completed: nil)
        } else {
            imvStaff.image = UIImage(named: "icon_no_avatar")
        }
    
        let cus = Utils.findObjectArrayInt(value: StaffPermission.customer.rawValue, in: permission)
        let karte = Utils.findObjectArrayInt(value: StaffPermission.karte.rawValue, in: permission)
        let brochure = Utils.findObjectArrayInt(value: StaffPermission.brochure.rawValue, in: permission)
        let contract = Utils.findObjectArrayInt(value: StaffPermission.contract.rawValue, in: permission)
        cus == true ? btnCustomer.setImage(UIImage(named: "icon_check_box.png"), for: .normal):btnCustomer.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
        karte == true ? btnKarte.setImage(UIImage(named: "icon_check_box.png"), for: .normal):btnKarte.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
        brochure == true ? btnBrochure.setImage(UIImage(named: "icon_check_box.png"), for: .normal):btnBrochure.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
        contract == true ? btnContract.setImage(UIImage(named: "icon_check_box.png"), for: .normal):btnContract.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
        
        checkCondition()
    }
    
    private func checkCondition() {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kStaffManagement.rawValue) {
            btnKarte.isHidden = false
        }
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kContract.rawValue) {
            btnBrochure.isHidden = false
            btnContract.isHidden = false
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSelectRole(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        delegate?.onSelectCheckbox(index: indexPath.row, position: sender.tag)
        switch sender.tag {
        case StaffPermission.customer.rawValue:
            if sender.currentImage == UIImage(named: "icon_uncheck_box.png") {
                btnCustomer.setImage(UIImage(named: "icon_check_box.png"), for: .normal)
            } else {
                btnCustomer.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
            }
        case StaffPermission.karte.rawValue:
            if sender.currentImage == UIImage(named: "icon_uncheck_box.png") {
                btnKarte.setImage(UIImage(named: "icon_check_box.png"), for: .normal)
            } else {
                btnKarte.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
            }
        case StaffPermission.brochure.rawValue:
            if sender.currentImage == UIImage(named: "icon_uncheck_box.png") {
                btnBrochure.setImage(UIImage(named: "icon_check_box.png"), for: .normal)
            } else {
                btnBrochure.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
            }
        case StaffPermission.contract.rawValue:
            if sender.currentImage == UIImage(named: "icon_uncheck_box.png") {
                btnContract.setImage(UIImage(named: "icon_check_box.png"), for: .normal)
            } else {
                btnContract.setImage(UIImage(named: "icon_uncheck_box.png"), for: .normal)
            }
        default:
            break
        }
    }
}
