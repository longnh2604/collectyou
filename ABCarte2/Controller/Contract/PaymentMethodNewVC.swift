//
//  PaymentMethodNewVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/16.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class PaymentMethodNewVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tblPayment: UITableView!
    @IBOutlet weak var tfRemainCost: UITextField!
    @IBOutlet weak var tfTotalPrice: UITextField!
    @IBOutlet weak var scrollSegment: ScrollableSegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    //Variable
    lazy var realm = try! Realm()
    var totalPrice : String?
    var brochure = BrochureData()
    var settlementOrder: [SettlementData] = []
    var account = AccountData()
    var payments: Results<PaymentData>!
   
    private lazy var creditViewController: CreditPaymentVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Contract", bundle: Bundle.main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "CreditPaymentVC") as! CreditPaymentVC
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var shoppingViewController: ShoppingCreditPaymentVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Contract", bundle: Bundle.main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ShoppingCreditPaymentVC") as! ShoppingCreditPaymentVC
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var emoneyViewController: EMoneyPaymentVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Contract", bundle: Bundle.main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "EMoneyPaymentVC") as! EMoneyPaymentVC
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        try! realm.write {
            realm.delete(realm.objects(SettlementData.self))
        }
        
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
        
        //configure segment
        scrollSegment.segmentStyle = .imageOnLeft
        scrollSegment.underlineHeight = 5.0
        scrollSegment.underlineSelected = true
        scrollSegment.fixedSegmentWidth = true
        scrollSegment.layer.borderColor = UIColor.black.cgColor
        scrollSegment.layer.borderWidth = 1.0
        
        let largerTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.black]
        scrollSegment.setTitleTextAttributes(largerTextAttributes, for: .normal)
        
        scrollSegment.addTarget(self, action: #selector(PaymentMethodNewVC.segmentSelected(sender:)), for: .valueChanged)
    }
    
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        removeCurrentPaymentView()
        addCurrentPaymentView(title: sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
    private func addCurrentPaymentView(title:String) {
        if title == "クレジットカード" {
            add(asChildViewController: creditViewController)
        } else if title == "ショッピングクレジット" {
            add(asChildViewController: shoppingViewController)
        } else if title == "電子マネー" {
            add(asChildViewController: emoneyViewController)
        }
    }
    
    private func removeCurrentPaymentView() {
        children.forEach { (vc) in
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        containerView.subviews.forEach({ $0.removeFromSuperview() })
    }
   
    private func add(asChildViewController viewController: BasePaymentVC) {
        //set index
        viewController.index = scrollSegment.selectedSegmentIndex
        viewController.settlementData = settlementOrder[scrollSegment.selectedSegmentIndex]
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        containerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func onConfirm() {
        //check settlement added or not
        if settlementOrder.count == 0 {
            Utils.showAlert(message: "お支払い時期とお支払い方法を選択して下さい", view: self)
            return
        }
        
        //check total payment is satisfy or not
        let footer = tblPayment.footerView(forSection: 0) as! PaymentFooterView
        let totalF = footer.tfTotal.text!.removeFormatAmount()
        if totalF < (totalPrice?.removeFormatAmount())! {
            Utils.showAlert(message: "お支払予定の総合計金額が不足しています", view: self)
            return
        }
        
        if checkPaymentDataAdded() {
            APIRequest.onAddSettlementNew(brochureID: brochure.id, settlement: settlementOrder) { (success) in
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
    }
    
    private func checkPaymentDataAdded()->Bool {
        for i in 0 ..< settlementOrder.count {
            if settlementOrder[i].settlement_type == "" {
                Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                return false }
            if settlementOrder[i].settlement_price == 0 {
                Utils.showAlert(message: "金額[\(i + 1)]の情報が不足しています", view: self)
                return false }
            if settlementOrder[i].settlement_date == 0 {
                Utils.showAlert(message: "お支払い時期[\(i + 1)]の情報が不足しています", view: self)
                return false }
    
            switch settlementOrder[i].settlement_type {
            case "クレジットカード":
                if settlementOrder[i].institution_name == "" {
                    Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                    return false
                }
                if settlementOrder[i].pay_type == "分割払い" {
                    if settlementOrder[i].settlement_count == 0 {
                        Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                        return false
                    }
                }
            case "ショッピングクレジット":
                if settlementOrder[i].institution_name == "" {
                    Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                    return false
                }
                if settlementOrder[i].adjust_set_date == 0 {
                    Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                    return false
                }
                if settlementOrder[i].settlement_count == 0 {
                    Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                    return false
                }
                if settlementOrder[i].monthly_set_price == 0 {
                    Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                    return false
                }
                if settlementOrder[i].pay_type == "ボーナス総額払い" {
                    if settlementOrder[i].bonus_pay1 == 0 {
                        Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                        return false
                    }
                } else if settlementOrder[i].pay_type == "初回" {
                    if settlementOrder[i].adjust_set_price == 0 {
                        Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                        return false
                    }
                } else if settlementOrder[i].pay_type == "最終回" {
                    if settlementOrder[i].adjust_set_price == 0 {
                        Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                        return false
                    }
                }
            case "電子マネー":
                if settlementOrder[i].institution_name == "" {
                    Utils.showAlert(message: "お支払い方法[\(i + 1)]の詳細が不足しています", view: self)
                    return false
                }
            default:
                break
            }
        }
        return true
    }
    
    @IBAction func onDeleteRow(_ sender: UIButton) {
        if let index = tblPayment.indexPathForSelectedRow {
            //check if it's the first cell or not
            if index.row == 0 {
                Utils.showAlert(message: "削除出来ません", view: self)
                return
            }
  
            //handle segment
            settlementOrder.remove(at: index.row)
            
            //remove segments after 1
//            let last = scrollSegment.numberOfSegments
//            let sequence = stride(from: 1, to: last, by: 1)
//            for element in sequence {
//                scrollSegment.removeSegment(at: element)
//            }
            
            for _ in 1 ..< scrollSegment.numberOfSegments {
                scrollSegment.removeSegment(at: 1)
            }
            
            for l in 1 ..< settlementOrder.count {
                scrollSegment.insertSegment(withTitle: settlementOrder[l].settlement_type, image: #imageLiteral(resourceName: "segment-\(l + 1)"), at: l)
            }

            //handle data binding
            for i in 0 ..< settlementOrder.count {
                //check index and reorder if need
                if settlementOrder[i].index != i, i != 0 {
                    settlementOrder[i].index = i
                }
                
                let cell = tblPayment.cellForRow(at: IndexPath(row: i, section: 0)) as? PaymentCell
                cell?.btnPayMethod.setTitle(settlementOrder[i].settlement_type, for: .normal)
                cell?.tfMoneyPay.text = String(settlementOrder[i].settlement_price).addFormatAmount()
                cell?.btnCalendar.setTitle(Utils.convertUnixTimestamp(time: settlementOrder[i].settlement_date), for: .normal)
            }
            
            //clear remain cell
            if settlementOrder.count < 4 {
                for j in settlementOrder.count ..< 4 {
                    let cell = tblPayment.cellForRow(at: IndexPath(row: j, section: 0)) as? PaymentCell
                    cell?.btnPayMethod.setTitle("リスト選択", for: .normal)
                    cell?.btnCalendar.setTitle("カレンダー選択", for: .normal)
                    cell?.tfMoneyPay.text = ""
                }
            }
        }
        
        //recalculate
        var total = 0
        for i in 0 ..< tblPayment.numberOfRows(inSection: 0) {
            let cell = tblPayment.cellForRow(at: IndexPath(row: i, section: 0)) as? PaymentCell
            if cell?.btnPayMethod.titleLabel?.text != "リスト選択",let text = cell?.tfMoneyPay.text {
                total += text.removeFormatAmount()
            }
        }
        let remain = (tfTotalPrice.text?.removeFormatAmount())! - total
        if remain < 0 {
            tfRemainCost.textColor = UIColor.red
        } else {
            tfRemainCost.textColor = UIColor.black
        }
        tfRemainCost.text = String(remain).addFormatAmount()
        
        let footer = tblPayment.footerView(forSection: 0) as! PaymentFooterView
        footer.tfTotal.text = String(total).addFormatAmount()
    }
}

//*****************************************************************
// MARK: - UITableView Delegate
//*****************************************************************

extension PaymentMethodNewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentCell
        if cell == nil
        {
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
}

//*****************************************************************
// MARK: - PaymentCell Delegate
//*****************************************************************

extension PaymentMethodNewVC: PaymentCellDelegate, DatePickerPopupVCDelegate {
    
    func onEditingValue() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func onAddMoney(index: Int) {
        if checkValidInput(index: index) {
            //count all tablecell
            let cell = tblPayment.cellForRow(at: IndexPath(row: index, section: 0)) as? PaymentCell
            if let text = cell?.tfMoneyPay.text {
                let int = text.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "")
                if int != "" {
                    cell?.tfMoneyPay.text = int.addFormatAmount()
                    settlementOrder[index].settlement_price = Int(int) ?? 0
                }
            }
            
            //recalculate
            var totalS = 0
            for i in 0 ..< tblPayment.numberOfRows(inSection: 0) {
                let cell = tblPayment.cellForRow(at: IndexPath(row: i, section: 0)) as? PaymentCell
                if cell?.btnPayMethod.titleLabel?.text != "リスト選択",let text = cell?.tfMoneyPay.text {
                    totalS += text.removeFormatAmount()
                }
            }
            
            let remain = (tfTotalPrice.text?.removeFormatAmount())! - totalS
            if remain < 0 {
                tfRemainCost.textColor = UIColor.red
            } else {
                tfRemainCost.textColor = UIColor.black
            }
            tfRemainCost.text = String(remain).addFormatAmount()
            
            let footer = tblPayment.footerView(forSection: 0) as! PaymentFooterView
            footer.tfTotal.text = String(totalS).addFormatAmount()
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            let cellIndex = tblPayment.cellForRow(at: IndexPath(row: index, section: 0)) as? PaymentCell
            cellIndex?.tfMoneyPay.text = ""
        }
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
        //check existing data first
        for i in 0 ..< tblPayment.numberOfRows(inSection: 0) {
            let cell = tblPayment.cellForRow(at: IndexPath(row: i, section: 0)) as? PaymentCell
            if cell?.btnPayMethod.title(for: .normal) == "リスト選択" {
                if i == index - 1 {
                    Utils.showAlert(message: "上の線を選択してください。", view: self)
                    return
                }
            }
        }
        
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let cash = UIAlertAction(title: "現金持参", style: .default) { UIAlertAction in
            self.onAddSegment(string: "現金持参", button: button, index: index)
        }
        let account = UIAlertAction(title: "現金振込", style: .default) { UIAlertAction in
            self.onAddSegment(string: "現金振込", button: button, index: index)
        }
        let debit = UIAlertAction(title: "デビットカード", style: .default) { UIAlertAction in
            self.onAddSegment(string: "デビットカード", button: button, index: index)
        }
        let credit = UIAlertAction(title: "クレジットカード", style: .default) { UIAlertAction in
            self.onAddSegment(string: "クレジットカード", button: button, index: index)
        }
        let shopping = UIAlertAction(title: "ショッピングクレジット", style: .default) { UIAlertAction in
            self.onAddSegment(string: "ショッピングクレジット", button: button, index: index)
        }
        let emoney = UIAlertAction(title: "電子マネー", style: .default) { UIAlertAction in
            self.onAddSegment(string: "電子マネー", button: button, index: index)
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
    
    func onRegisterDate(date: Date,index:Int) {
        if checkValidInput(index: index) {
            if let cell = tblPayment.cellForRow(at: IndexPath(row: index, section: 0)) as? PaymentCell {
                let format = DateFormatter()
                format.dateFormat = "yyyy年MM月dd日"
                let formattedDate = format.string(from: date)
                cell.btnCalendar.setTitle(formattedDate, for: .normal)
                settlementOrder[index].settlement_date = Int(date.timeIntervalSince1970)
            }
        }
    }
    
    func checkValidInput(index:Int)->Bool {
        //check valid
        let isIndexValid = settlementOrder.indices.contains(index)
        if !isIndexValid {
            Utils.showAlert(message: "先にお支払い方法[\(index + 1)]の情報が不足しています", view: self)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return false
        }
        return true
    }
    
    func onAddSegment(string:String,button: UIButton,index:Int) {
        if let text = button.titleLabel?.text {
            if text != "リスト選択" {
                scrollSegment.insertSegment(withTitle: string, image: #imageLiteral(resourceName: "segment-\(index + 1)"), at: index)
                scrollSegment.removeSegment(at: index + 1)
                //overwrite old data
                settlementOrder[index].settlement_type = string
                settlementOrder[index].institution_name = ""
                settlementOrder[index].index = index + 1
                
                //check added payment with current selected segment
                if scrollSegment.selectedSegmentIndex == index {
                    removeCurrentPaymentView()
                    addCurrentPaymentView(title: string)
                }
            } else {
                scrollSegment.insertSegment(withTitle: string, image: #imageLiteral(resourceName: "segment-\(index + 1)"), at: scrollSegment.numberOfSegments)
                //add new data
                let order = SettlementData()
                order.brochure_id = brochure.id
                order.settlement_type = string
                order.index = index + 1
                settlementOrder.append(order)
            }
        }
        scrollSegment.setNeedsLayout()
        
        button.setTitle(string, for: .normal)
    }
}
