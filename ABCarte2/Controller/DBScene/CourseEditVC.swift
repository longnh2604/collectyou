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

class CourseEditVC:UIViewController, CanEditDatabaseObject {
    
    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentCourse != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentCourse:CourseData? {
        get { return currentObject as? CourseData }
        set { currentObject = newValue }
    }
    var selectedCategory:DatabaseManager<CourseCategoryData, CourseData>.CategoryInfo?
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
    var selectedProduct = [ProductData]()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categorySelectButton: UIButton!
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var treatmentTimeTextField: UITextField!
    @IBOutlet weak var unitPriceTextField: UITextField!
    @IBOutlet weak var indexTextField: UITextField!
    @IBOutlet weak var feeRateTextField: UITextField!
    @IBOutlet weak var requireItemsTextView: UITextView!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    //MARK: - lifecycle & actions
    override func viewDidLoad() {
        deactivateInputs()
        requireItemsTextView.layer.cornerRadius = 5
    }
    @IBAction func categorySelectButtonTapped(_ sender: UIButton) {
        showCategorySelector(button:sender)
        startEditing()
    }
    @IBAction func courseNameTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func treatmentTimeTextFieldChanged(_ sender: UITextField) {
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
    @IBAction func onAddRequirementProduct(_ sender: UIButton) {
        guard let newPopup = ProductListPopupVC(nibName: "ProductListPopupVC", bundle: nil) as ProductListPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 300, height: 500)
        
        guard let course = currentCourse else { return }
        
        var productIDs = [Int]()
        //check if first time or not
        if selectedProduct.count > 0 {
            for i in 0 ..< selectedProduct.count {
                productIDs.append(selectedProduct[i].id)
            }
        } else {
            for i in 0 ..< course.products.count {
                productIDs.append(course.products[i].id)
            }
        }
        newPopup.productIDs = productIDs
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
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
        courseNameTextField.text = ""
        treatmentTimeTextField.text = ""
        unitPriceTextField.text = ""
        feeRateTextField.text = ""
        requireItemsTextView.text = ""
        indexTextField.text = ""
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        guard let course = currentCourse else { return }
        categorySelectButton.setTitle(course.findCategory(CourseCategoryData.self)?.titleForTable ?? "カテゴリー指定なし", for:.normal)
        selectedCategory = nil
        selectedProduct.removeAll()
        courseNameTextField.text = course.course_name
        treatmentTimeTextField.text = String(course.treatment_time)
        unitPriceTextField.text = String(course.unit_price)
        feeRateTextField.text = String(course.fee_rate)

        if course.category_id != 0 {
            indexTextField.text = String(course.display_num)
        } else {
            indexTextField.text = String(1)
        }
        
        var products = ""
        for i in 0 ..< course.products.count {
            products.append("・\(course.products[i].item_name)\n")
        }
        requireItemsTextView.text = products
        
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
        pickerVC.type = 1
        pickerVC.dbmCourse.includesInactives = false
        pickerVC.onSelectionCourseChanged = categoryChanged
        pickerVC.initialSelectedCourseCategory = selectedCategory?.object ?? currentCourse?.findCategory(CourseCategoryData.self)
        pickerVC.modalPresentationStyle = .popover
        pickerVC.preferredContentSize = CGSize(width:400, height:216)
        pickerVC.popoverPresentationController?.permittedArrowDirections = .up
        pickerVC.popoverPresentationController?.sourceView = categorySelectButton
        pickerVC.popoverPresentationController?.sourceRect = categorySelectButton.bounds
        present(pickerVC, animated:true, completion:nil)
        // 現在カテゴリが未選択だったら、ピッカーの最初の候補を自動的に選択
        if currentCourse?.findCategory(CourseCategoryData.self) == nil, pickerVC.dbmCourse.categories.count > 0 {
            selectedCategory = pickerVC.dbmCourse.categories[0]
            categorySelectButton.setTitle(pickerVC.dbmCourse.categories[0].title, for:.normal)
            if let no = selectedCategory?.subItems.count {
                indexTextField.text = "\(no + 1)"
            }
        }
    }
    private func categoryChanged(to category:DatabaseManager<CourseCategoryData, CourseData>.CategoryInfo?) {
        pickerVC?.dismiss(animated:true, completion:nil)
        selectedCategory = category
        categorySelectButton.setTitle(category?.title, for:.normal)
        if let no = category?.subItems.count {
            indexTextField.text = "\(no + 1)"
        }
    }
    private func finishEditing() {
        
        guard let courseNameText = courseNameTextField.text, courseNameText != "" else {
            showCantSaveAlert(message:"コース名を入力して下さい。", completion:{ self.courseNameTextField.becomeFirstResponder() })
            return
        }
        guard let _ = selectedCategory?.object ?? currentCourse?.findCategory(CourseCategoryData.self) else {
            showCantSaveAlert(message:"カテゴリーを指定してください。")
            return
        }
        
        if isNewObject {
            let realm = RealmServices.shared.realm
            let courses = realm.objects(CourseData.self).filter("course_name == '\(courseNameText)'")
            if courses.count > 0 {
                Utils.showAlert(message: "既に同じコース名が登録されています。他のコース名を記入してください。", view: self)
                return
            }
        }
        guard let currentCourse = currentCourse else { return }
        saveButton.isEnabled = false
        var category_id = 0
        if selectedCategory?.object != nil {
            category_id = (selectedCategory?.object!.id)!
        } else {
            category_id = currentCourse.category_id
        }
        
        var arrProduct = [Int]()
        for i in 0 ..< selectedProduct.count {
            arrProduct.append(selectedProduct[i].id)
        }
        let strProduct = (arrProduct.map{String($0)}).joined(separator: ",")
        let dict : [String : Any?] = ["course_name" : courseNameText,
                                      "category_id": category_id,
                                      "treatment_time" : treatmentTimeTextField.intValue,
                                      "unit_price": unitPriceTextField.intValue,
                                      "fee_rate": feeRateTextField.intValue,
                                      "requir_items": strProduct,
                                      "display_num": indexTextField.text]
        RealmServices.shared.update(currentCourse, with: dict)
        
        SVProgressHUD.show(withStatus: "読み込み中")
        
        if isNewObject {
            APIRequest.onAddCourse(course: currentCourse) { (success) in
                if success {
                    self.onUpdateRealm(currentCourse: currentCourse)
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                self.isEdited = false
                self.view.endEditing(true)
                self.saveButton.isEnabled = true
                self.onReloadData?()
                SVProgressHUD.dismiss()
            }
        } else {
            APIRequest.onUpdateCourse(course: currentCourse) { (success) in
                if success {
                    self.onUpdateRealm(currentCourse: currentCourse)
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                }
                self.isEdited = false
                self.view.endEditing(true)
                self.saveButton.isEnabled = true
                self.onReloadData?()
                SVProgressHUD.dismiss()
            }
        }
    }
    private func onUpdateRealm(currentCourse:CourseData) {
        if let selectedCategory = selectedCategory, selectedCategory.object != currentCourse.findCategory(CourseCategoryData.self) {
            RealmServices.shared.update(currentCourse, with:[
                CourseData.propertyNameOfCategoryID:selectedCategory.object?.categoryID ?? 0,
                CourseData.propertyNameOfDisplayNum:(selectedCategory.subItems.last?.displayNum ?? 0) + 1
            ])
        }
        setValueToCurrentObject(courseNameTextField.text,        forKey:"course_name") // to be checed
        setValueToCurrentObject(treatmentTimeTextField.intValue, forKey:"treatment_time")
        setValueToCurrentObject(unitPriceTextField.intValue,     forKey:"unit_price")
        setValueToCurrentObject(feeRateTextField.intValue,       forKey:"fee_rate")
        
        var arrProduct = [Int]()
        for i in 0 ..< selectedProduct.count {
            arrProduct.append(selectedProduct[i].id)
        }
        let strProduct = (arrProduct.map{String($0)}).joined(separator: ",")
        setValueToCurrentObject(strProduct,      forKey:"requir_items")
        
        currentCourse.updateUpdated()
        onEditingEnded?(currentCourse)
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentCourse = currentCourse else { return }
        RealmServices.shared.saveObjects(objs:currentCourse) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentCourse, with:[key:value])
    }
    private func showDeletionAlert() {
        let alert = UIAlertController(title:nil, message:"コース『\(currentCourse?.course_name ?? "")』を削除します。この操作は取り消せません。", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentCourse))
        alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
        present(alert, animated:true, completion:nil)
    }
    private func deleteCurrentCourse(alert:UIAlertAction) {
        guard let deleteCourse = currentCourse else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        //API handler
        APIRequest.onDeleteCourse(courseID: deleteCourse.id, completion: { (success) in
            if success {
                RealmServices.shared.delete(deleteCourse)
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

extension CourseEditVC: ProductListPopupVCDelegate {
    
    func onAddProduct(products: [ProductData]) {
        selectedProduct = products
        
        var stringP = ""
        for i in 0 ..< products.count {
            stringP.append("・\(products[i].item_name)\n")
        }
        requireItemsTextView.text = stringP
        
        startEditing()
    }
}
