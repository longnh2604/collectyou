//
//  CourseCategoryEditVC.swift
//  ABCDB
//
//  Created by 福嶋伸之 on 2019/12/28.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

// View controller for editing product-category-data specifications. The view is to be embedded to the DatabaseVC's container view. Uses picker.
// Updating current Object property causes refreshing the appearance. Name and isActive calls table's refreshness when updated.

class ProductCategoryEditVC:UIViewController, CanEditDatabaseObject {
    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentProductCategory != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentProductCategory:ProductCategoryData? {
        get { return currentObject as? ProductCategoryData }
        set { currentObject = newValue }
    }
    private var isEdited = false
    var onReloadData: (() -> ())?
    var onEditingBegan:(()->())?
    var onEditingEnded:((Object?)->())?
    var isNewObject:Bool = false {
        didSet {
            switchNewObjectMode()
        }
    }
    var picker:CategoryPickerController?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    //MARK: - lifecycle & actions
    override func viewDidLoad() {
        deactivateInputs()
    }
    @IBAction func categoryNameTextFieldChanged(_ sender: UITextField) {
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
        showDeletionAlert(categoryString:"カテゴリー", subItemString:"商品")
    }

    //MARK: - functions
    private func switchNewObjectMode() {
        if isNewObject {
            saveButton.setTitle("新規作成", for:.normal)
            cancelButton.isEnabled = true
            deleteButton.isHidden = true
        }
        else {
            saveButton.setTitle("更新する", for:.normal)
            cancelButton.isEnabled = false
            deleteButton.isHidden = false
        }
    }
    private func deactivateInputs() {
        categoryNameTextField.text = ""
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        categoryNameTextField.text = currentProductCategory?.category_name
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
    private func finishEditing() {
        guard let productCategoryNameText = categoryNameTextField.text, productCategoryNameText != "" else {
            showCantSaveAlert(message:"カテゴリー名を入力して下さい。", completion:{ self.categoryNameTextField.becomeFirstResponder() })
            return
        }
        
        //API handler
        SVProgressHUD.show(withStatus: "読み込み中")
        let object = currentObject as! ProductCategoryData
        if isNewObject {
            object.account_id = UserDefaults.standard.integer(forKey: "collectu-accid")
            object.category_name = productCategoryNameText
            
            APIRequest.onAddProductCategory(productCategory: object, completion: { (success) in
                if success {
                    self.onUpdateRealm()
                } else {
                    self.showCantSaveAlert(message:MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, completion:{ self.categoryNameTextField.becomeFirstResponder() })
                }
                SVProgressHUD.dismiss()
            })
        } else {
            RealmServices.shared.update(object, with: ["category_name": productCategoryNameText])
            
            APIRequest.onUpdateProductCategory(productCategory: object, completion: { (success) in
                if success {
                    self.onUpdateRealm()
                } else {
                    self.showCantSaveAlert(message:MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, completion:{ self.categoryNameTextField.becomeFirstResponder() })
                }
                SVProgressHUD.dismiss()
            })
        }
    }
    private func onUpdateRealm() {
        isEdited = false
        view.endEditing(true)
        setValueToCurrentObject(categoryNameTextField.text, forKey:"category_name")
        currentProductCategory?.updateUpdated()
        onEditingEnded?(currentProductCategory)
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentProductCategory = currentProductCategory else { return }
        RealmServices.shared.saveObjects(objs:currentProductCategory) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentProductCategory, with:[key:value])
    }
    private func showDeletionAlert(categoryString:String, subItemString:String) {
        if let subItems = currentProductCategory?.getSubItems(ProductData.self),subItems.count != 0 {
            showCantSaveAlert(message: "\nこの\(categoryString)に\(subItems.count)件の\(subItemString)がありますので削除出来ません。")
        } else {
            let alert = UIAlertController(title:"\(categoryString)『\(currentProductCategory?.titleForTable ?? "")』を削除します。この操作は取り消せません。", message:nil, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentObject))
            alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
            present(alert, animated:true, completion:nil)
        }
    }
    private func deleteCurrentObject(alert:UIAlertAction) {
        // set new category to items which belongs the category to be delete.
        if let subItems = self.currentProductCategory?.getSubItems(ProductData.self), let picker = picker {
            let index = picker.pickerView.selectedRow(inComponent:0)
            picker.dbmProduct.appendSubItems(subItems, at:index)
        }
        // delete
        guard let objectToDelete = currentProductCategory else { return }
        
        //API handler
        APIRequest.onDeleteProductCategory(productCategoryID: objectToDelete.id, completion: { (success) in
            if success {
                RealmServices.shared.delete(objectToDelete)
                self.currentProductCategory = nil
                self.onEditingEnded?(nil)
            } else {
                self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
        })
    }
}
