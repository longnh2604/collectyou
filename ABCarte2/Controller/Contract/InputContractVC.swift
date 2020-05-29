//
//  InputContractVC.swift
//  ABCarte2
//
//  Created by Long on 2019/10/07.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class InputContractVC: UIViewController, UITextFieldDelegate {

    //Variable
    var servicesArr = ["1","2","3","4","5"]
    var relatedProdArr = ["1","2","3","4","5"]
    var currentY : Int?
    var currentM : Int?
    var currentD : Int?
    var timeCreated: Int?
    var finalP : Int?
    var customer = CustomerData()
    var account = AccountData()
    var brochure = BrochureData()
    var courseOrder : [CourseOrderData] = []
    var productOrder : [ProductsOrderData] = []
    let maxLength = 15
    lazy var realm = try! Realm()
    
    //IBOutlet
    @IBOutlet weak var tblServices: UITableView!
    @IBOutlet weak var tblRelatedProd: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lblContractDate: UILabel!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var btnDateFromEnroll: UIButton!
    @IBOutlet weak var btnDateToEnroll: UIButton!
    @IBOutlet weak var tfEnrollFee: UITextField!
    @IBOutlet weak var btnDateFromService: UIButton!
    @IBOutlet weak var btnDateToService: UIButton!
    @IBOutlet weak var tfFinalTotal: UILabel!
    
    fileprivate struct ContractCell {
        static let services = "ContractServicesCell"
        static let related = "RelatedProductCell"
    }
    
    fileprivate struct ContractTable {
        static let services = 0
        static let related = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! realm.write {
            realm.delete(realm.objects(CourseOrderData.self))
            realm.delete(realm.objects(ProductsOrderData.self))
        }
       
        setupLayout()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        courseOrder.removeAll()
        productOrder.removeAll()
        GlobalVariables.sharedManager.courseIndex = nil
        GlobalVariables.sharedManager.goodsIndex = nil
    }
    
    fileprivate func setupLayout() {
        //tbl Services
        let nib1 = UINib(nibName: ContractCell.services, bundle: nil)
        tblServices.register(nib1, forCellReuseIdentifier: ContractCell.services)
        //tbl Related Product
        let nib2 = UINib(nibName: ContractCell.related, bundle: nil)
        tblRelatedProd.register(nib2, forCellReuseIdentifier: ContractCell.related)
        
        //register footerview
        tblServices.register(UINib.init(nibName: ContractServicesFooterView.ContractServicesFooterViewIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: ContractServicesFooterView.ContractServicesFooterViewIdentifier)
        tblRelatedProd.register(UINib.init(nibName: RelatedProductsFooterView.RelatedProductsFooterViewIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: RelatedProductsFooterView.RelatedProductsFooterViewIdentifier)
        
        tblServices.delegate = self
        tblServices.dataSource = self
        tblServices.tag = ContractTable.services
        tblServices.isScrollEnabled = false
        tblServices.layer.borderWidth = 1
        tblServices.layer.borderColor = UIColor.black.cgColor

        tblRelatedProd.delegate = self
        tblRelatedProd.dataSource = self
        tblRelatedProd.tag = ContractTable.related
        tblRelatedProd.isScrollEnabled = false
        tblRelatedProd.layer.borderWidth = 1
        tblRelatedProd.layer.borderColor = UIColor.black.cgColor
        
        scrollView.delegate = self
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "お支払い方法画面へ", style: .plain, target: self, action: #selector(onPaymentMethodSelect))
    }
    
    fileprivate func loadData() {
        let currDate = Date()
        let calendar = Calendar.current
        currentY = calendar.component(.year, from: currDate)
        currentM = calendar.component(.month, from: currDate)
        currentD = calendar.component(.day, from: currDate)
        if let time = timeCreated {
            setUnderlineLabel(string: "入力日：\(Utils.convertUnixTimestamp(time: time))", label: lblContractDate)
        }
        
        setUnderlineLabel(string: "顧客名：\(customer.last_name + customer.first_name)", label: lblCusName)
    
        onUpdateFinalTotal()
    }
    
    private func setUnderlineLabel(string: String, label: UILabel) {
        //set underline
        let attributedString = NSMutableAttributedString.init(string: string)
        // Add Underline Style Attribute.
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
            NSRange.init(location: 0, length: attributedString.length));
        label.attributedText = attributedString
    }
    
    fileprivate func fetchingDataWhenMoveNextScreen() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        if let membershipStart = formatter.date(from: btnDateFromEnroll.titleLabel!.text!),let membershipEnd = formatter.date(from: btnDateToEnroll.titleLabel!.text!) {
            brochure.mship_start_date = Int(membershipStart.timeIntervalSince1970)
            brochure.mship_end_date = Int(membershipEnd.timeIntervalSince1970)
        }
        
        if let serviceStart = formatter.date(from: btnDateFromService.titleLabel!.text!),let serviceEnd = formatter.date(from: btnDateToService.titleLabel!.text!) {
            brochure.service_start_date = Int(serviceStart.timeIntervalSince1970)
            brochure.service_end_date = Int(serviceEnd.timeIntervalSince1970)
        }
            
        brochure.user_name = lblCusName.text!
        brochure.admission_fee = (tfEnrollFee.text?.removeFormatAmount())!
        
        let viewContract = tblServices.footerView(forSection: 0) as? ContractServicesFooterView
        if let noContract = viewContract?.tfSubTotal.text?.removeFormatAmount(),let sum_notreat = viewContract?.tfNoTreat.text,let sum_coursetime = viewContract?.tfTotalTime.text {
            brochure.cours_total = noContract
            brochure.sum_notreat = Int(sum_notreat) ?? 0
            brochure.sum_coursetime = Int(sum_coursetime) ?? 0
        }
        
        let viewRelated = tblRelatedProd.footerView(forSection: 0) as? RelatedProductsFooterView
        if let noRelated = viewRelated?.tfTotal.text?.removeFormatAmount(),let sum_nogoods = viewRelated?.tfNoProduct.text {
            brochure.goods_total = noRelated
            brochure.sum_nogoods = Int(sum_nogoods) ?? 0
        }
        
        brochure.total = Int(finalP!)
        if let time = timeCreated {
            brochure.broch_create_date = time
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func removeDataAdded() {
        courseOrder.removeAll()
        productOrder.removeAll()
    }
    
    @objc func onPaymentMethodSelect(sender: UIBarButtonItem) {
        
        //checking condition first
        var totalTax = 0
        for i in 0 ..< tblServices.numberOfRows(inSection: 0) {
            if let cell = tblServices.cellForRow(at: IndexPath(row: i, section: 0)) as? ContractServicesCell {
                let order = CourseOrderData()
                //check course name
                order.unit_price = Int((cell.tfCourseUPrice.text?.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: ""))!)!
                
                if let courseName = cell.btnCourse.titleLabel?.text {
                    if courseName == "コース選択" {
                        continue
                    }
                    order.course_name = courseName
                }
                //check course number of treatment
                if let noTreat = cell.tfCourseNoTreat.text {
                    if noTreat == "" || noTreat == "0" {
                        Utils.showAlert(message: "コースの回数を記入して下さい", view: self)
                        removeDataAdded()
                        return
                    } else {
                        order.num_of_treat = Int(noTreat)!
                        totalTax += Int(Double(order.num_of_treat) * Double(order.unit_price) * 0.1)
                    }
                }
                
                order.brochure_id = brochure.id
                order.treatment_time = Int(cell.tfCourseTime.text!)!
                order.index = i + 1
                order.total_time = Int(cell.tfCourseTotalTime.text!)!
                order.sub_total = (cell.tfCourseSubTotal.text?.removeFormatAmount())!
                courseOrder.append(order)
            }
        }
        
        for j in 0 ..< tblRelatedProd.numberOfRows(inSection: 0) {
            if let cell = tblRelatedProd.cellForRow(at: IndexPath(row: j, section: 0)) as? RelatedProductCell {
                let order = ProductsOrderData()
                order.unit_price = Int((cell.tfProductUPrice.text?.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: ""))!)!
                //check goods name
                if let goodsName = cell.btnProduct.titleLabel?.text {
                    if goodsName == "商品選択" {
                        continue
                    }
                    order.item_name = goodsName
                }
                //check number of goods
                if let noGoods = cell.tfNoProduct.text {
                    if noGoods == "" || noGoods == "0" {
                        Utils.showAlert(message: "商品の数量を記入して下さい", view: self)
                        removeDataAdded()
                        return
                    } else {
                        order.num_of_goods = Int(noGoods)!
                    }
                }
                
                order.brochure_id = brochure.id
                order.item_category = cell.tfProductCategory.text!
                order.index = j + 1
                order.sub_total = Int(cell.tfProductSubTotal.text!)!
                order.tax_price = Int(cell.tfProductTax.text!.trimmingCharacters(in: ["%"]))!
                let tax = Double(order.tax_price)/100
                totalTax += Int(Double(order.num_of_goods) * Double(order.unit_price) * tax)
                order.goods_total = (cell.tfProductTotal.text?.removeFormatAmount())!
                productOrder.append(order)
            }
        }
        
        brochure.total_tax = totalTax
        
        if courseOrder.count == 0 {
            Utils.showAlert(message: "コースを選択して下さい", view: self)
            removeDataAdded()
            return
        } else {
            fetchingDataWhenMoveNextScreen()
            
            if brochure.service_start_date == 0 || brochure.service_end_date == 0 {
                Utils.showAlert(message: "役務提供期間を選択してください。", view: self)
                removeDataAdded()
                return
            }
            
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "PaymentMethodNewVC") as? PaymentMethodNewVC {
                viewController.totalPrice = tfFinalTotal.text
                viewController.brochure = brochure
                viewController.account = account
                SVProgressHUD.show()
                APIRequest.onAddCourseOrderNew(brochureID: brochure.id, course: courseOrder) { (success) in
                    if success {
                        if self.productOrder.count > 0 {
                            APIRequest.onAddGoodsOrderNew(brochureID: self.brochure.id, goods: self.productOrder) { (success) in
                                    if success {
                                        if let navigator = self.navigationController {
                                            navigator.pushViewController(viewController, animated: true)
                                        }
                                    } else {
                                        Utils.showAlert(message: "商品の追加に失敗しました。", view: self)
                                        self.removeDataAdded()
                                    }
                                    SVProgressHUD.dismiss()
                                }
                        } else {
                            if let navigator = self.navigationController {
                                navigator.pushViewController(viewController, animated: true)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        Utils.showAlert(message: "コースの追加に失敗しました。", view: self)
                        self.removeDataAdded()
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    fileprivate func onUpdateFinalTotal() {
        guard let noEnroll = tfEnrollFee.text?.removeFormatAmount() else {
            return
        }
        
        let viewContract = tblServices.footerView(forSection: 0) as? ContractServicesFooterView
        guard let noContract = viewContract?.tfSubTotal.text?.removeFormatAmount() else {
            finalP = noEnroll
            tfFinalTotal.text = String(finalP!).addFormatAmount()
            return
        }
        
        let viewRelated = tblRelatedProd.footerView(forSection: 0) as? RelatedProductsFooterView
        guard let noRelated = viewRelated?.tfTotal.text?.removeFormatAmount() else {
            finalP = noEnroll + noContract
            tfFinalTotal.text = String(finalP!).addFormatAmount()
            return
        }
        
        finalP = noEnroll + noContract + noRelated
        tfFinalTotal.text = String(finalP!).addFormatAmount()
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSelectDate(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 450, height: 300)
            newPopup.delegate = self
            newPopup.position = sender.tag
            newPopup.type = 1
            self.present(newPopup, animated: true, completion: nil)
        case 2:
            guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 450, height: 300)
            newPopup.delegate = self
            newPopup.position = sender.tag
            newPopup.type = 1
            self.present(newPopup, animated: true, completion: nil)
        case 3:
            guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 450, height: 300)
            newPopup.delegate = self
            newPopup.position = sender.tag
            newPopup.type = 1
            self.present(newPopup, animated: true, completion: nil)
        case 4:
            guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 450, height: 300)
            newPopup.delegate = self
            newPopup.position = sender.tag
            newPopup.type = 1
            self.present(newPopup, animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func onEnrollFeeInput(_ sender: UITextField) {
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
            onUpdateFinalTotal()
        }
    }
    
    @IBAction func onDeleteRow(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            if let index = tblServices.indexPathForSelectedRow {
                let cell = tblServices.cellForRow(at: index) as? ContractServicesCell
                cell?.btnCourse.setTitle("コース選択", for: .normal)
                cell?.tfCourseTime.text = "0"
                cell?.tfCourseUPrice.text = "¥0"
                cell?.tfCourseNoTreat.text = ""
                cell?.tfCourseNoTreat.placeholder = "手入力"
                cell?.tfCourseTotalTime.text = "0"
                cell?.tfCourseSubTotal.text = "0"
                
                var sumTreat = 0
                var sumTime = 0
                var sumPrice = 0
                //count all tablecell
                for i in 0 ..< tblServices.numberOfRows(inSection: 0) {
                    let cell = tblServices.cellForRow(at: IndexPath(row: i, section: 0)) as? ContractServicesCell
                    if var text = cell?.tfCourseNoTreat.text! {
                        if text == "" {
                            text = "0"
                        }
                        sumTreat = sumTreat + Int(text)!
                    }
                    
                    sumTime = sumTime + Int((cell?.tfCourseTotalTime.text)!)!
                    sumPrice = sumPrice + Int((cell?.tfCourseSubTotal.text?.removeFormatAmount())!)
                }
                
                let footer = tblServices.footerView(forSection: 0) as! ContractServicesFooterView
                footer.tfNoTreat.text = String(sumTreat)
                footer.tfTotalTime.text = String(sumTime)
                footer.tfSubTotal.text = String(sumPrice).addFormatAmount()
                onUpdateFinalTotal()
            }
        case 2:
            if let index = tblRelatedProd.indexPathForSelectedRow {
                let cell = tblRelatedProd.cellForRow(at: index) as? RelatedProductCell
                cell?.btnProduct.setTitle("商品選択", for: .normal)
                cell?.tfProductCategory.text = ""
                cell?.tfProductUPrice.text = "¥0"
                cell?.tfNoProduct.text = ""
                cell?.tfNoProduct.placeholder = "手入力"
                cell?.tfProductSubTotal.text = "0"
                cell?.tfProductTax.text = "0"
                cell?.tfProductTotal.text = "0"
                
                var sumQuantity = 0
                var sumSubTotal = 0
                var sumTotal = 0
                //count all tablecell
                for i in 0 ..< tblRelatedProd.numberOfRows(inSection: 0) {
                    let cell = tblRelatedProd.cellForRow(at: IndexPath(row: i, section: 0)) as? RelatedProductCell
                    if var text = cell?.tfNoProduct.text! {
                        if text == "" {
                            text = "0"
                        }
                        sumQuantity = sumQuantity + Int(text)!
                    }
                    
                    sumSubTotal = sumSubTotal + Int((cell?.tfProductSubTotal.text)!)!
                    sumTotal = sumTotal + Int((cell?.tfProductTotal.text?.removeFormatAmount())!)
                }
                
                let footer = tblRelatedProd.footerView(forSection: 0) as! RelatedProductsFooterView
                footer.tfNoProduct.text = String(sumQuantity)
                footer.tfSubTotal.text = String(sumSubTotal)
                footer.tfTotal.text = String(sumTotal).addFormatAmount()
                onUpdateFinalTotal()
            }
        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - TableView Datasource, Delegate
//*****************************************************************

extension InputContractVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == ContractTable.services {
            return servicesArr.count
        } else {
            return relatedProdArr.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == ContractTable.services {
            var cell = tableView.dequeueReusableCell(withIdentifier: ContractCell.services, for: indexPath) as? ContractServicesCell
            if cell == nil
            {
                //initialize the cell here
                cell = ContractServicesCell.init(style: .default, reuseIdentifier: ContractCell.services)
            }
            cell?.delegate = self
            cell?.configure(index: indexPath.row)
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: ContractCell.related, for: indexPath) as? RelatedProductCell
            if cell == nil
            {
                //initialize the cell here
                cell = RelatedProductCell.init(style: .default, reuseIdentifier: ContractCell.related)
            }
            cell?.delegate = self
            cell?.configure(index: indexPath.row)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.tag == ContractTable.services {
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: ContractServicesFooterView.ContractServicesFooterViewIdentifier) as! ContractServicesFooterView
            var noTreat = 0
            var noTotalTime = 0
            var noSubTotal = 0
            for i in 0 ..< tblServices.numberOfRows(inSection: 0) {
                if let cell = tblServices.cellForRow(at: IndexPath(row: i, section: 0)) as? ContractServicesCell {
                    if let no1 = Int(cell.tfCourseNoTreat.text!) {
                        noTreat = noTreat + no1
                    }
                    if let no2 = Int(cell.tfCourseTotalTime.text!) {
                        noTotalTime = noTotalTime + no2
                    }
                    if let no3 = Int(cell.tfCourseSubTotal.text!) {
                        noSubTotal = noSubTotal + no3
                    }
                }
            }
            return footer
        } else if tableView.tag == ContractTable.related {
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: RelatedProductsFooterView.RelatedProductsFooterViewIdentifier) as! RelatedProductsFooterView
            var noProduct = 0
            var noSubTotal = 0
            var noTax = 0
            var noTotal = 0
            for i in 0 ..< tblRelatedProd.numberOfRows(inSection: 0) {
                if let cell = tblRelatedProd.cellForRow(at: IndexPath(row: i, section: 0)) as? RelatedProductCell {
                    if let no1 = Int(cell.tfNoProduct.text!) {
                        noProduct = noProduct + no1
                    }
                    if let no2 = Int(cell.tfProductSubTotal.text!) {
                        noSubTotal = noSubTotal + no2
                    }
                    if let no3 = Int(cell.tfProductTax.text!) {
                        noTax = noTax + no3
                    }
                    if let no3 = Int(cell.tfProductTotal.text!) {
                        noTotal = noTotal + no3
                    }
                }
            }
            return footer
        } else {
            return UIView()
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
}

//*****************************************************************
// MARK: - ContractServicesCell,RelatedProductCell Delegate
//*****************************************************************

extension InputContractVC: ContractServicesCellDelegate, RelatedProductCellDelegate,ContractCategoryPopupDelegate {
    
    func onContractTapped(index: Int) {
        let newPopup = ContractCategoryPopup(nibName: "ContractCategoryPopup", bundle: nil)
        newPopup.modalPresentationStyle = .formSheet
        newPopup.preferredContentSize = CGSize(width: 400, height: 280)
        newPopup.type = 1
        newPopup.account = account
        newPopup.cellIndex = index
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func onBeginInputNoTreat() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func onNumberOfTreatmentChange(value: Int, index: Int) {
        
        if let cell = tblServices.cellForRow(at: IndexPath(row: index, section: 0)) as? ContractServicesCell {
            if let text = cell.btnCourse.titleLabel?.text {
                if text == "コース選択" {
                    Utils.showAlert(message: "先にコースを選択して下さい", view: self)
                    cell.btnCourse.titleLabel?.text = ""
                    tblServices.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
            }
            if let courseTime = Int(cell.tfCourseTime.text!),let uprice = Int((cell.tfCourseUPrice.text?.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: ""))!) {
                let totalTime = courseTime * value
                cell.tfCourseTotalTime.text = String(totalTime)
                let totalPrice = Float(uprice) * Float(value) * 1.1
                cell.tfCourseSubTotal.text = String(Int(totalPrice)).addFormatAmount()
                
                var sumTreat = 0
                var sumTime = 0
                var sumPrice = 0
                //count all tablecell
                for i in 0 ..< tblServices.numberOfRows(inSection: 0) {
                    let cell = tblServices.cellForRow(at: IndexPath(row: i, section: 0)) as? ContractServicesCell
                    if var text = cell?.tfCourseNoTreat.text! {
                        if text == "" {
                            text = "0"
                        }
                        sumTreat = sumTreat + Int(text)!
                    }
                    
                    sumTime = sumTime + Int((cell?.tfCourseTotalTime.text)!)!
                    sumPrice = sumPrice + Int((cell?.tfCourseSubTotal.text?.removeFormatAmount())!)
                }
                
                let footer = tblServices.footerView(forSection: 0) as! ContractServicesFooterView
                footer.tfNoTreat.text = String(sumTreat)
                footer.tfTotalTime.text = String(sumTime)
                footer.tfSubTotal.text = String(sumPrice).addFormatAmount()
                onUpdateFinalTotal()
            }
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func onRelatedTapped(index: Int) {
        let newPopup = ContractCategoryPopup(nibName: "ContractCategoryPopup", bundle: nil)
        newPopup.modalPresentationStyle = .formSheet
        newPopup.preferredContentSize = CGSize(width: 400, height: 280)
        newPopup.type = 2
        newPopup.account = account
        newPopup.cellIndex = index
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func onBeginInputRelatedProduct() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func onQuantityValueChange(value:Int,index:Int) {
        if let cell = tblRelatedProd.cellForRow(at: IndexPath(row: index, section: 0)) as? RelatedProductCell {
            if let text = cell.btnProduct.titleLabel?.text {
                if text == "商品選択" {
                    Utils.showAlert(message: "先に商品を選択して下さい", view: self)
                    cell.btnProduct.titleLabel?.text = ""
                    tblRelatedProd.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
            }
            if let uprice = Int(cell.tfProductUPrice.text!.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "")),let rate = Float(cell.tfProductTax.text!.trimmingCharacters(in: ["%"])) {
                let subTotal = uprice * value
                cell.tfProductSubTotal.text = String(subTotal)
                let total = Int(Float(subTotal) * (1 + (rate/100)))
                cell.tfProductTotal.text = String(total).addFormatAmount()
                
                var sumQuantity = 0
                var sumSubTotal = 0
                var sumTotal = 0
                //count all tablecell
                for i in 0 ..< tblRelatedProd.numberOfRows(inSection: 0) {
                    let cell = tblRelatedProd.cellForRow(at: IndexPath(row: i, section: 0)) as? RelatedProductCell
                    if var text = cell?.tfNoProduct.text! {
                        if text == "" {
                            text = "0"
                        }
                        sumQuantity = sumQuantity + Int(text)!
                    }
                    
                    sumSubTotal = sumSubTotal + Int((cell?.tfProductSubTotal.text)!)!
                    sumTotal = sumTotal + Int((cell?.tfProductTotal.text?.removeFormatAmount())!)
                }
                
                let footer = tblRelatedProd.footerView(forSection: 0) as! RelatedProductsFooterView
                footer.tfNoProduct.text = String(sumQuantity)
                footer.tfSubTotal.text = String(sumSubTotal)
                footer.tfTotal.text = String(sumTotal).addFormatAmount()
                onUpdateFinalTotal()
            }
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func onSelectContractServices(index: Int, course: CourseData) {
        
        //check if course has already added or not
        for c in 0 ..< tblServices.numberOfRows(inSection: 0) {
            if let cell = tblServices.cellForRow(at: IndexPath(row: c, section: 0)) as? ContractServicesCell {
                if cell.btnCourse.titleLabel?.text == course.course_name {
                    Utils.showAlert(message: "すでに同じ役務の内容が登録されています。数量を確認してください。", view: self)
                    return
                }
            }
        }
        
        //check available slot of product
        var availableIndex = [Int]()
        var addedProductName = [String]()
        for p in 0 ..< tblRelatedProd.numberOfRows(inSection: 0) {
            let cell = tblRelatedProd.cellForRow(at: IndexPath(row: p, section: 0)) as? RelatedProductCell
            if cell?.btnProduct.titleLabel?.text == "商品選択" {
                availableIndex.append(p)
            } else {
                addedProductName.append(cell?.btnProduct.titleLabel?.text ?? "")
            }
        }
            
        if course.products.count > availableIndex.count {
            Utils.showAlert(message: "商品入るスペースが足りないので追加に失敗しました。", view: self)
        } else {
            if let cell = tblServices.cellForRow(at: IndexPath(row: index, section: 0)) as? ContractServicesCell {
                cell.btnCourse.setTitle("\(course.course_name)", for: .normal)
                cell.tfCourseTime.text = String(course.treatment_time)
                cell.tfCourseUPrice.text = String(course.unit_price).addFormatAmount()
                //check if course has needed products
                var indexC = 0
                var indexP = 0
                for i in indexC ..< course.products.count {
                    //check same name product has exist or not
                    if addedProductName.contains(course.products[i].item_name) {
                        indexC += 1
                    } else {
                        for j in indexP ..< availableIndex.count {
                            let cell = tblRelatedProd.cellForRow(at: IndexPath(row: availableIndex[j], section: 0)) as? RelatedProductCell
                            cell?.btnProduct.setTitle(course.products[i].item_name, for: .normal)
                            cell?.tfProductCategory.text = course.products[i].item_category
                            cell?.tfProductUPrice.text = String(course.products[i].unit_price).addFormatAmount()
                            cell?.tfProductTax.text = "\(course.products[i].fee_rate)%"
                            indexP += 1
                            break
                        }
                    }
                }
            }
        }
    }
    
    func onSelectProductRelated(index: Int, course: ProductData) {
        
        //check if course has already added or not
        for p in 0 ..< tblRelatedProd.numberOfRows(inSection: 0) {
            if let cell = tblRelatedProd.cellForRow(at: IndexPath(row: p, section: 0)) as? RelatedProductCell {
                if cell.btnProduct.titleLabel?.text == course.item_name {
                    Utils.showAlert(message: "すでに同じ関連商品が登録されています。数量を確認してください。", view: self)
                    return
                }
            }
        }
        
        if let cell = tblRelatedProd.cellForRow(at: IndexPath(row: index, section: 0)) as? RelatedProductCell {
            cell.btnProduct.setTitle("\(course.item_name)", for: .normal)
            cell.tfProductCategory.text = course.item_category
            cell.tfProductUPrice.text = String(course.unit_price).addFormatAmount()
            cell.tfProductTax.text = "\(course.fee_rate)%"
        }
    }
}

extension InputContractVC: DatePickerPopupVCDelegate {
    func onRegisterDateLocation(date: Date, loc: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        switch loc {
        case 1:
            btnDateFromEnroll.setTitle(dateFormatter.string(from: date), for: .normal)
        case 2:
            btnDateToEnroll.setTitle(dateFormatter.string(from: date), for: .normal)
        case 3:
            btnDateFromService.setTitle(dateFormatter.string(from: date), for: .normal)
        case 4:
            btnDateToService.setTitle(dateFormatter.string(from: date), for: .normal)
        default:
            break
        }
    }
}
