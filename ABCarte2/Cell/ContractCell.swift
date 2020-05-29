//
//  ContractCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/17.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol ContractCellDelegate: class {
    func onAddContract(type:Int,time:Int,id: Int,index:Int)
    func onPreviewContract(type:Int,id:Int,url:String,index:Int)
    func onAddCustomerFinalSign(id:Int,index:Int,type:Int)
}

class ContractCell: UITableViewCell {
    
    //IBOutlet
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnBrochure: UIButton!
    @IBOutlet weak var btnContract: UIButton!
    @IBOutlet weak var btnCustomerSign: UIButton!
    
    //Variable
    weak var delegate:ContractCellDelegate?
    var createdTime: Int?
    var brochureID: Int?
    var brochureURL: String?
    var contractURL: String?
    var brochureConfirmURL: String?
    var contractConfirmURL: String?
    
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
        
        btnBrochure.setTitle("概要書面", for: .normal)
        btnContract.setTitle("契約書", for: .normal)
        btnCustomerSign.setTitle("概要書面", for: .normal)
    }
    
    func configure(brochure:BrochureData,index:Int) {
        lblDate.text = Utils.convertUnixTimestamp(time: brochure.select_date)
        createdTime = brochure.created_at
        brochureID = brochure.id
        brochureURL = brochure.brochure_signed_url
        contractURL = brochure.contract_signed_url
        brochureConfirmURL = brochure.brochure_confirm_signed_url
        contractConfirmURL = brochure.contract_confirm_signed_url
        btnBrochure.tag = index
        btnContract.tag = index
        btnCustomerSign.tag = index
        
        if brochureURL != "" {
            if brochure.broch_print_date != 0 {
                let print_date = Utils.convertUnixTimestampUK(time: brochure.broch_print_date)
                btnBrochure.setTitle("印刷済 \(print_date)", for: .normal)
                btnBrochure.backgroundColor = COLOR_SET.kPINK
            } else {
                let date = Utils.convertUnixTimestampUK(time: brochure.broch_create_date)
                btnBrochure.setTitle("作成日 \(date)", for: .normal)
                btnBrochure.backgroundColor = COLOR_SET.kBLUE
            }
        } else {
            btnBrochure.backgroundColor = COLOR_SET.kLIGHTGRAY
        }
        
        if contractURL != "" {
            if brochure.cont_print_date != 0 {
                let print_date = Utils.convertUnixTimestampUK(time: brochure.cont_print_date)
                btnContract.setTitle("印刷済 \(print_date)", for: .normal)
                btnContract.backgroundColor = COLOR_SET.kPINK
            } else {
                let date = Utils.convertUnixTimestampUK(time: brochure.cont_create_date)
                btnContract.setTitle("作成日 \(date)", for: .normal)
                btnContract.backgroundColor = COLOR_SET.kBLUE
            }
        } else {
            btnContract.backgroundColor = COLOR_SET.kLIGHTGRAY
        }
        
        if brochureConfirmURL != "" {
            if contractConfirmURL != "" {
                let date = Utils.convertUnixTimestampUK(time: brochure.hand_over_date)
                btnCustomerSign.setTitle("概・契 \(date)", for: .normal)
                btnCustomerSign.backgroundColor = COLOR_SET.kPINK
            } else {
                let date = Utils.convertUnixTimestampUK(time: brochure.hand_over_date)
                btnCustomerSign.setTitle("概 \(date)", for: .normal)
                btnCustomerSign.backgroundColor = COLOR_SET.kBLUE
            }
        } else {
            btnCustomerSign.backgroundColor = COLOR_SET.kLIGHTGRAY
        }
    }
    
    @IBAction func onAddBrochure(_ sender: UIButton) {
        if let time = createdTime,let id = brochureID,let url = brochureURL {
            if url != "" {
                delegate?.onPreviewContract(type: 1, id: id, url: url,index:sender.tag)
            } else {
                delegate?.onAddContract(type: 1, time: time, id: id,index:sender.tag)
            }
        }
    }
    
    @IBAction func onAddContract(_ sender: UIButton) {
        if let time = createdTime,let id = brochureID,let url = contractURL {
            if url != "" {
                delegate?.onPreviewContract(type: 2, id: id, url: url,index:sender.tag)
            } else {
                if brochureURL != "" {
                    delegate?.onAddContract(type: 2,time: time, id: id,index:sender.tag)
                } else {
                    delegate?.onAddContract(type: 3, time: time, id: id, index: sender.tag)
                }
            }
        }
    }
    
    @IBAction func onAddCustomerFinalSign(_ sender: UIButton) {
        if let id = brochureID {
            if brochureURL != nil && brochureURL != "" {
                delegate?.onAddCustomerFinalSign(id: id, index: sender.tag, type: 1)
            } else {
                delegate?.onAddCustomerFinalSign(id: id, index: sender.tag, type: 2)
            }
        }
    }
}
