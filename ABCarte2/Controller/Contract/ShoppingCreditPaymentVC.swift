//
//  ShoppingCreditPaymentVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/17.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class ShoppingCreditPaymentVC: BasePaymentVC {

    //IBOutlet
    @IBOutlet weak var btnSCName: UIButton!
    @IBOutlet weak var tfPaymentTimes: UITextField!
    @IBOutlet weak var btnSCFirst: UIButton!
    @IBOutlet weak var btnSCLast: UIButton!
    @IBOutlet weak var btnSCTimes: UIButton!
    @IBOutlet weak var btnSCBonus: UIButton!
    @IBOutlet weak var tfSCWithDrawn1: UITextField!
    @IBOutlet weak var tfSCWithDrawn2: UITextField!
    @IBOutlet weak var tfSCWithDrawn3: UITextField!
    @IBOutlet weak var btnCalendarSCWD: UIButton!
    
    //Variable
    var bonusPay: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupLayout() {
        if settlementData.institution_name != "" {
            btnSCName.setTitle(settlementData.institution_name, for: .normal)
        } else {
            btnSCName.setTitle("リスト選択", for: .normal)
        }
        
        if settlementData.settlement_count != 0 {
            tfPaymentTimes.text = String(settlementData.settlement_count)
        } else {
            tfPaymentTimes.text = ""
        }
        
        if settlementData.adjust_set_date != 0 {
            btnCalendarSCWD.setTitle(Utils.convertUnixTimestamp(time: settlementData.adjust_set_date), for: .normal)
        } else {
            btnCalendarSCWD.setTitle("カレンダー選択", for: .normal)
        }
        
        if settlementData.adjust_set_price != 0 {
            tfSCWithDrawn1.text = String(settlementData.adjust_set_price).addFormatAmount()
        } else {
            tfSCWithDrawn1.text = ""
        }
        
        if settlementData.monthly_set_price != 0 {
            tfSCWithDrawn2.text = String(settlementData.monthly_set_price).addFormatAmount()
        } else {
            tfSCWithDrawn2.text = ""
        }
        
        if settlementData.bonus_pay1 != 0 {
            tfSCWithDrawn3.text = String(settlementData.bonus_pay1).addFormatAmount()
        } else {
            tfSCWithDrawn3.text = ""
        }
        
        onResetButtonStatus()
        bonusPay = false
        switch settlementData.pay_type {
        case "初回":
            btnSCFirst.setImage(UIImage(named: "icon_radio_check_button.png"), for: .normal)
        case "最終回":
            btnSCLast.setImage(UIImage(named: "icon_radio_check_button.png"), for: .normal)
        case "ボーナス総額払い":
            btnSCBonus.setImage(UIImage(named: "icon_check_box.png"), for: .normal)
            bonusPay = true
        default:
            btnSCFirst.setImage(UIImage(named: "icon_radio_check_button.png"), for: .normal)
            settlementData.pay_type = "初回"
        }
    }
    
    private func onResetButtonStatus() {
        btnSCFirst.setImage(UIImage(named: "icon_radio_uncheck_button.png"), for: .normal)
        btnSCLast.setImage(UIImage(named: "icon_radio_uncheck_button.png"), for: .normal)
        btnSCBonus.setImage(UIImage(named: "icon_uncheck_box"), for: .normal)
    }
    
    @IBAction func onInputSCPaymentTimes(_ sender: UITextField) {
        self.settlementData.settlement_count = Int(sender.text!) ?? 0
    }
    
    @IBAction func onInputSCWD(_ sender: UITextField) {
        let int = sender.text?.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "")
        if int != "" {
            sender.text = String(int ?? "0")
        } else {
            sender.text = "0"
        }
        
        switch sender.tag {
        case 1:
            self.settlementData.adjust_set_price = Int(sender.text!) ?? 0
        case 2:
            self.settlementData.monthly_set_price = Int(sender.text!) ?? 0
        case 3:
            self.settlementData.bonus_pay1 = Int(sender.text!) ?? 0
        default:
            break
        }
        sender.text = sender.text?.addFormatAmount()
    }
    
    @IBAction func onShoppingCardCompanySelect(_ sender: UIButton) {
        let shoppingcards = realm.objects(PaymentData.self).filter("category_id == 2").sorted(byKeyPath: "display_num")
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        for i in 0 ..< shoppingcards.count {
            let action = UIAlertAction(title: shoppingcards[i].credit_company, style: .default) { (UIAlertAction) in
                self.btnSCName.setTitle(shoppingcards[i].credit_company, for: .normal)
                self.settlementData.institution_name = shoppingcards[i].credit_company
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.btnSCName
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnSCName.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func onSelectShoppingCardPayType(_ sender: UIButton) {
        bonusPay = false
        onResetButtonStatus()
        switch sender.tag {
        case 1:
            self.settlementData.pay_type = "初回"
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
        case 2:
            self.settlementData.pay_type = "最終回"
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func onSelectShoppingCardBonus(_ sender: UIButton) {
        onResetButtonStatus()
        if bonusPay == true {
            sender.setImage(UIImage(named: "icon_uncheck_box"), for: .normal)
            btnSCFirst.setImage(UIImage(named: "icon_radio_check_button"), for: .normal)
            settlementData.pay_type = "初回"
            bonusPay = false
        } else {
            sender.setImage(UIImage(named: "icon_check_box"), for: .normal)
            settlementData.pay_type = "ボーナス総額払い"
            bonusPay = true
        }
    }
    
    @IBAction func onSelectCalendarSCWD(_ sender: UIButton) {
        guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 450, height: 300)
        newPopup.type = 2
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
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
}

extension ShoppingCreditPaymentVC: DatePickerPopupVCDelegate {
    
    func onRegisterDateOnly(date: Date) {
        let format = DateFormatter()
        format.dateFormat = "yyyy年MM月dd日"
        let formattedDate = format.string(from: date)
        btnCalendarSCWD.setTitle(formattedDate, for: .normal)
        settlementData.adjust_set_date = Int(date.timeIntervalSince1970)
    }
}
