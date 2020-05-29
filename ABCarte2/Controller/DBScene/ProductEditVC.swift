//
//  CourseEditVC.swift
//  ABCDB
//
//  Created by 福嶋伸之 on 2019/12/28.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

// View controller for editing course-data specifications. The view is to be embedded to the DatabaseVC's container view. Uses picker.
// Updating current Object property causes refreshing the appearance. Name and isActive calls table's refreshness when updated.

class ProductEditVC:UIViewController, CanEditDatabaseObject {

    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentProduct != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentProduct:ProductData? {
        get { return currentObject as? ProductData }
        set { currentObject = newValue }
    }
    var selectedCategory:DatabaseManager<ProductCategoryData, ProductData>.CategoryInfo?
    private var isEdited = false
    var onReloadData: (() -> ())?
    var onEditingBegan:(()->())?
    var onEditingEnded:((Object?)->())?
    var isNewObject:Bool = false {
        didSet {
            switchNewObjectMode()
        }
    }
    var pickerVC:UIViewController?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categorySelectButton: UIButton!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var unitPriceTextField: UITextField!
    @IBOutlet weak var feeRateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var indexTextField: UITextField!
    
    //MARK: - lifecycle & actions
    override func viewDidLoad() {
        deactivateInputs()
    }
    @IBAction func categorySelectButtonTapped(_ sender: UIButton) {
        showCategorySelector(button:sender)
        startEditing()
    }
    @IBAction func productNameTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func unitPriceTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func feeRateTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        finishEditing()
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        isEdited = false
        if isNewObject {
            currentObject = nil
            onEditingEnded?(nil)
            return
        }
        onEditingEnded?(currentObject)
    }
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        showDeletionAlert()
    }

    //MARK: - functions
    private func switchNewObjectMode() {
        if isNewObject {
            saveButton.setTitle("新規作成", for:.normal)
            cancelButton.isEnabled = true
            deleteButton.isHidden = true
            categorySelectButton.isEnabled = true
        }
        else {
            saveButton.setTitle("更新する", for:.normal)
            cancelButton.isEnabled = false
            deleteButton.isHidden = false
            categorySelectButton.isEnabled = false
        }
    }
    private func deactivateInputs() {
        categorySelectButton.setTitle("", for:.normal)
        productNameTextField.text = ""
        unitPriceTextField.text = ""
        feeRateTextField.text = ""
        indexTextField.text = ""
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        guard let product = currentProduct else { return }
        categorySelectButton.setTitle(product.findCategory(ProductCategoryData.self)?.titleForTable ?? "カテゴリー指定なし", for:.normal)
        selectedCategory = nil
        productNameTextField.text = product.item_name
        unitPriceTextField.text = String(product.unit_price)
        feeRateTextField.text = String(product.fee_rate)
        if product.category_id != 0 {
            indexTextField.text = String(product.display_num)
        } else {
            indexTextField.text = String(1)
        }
        scrollView.alpha = 1
        scrollView.isUserInteractionEnabled = true
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    private func startEditing() {
        if isEdited {
            return
        }
        else {
            isEdited = true
            saveButton.isEnabled = true
            cancelButton.isEnabled = true
            onEditingBegan?()
        }
    }
    private func showCategorySelector(button:UIButton) {
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"Picker")
        guard let pickerVC = pickerVC as? CategoryPickerController else { return }
        pickerVC.dbmProduct.includesInactives = false
        pickerVC.onSelectionProductChanged = categoryChanged
        pickerVC.initialSelectedProductCategory = selectedCategory?.object ?? currentProduct?.findCategory(ProductCategoryData.self)
        pickerVC.type = 2
        pickerVC.modalPresentationStyle = .popover
        pickerVC.preferredContentSize = CGSize(width:400, height:216)
        pickerVC.popoverPresentationController?.permittedArrowDirections = .up
        pickerVC.popoverPresentationController?.sourceView = categorySelectButton
        pickerVC.popoverPresentationController?.sourceRect = categorySelectButton.bounds
        present(pickerVC, animated:true, completion:nil)
        // 現在カテゴリが未選択だったら、ピッカーの最初の候補を自動的に選択
        if currentProduct?.findCategory(ProductCategoryData.self) == nil, pickerVC.dbmProduct.categories.count > 0 {
            selectedCategory = pickerVC.dbmProduct.categories[0]
            categorySelectButton.setTitle(pickerVC.dbmProduct.categories[0].title, for:.normal)
            if let no = selectedCategory?.subItems.count {
                indexTextField.text = "\(no + 1)"
            }
        }
    }
    private func categoryChanged(to category:DatabaseManager<ProductCategoryData, ProductData>.CategoryInfo?) {
        pickerVC?.dismiss(animated:true, completion:nil)
        selectedCategory = category
        categorySelectButton.setTitle(category?.title, for:.normal)
        if let no = category?.subItems.count {
            indexTextField.text = "\(no + 1)"
        }
    }
    private func finishEditing() {
        guard let productNameText = productNameTextField.text, productNameText != "" else {
            showCantSaveAlert(message:"商品名を入力して下さい。", completion:{ self.productNameTextField.becomeFirstResponder() })
            return
        }
        guard let _ = selectedCategory?.object ?? currentProduct?.findCategory(ProductCategoryData.self) else {
            showCantSaveAlert(message:"カテゴリーを指定してください。")
            return
        }
        
        if isNewObject {
            let realm = RealmServices.shared.realm
            let products = realm.objects(ProductData.self).filter("item_name == '\(productNameText)'")
            if products.count > 0 {
                Utils.showAlert(message: "既に同じ商品名が登録されています。他の商品名を記入してください。", view: self)
                return
            }
        }
        
        guard let currentProduct = currentProduct else { return }
        self.saveButton.isEnabled = false
        var category_id = 0
        var category_name = ""
        if selectedCategory?.object != nil {
            category_id = (selectedCategory?.object!.id)!
            category_name = (selectedCategory?.object!.category_name)!
        } else {
            category_id = currentProduct.category_id
            category_name = currentProduct.item_category
        }
        
        let dict : [String : Any?] = ["item_name" : productNameText,
                                      "item_category" : category_name,
                                      "category_id": category_id,
                                      "unit_price": unitPriceTextField.intValue,
                                      "fee_rate": feeRateTextField.intValue,
                                      "display_num": indexTextField.text]
        RealmServices.shared.update(currentProduct, with: dict)
        
        SVProgressHUD.show(withStatus: "読み込み中")
        
        if isNewObject {
            APIRequest.onAddProduct(product: currentProduct) { (success) in
                self.isEdited = false
                self.view.endEditing(true)
                if success {
                    self.onUpdateRealm(currentProduct: currentProduct)
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                self.saveButton.isEnabled = true
                SVProgressHUD.dismiss()
            }
        } else {
            APIRequest.onUpdateProduct(product: currentProduct) { (success) in
                self.isEdited = false
                self.view.endEditing(true)
                if success {
                    self.onUpdateRealm(currentProduct: currentProduct)
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                self.saveButton.isEnabled = true
                SVProgressHUD.dismiss()
            }
        }
    }
    private func onUpdateRealm(currentProduct:ProductData) {
        if let selectedCategory = selectedCategory, selectedCategory.object != currentProduct.findCategory(ProductCategoryData.self) {
            RealmServices.shared.update(currentProduct, with:[
                ProductData.propertyNameOfCategoryID:selectedCategory.object?.categoryID ?? 0,
                ProductData.propertyNameOfDisplayNum:(selectedCategory.subItems.last?.displayNum ?? 0) + 1
            ])
        }
        setValueToCurrentObject(productNameTextField.text,                  forKey:"item_name") // to be checked
        setValueToCurrentObject(currentProduct.item_category,               forKey:"item_category")
        setValueToCurrentObject(unitPriceTextField.intValue,                forKey:"unit_price")
        setValueToCurrentObject(feeRateTextField.intValue,                  forKey:"fee_rate")
        currentProduct.updateUpdated()
        onEditingEnded?(currentProduct)
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentProduct = currentProduct else { return }
        RealmServices.shared.saveObjects(objs:currentProduct) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentProduct, with:[key:value])
    }
    private func showDeletionAlert() {
        let alert = UIAlertController(title:nil, message:"コース『\(currentProduct?.item_name ?? "")』を削除します。この操作は取り消せません。", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentProduct))
        alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
        present(alert, animated:true, completion:nil)
    }
    private func deleteCurrentProduct(alert:UIAlertAction) {
        guard let deleteProduct = currentProduct else { return }
        //API handler
        SVProgressHUD.show(withStatus: "読み込み中")
        APIRequest.onDeleteProduct(productID: deleteProduct.id, completion: { (success) in
            if success {
                RealmServices.shared.delete(deleteProduct)
                self.currentObject = nil
                self.onReloadData?()
            } else {
                self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
            SVProgressHUD.dismiss()
        })
    }
}

//MARK: - useful extension for editing
fileprivate extension UITextField {
    var intValue:Int {
        get {
            return Int(text ?? "0") ?? 0
        }
        set {
            text = String(newValue)
        }
    }
}
