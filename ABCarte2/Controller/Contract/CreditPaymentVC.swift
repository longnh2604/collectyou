//
//  CreditPaymentVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/17.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class CreditPaymentVC: BasePaymentVC {

    //IBOutlet
    @IBOutlet weak var radioCC1time: UIButton!
    @IBOutlet weak var radioCCtimes: UIButton!
    @IBOutlet weak var radioCCribo: UIButton!
    @IBOutlet weak var radioCCBonus1: UIButton!
    @IBOutlet weak var radioCCBonus2: UIButton!
    @IBOutlet weak var btnCCName: UIButton!
    @IBOutlet weak var tfCCtimes: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupLayout() {
        if settlementData.institution_name != "" {
            btnCCName.setTitle(settlementData.institution_name, for: .normal)
        } else {
            btnCCName.setTitle("リスト選択", for: .normal)
        }
        
        if settlementData.settlement_count != 0 {
            tfCCtimes.text = String(settlementData.settlement_count)
        } else {
            tfCCtimes.text = ""
        }
        
        switch settlementData.pay_type {
        case "1回払い":
            addCheckButtonStatus(sender: radioCC1time)
        case "分割払い":
            addCheckButtonStatus(sender: radioCCtimes)
        case "リボ払い":
            addCheckButtonStatus(sender: radioCCribo)
        case "ボーナス1回":
            addCheckButtonStatus(sender: radioCCBonus1)
        case "ボーナス2回":
            addCheckButtonStatus(sender: radioCCBonus2)
        default:
            addCheckButtonStatus(sender: radioCC1time)
        }
    }
    
    @IBAction func onCreditCardCompanySelect(_ sender: UIButton) {
        let emoneys = realm.objects(PaymentData.self).filter("category_id == 1").sorted(byKeyPath: "display_num")
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        for i in 0 ..< emoneys.count {
            let action = UIAlertAction(title: emoneys[i].credit_company, style: .default) { (UIAlertAction) in
                self.btnCCName.setTitle(emoneys[i].credit_company, for: .normal)
                self.settlementData.institution_name = emoneys[i].credit_company
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.btnCCName
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnCCName.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSelectCreditPayType(_ sender: UIButton) {
        addCheckButtonStatus(sender: sender)
    }
    
    private func addCheckButtonStatus(sender:UIButton) {
        radioCC1time.setImage(UIImage(named: "icon_radio_uncheck_button"), for: .normal)
        radioCCtimes.setImage(UIImage(named: "icon_radio_uncheck_button"), for: .normal)
        radioCCribo.setImage(UIImage(named: "icon_radio_uncheck_button"), for: .normal)
        radioCCBonus1.setImage(UIImage(named: "icon_radio_uncheck_button"), for: .normal)
        radioCCBonus2.setImage(UIImage(named: "icon_radio_uncheck_button"), for: .normal)
        
        sender.setImage(UIImage(named: "icon_radio_check_button"), for: .normal)
        self.settlementData.pay_type = getSelectedButton(sender: sender)
    }
    
    private func getSelectedButton(sender:UIButton)->String {
        switch sender.tag {
        case 1:
            return "1回払い"
        case 2:
            return "分割払い"
        case 3:
            return "リボ払い"
        case 4:
            return "ボーナス1回"
        case 5:
            return "ボーナス2回"
        default:
            return "1回払い"
        }
    }
    
    @IBAction func onInputCreditPaymentTime(_ sender: UITextField) {
        self.settlementData.settlement_count = Int(sender.text!) ?? 0
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
