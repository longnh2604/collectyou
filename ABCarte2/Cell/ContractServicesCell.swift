//
//  ContractServicesCell.swift
//  ABCarte2
//
//  Created by Long on 2019/10/07.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol ContractServicesCellDelegate: class {
    func onContractTapped(index:Int)
    func onBeginInputNoTreat()
    func onNumberOfTreatmentChange(value:Int,index:Int)
}

class ContractServicesCell: UITableViewCell, UITextFieldDelegate {

    //Variable
    weak var delegate: ContractServicesCellDelegate?
    let maxLength = 5
    
    //IBOutlet
    @IBOutlet weak var tfOrder: UITextField!
    @IBOutlet weak var btnCourse: UIButton!
    @IBOutlet weak var tfCourseTime: UITextField!
    @IBOutlet weak var tfCourseUPrice: UITextField!
    @IBOutlet weak var tfCourseNoTreat: UITextField!
    @IBOutlet weak var tfCourseTotalTime: UITextField!
    @IBOutlet weak var tfCourseSubTotal: UITextField!
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        btnCourse.setTitle("コース選択", for: .normal)
        tfCourseTime.text = "0"
        tfCourseUPrice.text = "¥0"
        tfCourseTotalTime.text = "0"
        tfCourseNoTreat.text = ""
        tfCourseNoTreat.placeholder = "手入力"
        tfCourseSubTotal.text = "0"
    }
    
    func configure(index:Int) {
        btnCourse.tag = index
        let no = index + 1
        
        if tfOrder.text!.isEmpty {
            tfOrder.text = "\(no)"
        }
        
        if tfCourseTime.text!.isEmpty {
            tfCourseTime.text = "0"
        }
        
        if tfCourseUPrice.text!.isEmpty {
            tfCourseUPrice.text = "¥0"
        } else {
            tfCourseUPrice.text = tfCourseUPrice.text?.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "").addFormatAmount()
        }
        
        if tfCourseTotalTime.text!.isEmpty {
            tfCourseTotalTime.text = "0"
        }
        
        if tfCourseSubTotal.text!.isEmpty {
            tfCourseSubTotal.text = "0"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil && newString.length <= maxLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "0"
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onBeginInputNoTreatment(_ sender: UITextField) {
        delegate?.onBeginInputNoTreat()
    }
    
    @IBAction func onNumberOfTreatmentChange(_ sender: UITextField) {
        if var text = sender.text {
            if text == "" {
                text = "0"
            }
            delegate?.onNumberOfTreatmentChange(value: Int(text)!,index: btnCourse.tag)
        }
    }
    
    @IBAction func onContractCategorySelect(_ sender: UIButton) {
        delegate?.onContractTapped(index:sender.tag)
    }
}
