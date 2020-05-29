//
//  PaymentCell.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/17.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol PaymentCellDelegate: class {
    func onCalendarSelect(index: Int)
    func onPaymentMethodSelect(index: Int,button: UIButton)
    func onAddMoney(index: Int)
    func onEditingValue()
}

class PaymentCell: UITableViewCell,UITextFieldDelegate {

    //IBOutlet
    @IBOutlet weak var tfNo: UITextField!
    @IBOutlet weak var tfMoneyPay: UITextField!
    @IBOutlet weak var btnCalendar: RoundButton!
    @IBOutlet weak var btnPayMethod: RoundButton!
    
    //Variable
    weak var delegate: PaymentCellDelegate?
    let maxLength = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(index:Int) {
        btnCalendar.tag = index
        btnPayMethod.tag = index
        let no = index + 1
        
        if tfNo.text!.isEmpty {
            tfNo.text = "\(no)"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil && newString.length <= maxLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" || textField.text == "¥" {
            textField.text = "¥0"
        }
    }
    
    @IBAction func onMoneyAdd(_ sender: UITextField) {
        delegate?.onAddMoney(index: btnCalendar.tag)
    }
    
    @IBAction func onEditing(_ sender: UITextField) {
        delegate?.onEditingValue()
    }
    
    @IBAction func onCalendarSelect(_ sender: UIButton) {
        delegate?.onCalendarSelect(index: sender.tag)
    }
    
    @IBAction func onPayMethod(_ sender: UIButton) {
        delegate?.onPaymentMethodSelect(index: sender.tag,button:sender)
    }
}
