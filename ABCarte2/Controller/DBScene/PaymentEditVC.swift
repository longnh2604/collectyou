//
//  PaymentEditVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/09.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

class PaymentEditVC:UIViewController,CanEditDatabaseObject {
    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentPayment != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentPayment:PaymentData? {
        get { return currentObject as? PaymentData }
        set { currentObject = newValue }
    }
    var onReloadData: (() -> ())?
    var onEditingBegan:(()->())?
    var onEditingEnded:((Object?)->())?
    var isNewObject:Bool = false {
        didSet {
            switchNewObjectMode()
        }
    }
    var selectedCategory:DatabaseManager<PaymentCategoryData, PaymentData>.CategoryInfo?
    private var isEdited = false
    var pickerVC:UIViewController?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnCategorySelect: UIButton!
    @IBOutlet weak var tfCreditCompany: UITextField!
    @IBOutlet weak var tfIndex: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBAction func onCategorySelect(_ sender: UIButton) {
        showCategorySelector(button:sender)
        startEditing()
    }
    
    private func showCategorySelector(button:UIButton) {
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"Picker")
        guard let pickerVC = pickerVC as? CategoryPickerController else { return }
        pickerVC.dbmProduct.includesInactives = false
        pickerVC.onSelectionPaymentChanged = categoryChanged
        pickerVC.initialSelectedPaymentCategory = selectedCategory?.object ?? currentPayment?.findCategory(PaymentCategoryData.self)
        pickerVC.type = 4
        pickerVC.modalPresentationStyle = .popover
        pickerVC.preferredContentSize = CGSize(width:400, height:216)
        pickerVC.popoverPresentationController?.permittedArrowDirections = .up
        pickerVC.popoverPresentationController?.sourceView = btnCategorySelect
        pickerVC.popoverPresentationController?.sourceRect = btnCategorySelect.bounds
        present(pickerVC, animated:true, completion:nil)
        // 現在カテゴリが未選択だったら、ピッカーの最初の候補を自動的に選択
        if currentPayment?.findCategory(ProductCategoryData.self) == nil, pickerVC.dbmPayment.categories.count > 0 {
            selectedCategory = pickerVC.dbmPayment.categories[0]
            btnCategorySelect.setTitle(pickerVC.dbmPayment.categories[0].title, for:.normal)
            if let no = selectedCategory?.subItems.count {
                tfIndex.text = "\(no + 1)"
            }
        }
    }
    
    private func categoryChanged(to category:DatabaseManager<PaymentCategoryData, PaymentData>.CategoryInfo?) {
        pickerVC?.dismiss(animated:true, completion:nil)
        selectedCategory = category
        btnCategorySelect.setTitle(category?.title, for:.normal)
        if let no = category?.subItems.count {
            tfIndex.text = "\(no + 1)"
        }
    }
    
    @IBAction func onCreditCompanyNameChange(_ sender: UITextField) {
        startEditing()
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        guard let tfCreditCompanyName = tfCreditCompany.text, tfCreditCompanyName != "" else {
            showCantSaveAlert(message:"会社カード名を入力して下さい。", completion:{ self.tfCreditCompany.becomeFirstResponder() })
            return
        }
        guard let _ = selectedCategory?.object ?? currentPayment?.findCategory(PaymentCategoryData.self) else {
            showCantSaveAlert(message:"カテゴリーを指定してください。")
            return
        }
        
        if isNewObject {
            let realm = RealmServices.shared.realm
            let cards = realm.objects(PaymentData.self).filter("credit_company == '\(tfCreditCompanyName)'")
            if cards.count > 0 {
                Utils.showAlert(message: "既に同じ商品名が登録されています。他の商品名を記入してください。", view: self)
                return
            }
        }

        guard let currentPayment = currentPayment else { return }
        var category_id = 0
        if selectedCategory?.object != nil {
            category_id = (selectedCategory?.object!.id)!
        } else {
            category_id = currentPayment.category_id
        }
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        let dict : [String : Any?] = ["category_id": category_id,
                                      "credit_company": tfCreditCompanyName,
                                      "display_num": tfIndex.text]
        RealmServices.shared.update(currentPayment, with: dict)

        var link = ""
        switch currentPayment.category_id {
        case 1:
            link = kAPI_CREDIT
        case 2:
            link = kAPI_SHOPPINGCREDIT
        case 3:
            link = kAPI_EMONEY
        default:
            break
        }
        
        if isNewObject {
            APIRequest.onAddNewPayment(accID: accountID, payment: currentPayment, link: link) { (status) in
                if status == 1 {
                    self.onUpdateRealm(currentPayment: currentPayment)
                    self.onReloadData?()
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            APIRequest.onUpdatePayment(payment: currentPayment, link: link) { (success) in
                if success {
                    self.onUpdateRealm(currentPayment: currentPayment)
                    self.onReloadData?()
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    private func onUpdateRealm(currentPayment:PaymentData) {
        setValueToCurrentObject(tfCreditCompany.text,           forKey:"credit_company") // to be checed
        setValueToCurrentObject(tfIndex.text,                   forKey: "display_num")
        setValueToCurrentObject(currentPayment.category_id,     forKey: "category_id")
        currentPayment.updateUpdated()
        onEditingEnded?(currentPayment)
        
        isEdited = false
        view.endEditing(true)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentPayment = currentPayment else { return }
        RealmServices.shared.saveObjects(objs:currentPayment) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentPayment, with:[key:value])
    }
    @IBAction func onCancel(_ sender: UIButton) {
        isEdited = false
        if isNewObject {
            currentObject = nil
            onEditingEnded?(nil)
            return
        }
        onEditingEnded?(currentObject)
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        view.endEditing(true)
        showDeletionAlert()
    }
    
    override func viewDidLoad() {
        
    }
    
    //MARK: - functions
    private func switchNewObjectMode() {
        if isNewObject {
            btnRegister.setTitle("新規作成", for:.normal)
            btnCancel.isEnabled = true
            btnDelete.isHidden = true
            btnCategorySelect.isEnabled = true
        }
        else {
            btnRegister.setTitle("更新する", for:.normal)
            btnCancel.isEnabled = false
            btnDelete.isHidden = false
            btnCategorySelect.isEnabled = false
        }
    }
    private func deactivateInputs() {
        btnCategorySelect.setTitle("", for: .normal)
        tfCreditCompany.text = ""
        tfIndex.text = ""
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        guard let payment = currentPayment else { return }
        btnCategorySelect.setTitle(payment.findCategory(PaymentCategoryData.self)?.titleForTable ?? "指定なし", for:.normal)
        selectedCategory = nil
        tfCreditCompany.text = payment.credit_company
        tfIndex.text = String(payment.display_num)
        scrollView.alpha = 1
        scrollView.isUserInteractionEnabled = true
        btnRegister.isEnabled = false
        btnCancel.isEnabled = false
    }
    private func startEditing() {
        if isEdited {
            return
        } else {
            isEdited = true
            btnRegister.isEnabled = true
            btnCancel.isEnabled = true
            onEditingBegan?()
        }
    }
    private func showDeletionAlert() {
        let alert = UIAlertController(title:nil, message:"スタッフ『\(currentPayment?.credit_company ?? "")』を削除します。この操作は取り消せません。", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentPayment))
        alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
        present(alert, animated:true, completion:nil)
    }
    private func deleteCurrentPayment(alert:UIAlertAction) {
        guard let deleteCurrentPayment = currentPayment else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        
        var link = ""
        switch deleteCurrentPayment.category_id {
        case 1:
            link = kAPI_CREDIT
        case 2:
            link = kAPI_SHOPPINGCREDIT
        case 3:
            link = kAPI_EMONEY
        default:
            break
        }
       
        //API handler
        APIRequest.onDeletePayment(paymentID: deleteCurrentPayment.dbID,link: link,completion: { (success) in
            if success {
                RealmServices.shared.delete(deleteCurrentPayment)
                self.currentObject = nil
                self.onReloadData?()
            } else {
                self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
            SVProgressHUD.dismiss()
        })
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
}
