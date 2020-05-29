//
//  PaymentMethodVC.swift
//  ABCarte2
//
//  Created by Long on 2019/10/15.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class PaymentMethodVC: UIViewController, UITextFieldDelegate {

    //IBOutlet
    @IBOutlet weak var tblPayment: UITableView!
    @IBOutlet weak var tblPaymentHeightConst: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewShopping: RoundUIView!
    @IBOutlet weak var viewEMoney: RoundUIView!
    @IBOutlet weak var viewCredit: RoundUIView!
    @IBOutlet weak var btnCreditCardCom: RoundButton!
    @IBOutlet weak var btnShoppingCardCom: RoundButton!
    @IBOutlet weak var btnEMoney: RoundButton!
    @IBOutlet weak var heightShoppingCardConstant: NSLayoutConstraint!
    @IBOutlet weak var heightCreditCardConstant: NSLayoutConstraint!
    @IBOutlet weak var heightEMoneyConstant: NSLayoutConstraint!
    @IBOutlet weak var tfRemainCost: UITextField!
    @IBOutlet weak var tfTotalPrice: UITextField!
    @IBOutlet weak var tfShoppingCardWithdrawn1: UITextField!
    @IBOutlet weak var tfShoppingCardWithdrawn2: UITextField!
    @IBOutlet weak var tfShoppingCardWithdrawn3: UITextField!
    @IBOutlet weak var btnCC1time: UIButton!
    @IBOutlet weak var btnCCtimes: UIButton!
    @IBOutlet weak var btnCCRipo: UIButton!
    @IBOutlet weak var btnCCBonus1: UIButton!
    @IBOutlet weak var btnCCBonus2: UIButton!
    @IBOutlet weak var btnSC1st: UIButton!
    @IBOutlet weak var btnSClst: UIButton!
    @IBOutlet weak var btnSCtimes: UIButton!
    @IBOutlet weak var btnSCBonus: UIButton!
    @IBOutlet weak var btnCalendarFirstWDrawn: UIButton!
    @IBOutlet weak var tfCreditCount: UITextField!
    @IBOutlet weak var tfShoppingCount: UITextField!
    
    //Variable
    var paymentArr = ["1","2","3","4"]
    var totalPrice : String?
    var brochure = BrochureData()
    var courseOrder : [CourseOrderData] = []
    var productOrder : [ProductsOrderData] = []
    var settlementOrder: [SettlementData] = []
    var ccCard = ["0"]
    var creditSelected = 1
    var shoppingSelected = 1
    var checkBoxShopping = 0
    let maxLength = 15
    var account = AccountData()
    var payments: Results<PaymentData>!
    lazy var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupLayout()
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetAllPaymentMethod(accountID: account.id) { (success) in
            if success {
                self.payments = self.realm.objects(PaymentData.self)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func setupLayout() {
        let nib1 = UINib(nibName: "PaymentCell", bundle: nil)
        tblPayment.register(nib1, forCellReuseIdentifier: "PaymentCell")
        
        tblPayment.delegate = self
        tblPayment.dataSource = self
        tblPayment.register(UINib.init(nibName: PaymentFooterView.PaymentFooterViewIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: PaymentFooterView.PaymentFooterViewIdentifier)
        tblPayment.isScrollEnabled = false
        tblPayment.layer.borderWidth = 1
        tblPayment.layer.borderColor = UIColor.black.cgColor
        
        if let total = totalPrice {
            tfTotalPrice.text = total
            tfRemainCost.text = total
        }
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "その他情報へ", style: .plain, target: self, action: #selector(onConfirm))
        
        btnCC1time.setImage(UIImage(named: "icon_radio_check_button.png"), for: .normal)
        btnSC1st.setImage(UIImage(named: "icon_radio_check_button.png"), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settlementOrder.removeAll()
    }
    
    @objc func onConfirm() {
        //check total price
        let footer = tblPayment.footerView(forSection: 0) as! PaymentFooterView
        let totalF = footer.tfTotal.text!.removeFormatAmount()
        if totalF < (totalPrice?.removeFormatAmount())! {
            Utils.showAlert(message: "お支払予定の総合計金額が不足しています", view: self)
            return
        }
        
        onFetchingData()
        if settlementOrder.count == 0 {
            Utils.showAlert(message: "お支払い時期とお支払い方法を選択して下さい", view: self)
            return
        }
        APIRequest.onAddSettlement(brochureID: brochure.id, settlement: settlementOrder, index: 0, total: settlementOrder.count) { (success) in
            if success {
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OtherInfoVC") as? OtherInfoVC {
                    viewController.brochure = self.brochure
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            } else {
                Utils.showAlert(message: "add settlement failed", view: self)
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func onFetchingData() {
        for i in 0 ..< tblPayment.numberOfRows(inSection: 0) {
            if let cell = tblPayment.cellForRow(at: IndexPath(row: i, section: 0)) as? PaymentCell {
                let order = SettlementData()
                order.brochure_id = brochure.id
                order.settlement_price = (cell.tfMoneyPay.text?.removeFormatAmount())!
                if order.settlement_price > 0 {
                    if cell.btnCalendar.titleLabel?.text == "カレンダー選択" || cell.btnPayMethod.titleLabel?.text == "リスト選択" {
                        Utils.showAlert(message: "お支払い時期とお支払い方法を選択して下さい", view: self)
                        settlementOrder.removeAll()
                        return
                    }
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy年MM月dd日"
                if cell.btnCalendar.titleLabel?.text == "カレンダー選択" {
                    continue
                }
                order.settlement_date = Int(formatter.date(from: cell.btnCalendar.titleLabel!.text!)!.timeIntervalSince1970)
                
                if let text = cell.btnPayMethod.titleLabel?.text! {
                    order.settlement_type = text
                    if text == "クレジットカード" {
                        if let cardName = btnCreditCardCom.titleLabel?.text {
                            if cardName == "リスト選択" {
                                Utils.showAlert(message: "クレジットカードリストを選択して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                            order.institution_name = cardName
                        }
                        if creditSelected == 1 {
                            order.pay_type = "1回払い"
                        } else if creditSelected == 2 {
                            order.pay_type = "分割払い"
                            if let count = tfCreditCount.text {
                                if count == "0" {
                                    Utils.showAlert(message: "クレジットカード分割払いの回を選択して下さい", view: self)
                                    settlementOrder.removeAll()
                                    return
                                }
                                order.settlement_count = Int(count) ?? 0
                            }
                        } else if creditSelected == 3 {
                            order.pay_type = "リボ払い"
                        } else if creditSelected == 4 {
                            order.pay_type = "ボーナス1回"
                        } else if creditSelected == 5 {
                            order.pay_type = "ボーナス2回"
                        }
                    } else if text == "ショッピングクレジット" {
                        if let cardName = btnShoppingCardCom.titleLabel?.text {
                            if cardName == "リスト選択" {
                                Utils.showAlert(message: "ショッピングクレジットリストを選択して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                            order.institution_name = cardName
                        }
                        if let date = btnCalendarFirstWDrawn?.titleLabel?.text {
                            if date == "カレンダー選択" {
                                Utils.showAlert(message: "ショッピングクレジットし初回引き落ちのカレンダーを選択して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                            order.adjust_set_date = Int(formatter.date(from: date)!.timeIntervalSince1970)
                        }
                        if let count = tfShoppingCount.text {
                            if count == "0" {
                                Utils.showAlert(message: "ショッピングクレジットの支払い回数を記入して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                            order.settlement_count = Int(count) ?? 0
                        } else {
                            Utils.showAlert(message: "ショッピングクレジットの支払い回数を記入して下さい", view: self)
                            settlementOrder.removeAll()
                            return
                        }
                        if let text = tfShoppingCardWithdrawn2.text {
                            order.monthly_set_price = text.removeFormatAmount()
                        } else {
                            Utils.showAlert(message: "ショッピングクレジットの通常各回を記入して下さい", view: self)
                            settlementOrder.removeAll()
                            return
                        }
                        if checkBoxShopping == 1 {
                            order.pay_type = "ボーナス総額払い"
                            if let text = tfShoppingCardWithdrawn3.text {
                                order.bonus_pay1 = text.removeFormatAmount()
                                if order.bonus_pay1 == 0 {
                                    Utils.showAlert(message: "ショッピングクレジットのボーナスを記入して下さい", view: self)
                                    settlementOrder.removeAll()
                                    return
                                }
                            }
                        }
                        if shoppingSelected == 1 && checkBoxShopping == 0 {
                            order.pay_type = "初回"
                            if let text = tfShoppingCardWithdrawn1.text {
                                order.adjust_set_price = text.removeFormatAmount()
                                if order.adjust_set_price == 0 {
                                    Utils.showAlert(message: "ショッピングクレジットの初回を記入して下さい", view: self)
                                    settlementOrder.removeAll()
                                    return
                                }
                            } else {
                                Utils.showAlert(message: "ショッピングクレジットの初回を記入して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                        }
                        if shoppingSelected == 2 && checkBoxShopping == 0 {
                            order.pay_type = "最終回"
                            if let text = tfShoppingCardWithdrawn1.text {
                                order.adjust_set_price = text.removeFormatAmount()
                                if order.adjust_set_price == 0 {
                                    Utils.showAlert(message: "ショッピングクレジットの最終回を選択して下さい", view: self)
                                    settlementOrder.removeAll()
                                    return
                                }
                            } else {
                                Utils.showAlert(message: "ショッピングクレジットの最終回を選択して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                        }
                    } else if text == "電子マネー" {
                        if let cardName = btnEMoney.titleLabel?.text {
                            if cardName == "リスト選択" {
                                Utils.showAlert(message: "電子マネーを選択して下さい", view: self)
                                settlementOrder.removeAll()
                                return
                            }
                            order.institution_name = cardName
                        }
                    } else if text == "リスト選択" {
                        continue
                    }
                }
                order.index = i + 1
                settlementOrder.append(order)
            }
        }
    }
    
    fileprivate func checkScrollView() {
        let space = self.view.frame.height - ( viewEMoney.frame.origin.y + 150 )
        if space < 50 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height - (space))
        }
    }
    
    fileprivate func updateOptionView(type:Int) {
        switch type {
        case 0:
            heightCreditCardConstant.constant = 0
            heightShoppingCardConstant.constant = 0
            heightEMoneyConstant.constant = 0
            viewCredit.isHidden = true
            viewShopping.isHidden = true
            viewEMoney.isHidden = true
        case 1:
            heightCreditCardConstant.constant = 200
            heightShoppingCardConstant.constant = 0
            heightEMoneyConstant.constant = 0
            viewCredit.isHidden = false
            viewShopping.isHidden = true
            viewEMoney.isHidden = true
        case 2:
            heightCreditCardConstant.constant = 0
            heightShoppingCardConstant.constant = 220
            heightEMoneyConstant.constant = 0
            viewCredit.isHidden = true
            viewShopping.isHidden = false
            viewEMoney.isHidden = true
        case 3:
            heightCreditCardConstant.constant = 0
            heightShoppingCardConstant.constant = 0
            heightEMoneyConstant.constant = 80
            viewCredit.isHidden = true
            viewShopping.isHidden = true
            viewEMoney.isHidden = false
        default:
            break
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

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onCalendarFirstWDrawnSelect(_ sender: UIButton) {
        guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 450, height: 300)
        newPopup.type = 2
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onAddPayment(_ sender: UIButton) {
        //check table rows
        if tblPayment.numberOfRows(inSection: 0) > 3 {
            Utils.showAlert(message: "登録出来るコースは4つまでです", view: self)
            return
        }
        //add to array
        paymentArr.append("new")
        tblPaymentHeightConst.constant = tblPaymentHeightConst.constant + 50
        //update tableview
        tblPayment.beginUpdates()
        tblPayment.insertRows(at: [IndexPath(row: paymentArr.count-1, section: 0)], with: .automatic)
        tblPayment.endUpdates()
        
        checkScrollView()
    }
    
    @IBAction func onSelectCreditCardPayType(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            creditSelected = 1
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnCCtimes.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCRipo.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCRipo.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus1.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus2.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        case 2:
            creditSelected = 2
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnCC1time.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCRipo.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus1.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus2.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        case 3:
            creditSelected = 3
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnCC1time.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCtimes.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus1.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus2.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        case 4:
            creditSelected = 4
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnCC1time.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCtimes.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCRipo.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus2.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        case 5:
            creditSelected = 5
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnCC1time.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCtimes.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCRipo.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
            btnCCBonus1.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func onSelectShoppingCardPayType(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            shoppingSelected = 1
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnSClst.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        case 2:
            shoppingSelected = 2
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnSC1st.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func onCheckShoppingCardBonus(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            checkBoxShopping = 0
            sender.setImage(UIImage(named: "icon_uncheck_box"), for: .normal)
        } else {
            checkBoxShopping = 1
            sender.setImage(UIImage(named: "icon_check_box.png"), for: .normal)
        }
    }
    
    @IBAction func onCreditCardCompanySelect(_ sender: UIButton) {
        let credits = realm.objects(PaymentData.self).filter("category_id == 1").sorted(byKeyPath: "display_num")
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        for i in 0 ..< credits.count {
            let action = UIAlertAction(title: credits[i].credit_company, style: .default) { (UIAlertAction) in
                self.btnCreditCardCom.setTitle(credits[i].credit_company, for: .normal)
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.btnCreditCardCom
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnCreditCardCom.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onShoppingCardCompanySelect(_ sender: UIButton) {
        let shoppingcredits = realm.objects(PaymentData.self).filter("category_id == 2").sorted(byKeyPath: "display_num")
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        for i in 0 ..< shoppingcredits.count {
            let action = UIAlertAction(title: shoppingcredits[i].credit_company, style: .default) { (UIAlertAction) in
                self.btnShoppingCardCom.setTitle(shoppingcredits[i].credit_company, for: .normal)
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.btnShoppingCardCom
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnShoppingCardCom.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onEMoneySelect(_ sender: UIButton) {
        let emoneys = realm.objects(PaymentData.self).filter("category_id == 3").sorted(byKeyPath: "display_num")
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        for i in 0 ..< emoneys.count {
            let action = UIAlertAction(title: emoneys[i].credit_company, style: .default) { (UIAlertAction) in
                self.btnEMoney.setTitle(emoneys[i].credit_company, for: .normal)
            }
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = self.btnEMoney
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnEMoney.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onChangeText(_ sender: UITextField) {
        if var text = sender.text {
            if text.contains("¥") {
                var int = text.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "")
                if int == "" {
                    int = "0"
                }
                sender.text = String(int).addFormatAmount()
            } else {
                if text == "" {
                    text = "0"
                }
                sender.text = text.addFormatAmount()
            }
        }
    }
}

//*****************************************************************
// MARK: - UITableView Delegate
//*****************************************************************

extension PaymentMethodVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentCell
        if cell == nil
        {
            //initialize the cell here
            cell = PaymentCell.init(style: .default, reuseIdentifier: "PaymentCell")
        }
        cell?.configure(index: indexPath.row)
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: PaymentFooterView.PaymentFooterViewIdentifier) as! PaymentFooterView
        return footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PaymentCell else { return }
        if cell.btnPayMethod.titleLabel!.text == "クレジットカード" {
//            self.updateOptionView(type:1)
        } else if cell.btnPayMethod.titleLabel!.text == "ショッピングクレジット" {
//            self.updateOptionView(type:2)
        } else if cell.btnPayMethod.titleLabel!.text == "電子マネー" {
//            self.updateOptionView(type:3)
        } else {
//            self.updateOptionView(type:0)
        }
    }
}

//*****************************************************************
// MARK: - PaymentCell Delegate
//*****************************************************************

extension PaymentMethodVC: PaymentCellDelegate, DatePickerPopupVCDelegate {
    
    func onEditingValue() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func onAddMoney(index: Int) {
        var total = 0
        //count all tablecell
        for i in 0 ..< tblPayment.numberOfRows(inSection: 0) {
            let cell = tblPayment.cellForRow(at: IndexPath(row: i, section: 0)) as? PaymentCell
            if let text = cell?.tfMoneyPay.text {
                let int = text.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "")
                if int != "" {
                    cell?.tfMoneyPay.text = int.addFormatAmount()
                    total = total + Int(int)!
                }
            }
        }
        
        let remain = (tfTotalPrice.text?.removeFormatAmount())! - total
        if remain < 0 {
            tfRemainCost.textColor = UIColor.red
        } else {
            tfRemainCost.textColor = UIColor.black
        }
        tfRemainCost.text = String((tfTotalPrice.text?.removeFormatAmount())! - total).addFormatAmount()
        
        let footer = tblPayment.footerView(forSection: 0) as! PaymentFooterView
        footer.tfTotal.text = String(total).addFormatAmount()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func onCalendarSelect(index: Int) {
        guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 450, height: 300)
        newPopup.cellIndex = index
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func onPaymentMethodSelect(index: Int,button: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let cash = UIAlertAction(title: "現金持参", style: .default) { UIAlertAction in
            if let text = button.titleLabel?.text {
                if text == "クレジットカード" {
                    if let index = self.ccCard.firstIndex(of: "1") {
                        self.ccCard.remove(at: index)
                    }
                } else if text == "ショッピングクレジット" {
                    if let index = self.ccCard.firstIndex(of: "2") {
                        self.ccCard.remove(at: index)
                    }
                } else if text == "電子マネー" {
                    if let index = self.ccCard.firstIndex(of: "3") {
                        self.ccCard.remove(at: index)
                    }
                } else {
                    //do nothing
                }
            }
            button.setTitle("現金持参", for: .normal)
        }
        let account = UIAlertAction(title: "現金振込", style: .default) { UIAlertAction in
            if let text = button.titleLabel?.text {
                if text == "クレジットカード" {
                    if let index = self.ccCard.firstIndex(of: "1") {
                        self.ccCard.remove(at: index)
                    }
                } else if text == "ショッピングクレジット" {
                    if let index = self.ccCard.firstIndex(of: "2") {
                        self.ccCard.remove(at: index)
                    }
                } else if text == "電子マネー" {
                    if let index = self.ccCard.firstIndex(of: "3") {
                        self.ccCard.remove(at: index)
                    }
                } else {
                    //do nothing
                }
            }
            button.setTitle("現金振込", for: .normal)
        }
        let debit = UIAlertAction(title: "デビットカード", style: .default) { UIAlertAction in
            if let text = button.titleLabel?.text {
                if text == "クレジットカード" {
                    if let index = self.ccCard.firstIndex(of: "1") {
                        self.ccCard.remove(at: index)
                    }
                } else if text == "ショッピングクレジット" {
                    if let index = self.ccCard.firstIndex(of: "2") {
                        self.ccCard.remove(at: index)
                    }
                } else if text == "電子マネー" {
                    if let index = self.ccCard.firstIndex(of: "3") {
                        self.ccCard.remove(at: index)
                    }
                } else {
                    //do nothing
                }
            }
            button.setTitle("デビットカード", for: .normal)
        }
        let credit = UIAlertAction(title: "クレジットカード", style: .default) { UIAlertAction in
            self.rewriteCardData(text: button.titleLabel!.text!)
            if self.ccCard.contains("1") {
                Utils.showAlert(message: "他のお支払い方法を選択して下さい", view: self)
                return
            } else {
                button.setTitle("クレジットカード", for: .normal)
                self.ccCard.append("1")
            }
        }
        let shopping = UIAlertAction(title: "ショッピングクレジット", style: .default) { UIAlertAction in
            self.rewriteCardData(text: button.titleLabel!.text!)
            if self.ccCard.contains("2") {
                Utils.showAlert(message: "他のお支払い方法を選択して下さい", view: self)
                return
            } else {
                button.setTitle("ショッピングクレジット", for: .normal)
                self.ccCard.append("2")
            }
            button.setTitle("ショッピングクレジット", for: .normal)
        }
        let emoney = UIAlertAction(title: "電子マネー", style: .default) { UIAlertAction in
            self.rewriteCardData(text: button.titleLabel!.text!)
            if self.ccCard.contains("3") {
                Utils.showAlert(message: "他のお支払い方法を選択して下さい", view: self)
                return
            } else {
                button.setTitle("電子マネー", for: .normal)
                self.ccCard.append("3")
            }
            button.setTitle("電子マネー", for: .normal)
        }
        alert.addAction(cancel)
        alert.addAction(cash)
        alert.addAction(account)
        alert.addAction(debit)
        alert.addAction(credit)
        alert.addAction(shopping)
        alert.addAction(emoney)
        alert.popoverPresentationController?.sourceView = button
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        alert.popoverPresentationController?.sourceRect = button.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func rewriteCardData(text:String) {
        switch text {
        case "クレジットカード":
            ccCard.remove(object: "1")
        case "ショッピングクレジット":
            ccCard.remove(object: "2")
        case "電子マネー":
            ccCard.remove(object: "3")
        default:
            break
        }
    }
    
    func onRegisterDate(date: Date,index:Int) {
        if let cell = tblPayment.cellForRow(at: IndexPath(row: index, section: 0)) as? PaymentCell {
            let format = DateFormatter()
            format.dateFormat = "yyyy年MM月dd日"
            let formattedDate = format.string(from: date)
            cell.btnCalendar.setTitle(formattedDate, for: .normal)
            tblPayment.reloadInputViews()
        }
    }
    
    func onRegisterDateOnly(date: Date) {
        let format = DateFormatter()
        format.dateFormat = "yyyy年MM月dd日"
        let formattedDate = format.string(from: date)
        btnCalendarFirstWDrawn.setTitle(formattedDate, for: .normal)
    }
}
