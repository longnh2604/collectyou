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

class StaffEditVC:UIViewController, CanEditDatabaseObject {

    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentStaff != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentStaff:StaffData? {
        get { return currentObject as? StaffData }
        set { currentObject = newValue }
    }
    var selectedCategory:DatabaseManager<CompanyData, StaffData>.CategoryInfo?
    private var isEdited = false
    var onReloadData: (() -> ())?
    var onEditingBegan:(()->())?
    var onEditingEnded:((Object?)->())?
    var isNewObject:Bool = false {
        didSet {
            switchNewObjectMode()
        }
    }
    var genderSelect = 0
    var pickerVC:UIViewController?
    var imagePicker = UIImagePickerController()
    var imageTemp: UIImage?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categorySelectButton: UIButton!
    @IBOutlet weak var staffNameTextField: UITextField!
    @IBOutlet weak var genderSelectButton: UIButton!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var uploadButton: RoundButton!
    @IBOutlet weak var indexTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lblPermissions: UILabel!
    
    //MARK: - lifecycle & actions
    override func viewDidLoad() {
        deactivateInputs()
    }
    @IBAction func categorySelectButtonTapped(_ sender: UIButton) {
        showCategorySelector(button:sender)
        startEditing()
    }
    @IBAction func staffNameTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func genderSelectButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let male = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), style: .default) { UIAlertAction in
            self.genderSelectButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), for: .normal)
            self.genderSelect = 1
            self.startEditing()
        }
        let female = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), style: .default) { UIAlertAction in
            self.genderSelectButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), for: .normal)
            self.genderSelect = 2
            self.startEditing()
        }
        let undefined = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), style: .default) { UIAlertAction in
            self.genderSelectButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            self.genderSelect = 0
            self.startEditing()
        }
        
        alert.addAction(cancel)
        alert.addAction(female)
        alert.addAction(male)
        alert.addAction(undefined)
        alert.popoverPresentationController?.sourceView = self.genderSelectButton
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.genderSelectButton.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func onUploadAvatar(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)

        let takeNew = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Take a Photo", comment: ""), style: .default) { UIAlertAction in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker,animated: true,completion: nil)
            } else {
                Utils.showAlert(message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Camera not found", comment: ""), view: self)
            }
        }
        let selectPhoto = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Choose Photo from Device", comment: ""), style: .default) { UIAlertAction in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: {
                    self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
                })
            }
        }
        
        let selectNoPhoto = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Delete Representative Image", comment: ""), style: .default) { UIAlertAction in
            let image = UIImage(named: "icon_no_avatar")
            self.imageTemp = image
            self.imvAvatar.image = image
            self.startEditing()
        }
        
        alert.addAction(takeNew)
        alert.addAction(selectPhoto)
        alert.addAction(selectNoPhoto)
        
        alert.popoverPresentationController?.sourceView = self.uploadButton
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.uploadButton.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let staffNameText = staffNameTextField.text, staffNameText != "" else {
            showCantSaveAlert(message:"コース名を入力して下さい。", completion:{ self.staffNameTextField.becomeFirstResponder() })
            return
        }

        guard let _ = selectedCategory?.object ?? currentStaff?.findCategory(CompanyData.self) else {
            showCantSaveAlert(message:"カテゴリーを指定してください。")
            return
        }

        guard let currentStaff = currentStaff else { return }
        var category_id = 0
        var category_name = ""
        if selectedCategory?.object != nil {
            category_id = (selectedCategory?.object!.id)!
            category_name = (selectedCategory?.object!.company_name)!
        } else {
            category_id = currentStaff.company_id
            category_name = currentStaff.company_name
        }

        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        let dict : [String : Any?] = ["staff_name" : staffNameText,
                                      "gender" : genderSelect,
                                      "account_id" : accountID,
                                      "company_id": category_id,
                                      "company_name": category_name,
                                      "display_num": indexTextField.text]
        RealmServices.shared.update(currentStaff, with: dict)

        if isNewObject {
            APIRequest.onAddNewStaff(accID: currentStaff.account_id, staff: currentStaff) { (status) in
                if status == "false" {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    return
                }
                if status == "existed" {
                    Utils.showAlert(message: "同じスタッフの順番があります。", view: self)
                    return
                }
                if (self.imageTemp != nil) {
                    APIRequest.onUpdateStaffAvatar(staffID: currentStaff.id, imageData:self.imageTemp!.jpegData(compressionQuality: 1.0)!) { (url) in
                        if url != "" {
                            RealmServices.shared.update(currentStaff, with: ["avatar_url": url])
                            self.onUpdateRealm(currentStaff: currentStaff)
                            SVProgressHUD.dismiss()
                        } else {
                            self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                        }
                    }
                } else {
                    self.onUpdateRealm(currentStaff: currentStaff)
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            APIRequest.onUpdateStaff(staff: currentStaff) { (success) in
                if success {
                    if (self.imageTemp != nil) {
                        APIRequest.onUpdateStaffAvatar(staffID: currentStaff.id, imageData:self.imageTemp!.jpegData(compressionQuality: 1.0)!) { (url) in
                            if url != "" {
                                RealmServices.shared.update(currentStaff, with: ["avatar_url": url])
                                self.onUpdateRealm(currentStaff: currentStaff)
                                SVProgressHUD.dismiss()
                            } else {
                                self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                            }
                        }
                    } else {
                        self.onUpdateRealm(currentStaff: currentStaff)
                        SVProgressHUD.dismiss()
                    }
                } else {
                    self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
                    SVProgressHUD.dismiss()
                }
            }
        }
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
        genderSelect = 0
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
        categorySelectButton.setTitle("", for: .normal)
        staffNameTextField.text = ""
        genderSelectButton.setTitle("", for: .normal)
        indexTextField.text = ""
        imvAvatar.image = UIImage(named: "icon_no_avatar")
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        guard let staff = currentStaff else { return }
        categorySelectButton.setTitle(staff.findCategory(CompanyData.self)?.titleForTable ?? "指定なし", for:.normal)
        selectedCategory = nil
        staffNameTextField.text = staff.staff_name
        updateStaffGender(type: staff.gender)
        
        if staff.company_id != 0 {
            indexTextField.text = String(staff.display_num)
        } else {
            indexTextField.text = String(1)
        }
        
        if let url = URL(string: staff.avatar_url) {
            imvAvatar.sd_setImage(with: url, completed: nil)
        } else {
            imvAvatar.image = UIImage(named: "icon_no_avatar")
        }
        
        var per = ""
        if staff.permission != "" {
            
            let arr = staff.permission.components(separatedBy: ",")
            let permission = arr.map { Int($0)!}
            if permission.contains(1) {
                per.append("・新規顧客\n")
            }
            if permission.contains(2) {
                per.append("・カルテ\n")
            }
            if permission.contains(3) {
                per.append("・概要書面\n")
            }
            if permission.contains(4) {
                per.append("・契約")
            }
            lblPermissions.text = per
        } else {
            lblPermissions.text = per
        }
        
        scrollView.alpha = 1
        scrollView.isUserInteractionEnabled = true
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    private func updateStaffGender(type:Int) {
        switch type {
        case 0:
            genderSelectButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
        case 1:
            genderSelectButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), for: .normal)
        case 2:
            genderSelectButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), for: .normal)
        default:
            break
        }
    }
    private func startEditing() {
        if isEdited {
            return
        } else {
            isEdited = true
            saveButton.isEnabled = true
            cancelButton.isEnabled = true
            onEditingBegan?()
        }
    }
    private func showCategorySelector(button:UIButton) {
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"Picker")
        guard let pickerVC = pickerVC as? CategoryPickerController else { return }
        pickerVC.type = 3
        pickerVC.dbmStaff.includesInactives = false
        pickerVC.onSelectionCompanyChanged = categoryChanged
        pickerVC.initialSelectedCompanyCategory = selectedCategory?.object ?? currentStaff?.findCategory(CompanyData.self)
        pickerVC.modalPresentationStyle = .popover
        pickerVC.preferredContentSize = CGSize(width:400, height:216)
        pickerVC.popoverPresentationController?.permittedArrowDirections = .up
        pickerVC.popoverPresentationController?.sourceView = categorySelectButton
        pickerVC.popoverPresentationController?.sourceRect = categorySelectButton.bounds
        present(pickerVC, animated:true, completion:nil)
        // 現在カテゴリが未選択だったら、ピッカーの最初の候補を自動的に選択
        if currentStaff?.findCategory(CompanyData.self) == nil, pickerVC.dbmStaff.categories.count > 0 {
            selectedCategory = pickerVC.dbmStaff.categories[0]
            categorySelectButton.setTitle(pickerVC.dbmStaff.categories[0].title, for:.normal)
            if let no = selectedCategory?.subItems.count {
                indexTextField.text = "\(no + 1)"
            }
        }
    }
    private func categoryChanged(to category:DatabaseManager<CompanyData, StaffData>.CategoryInfo?) {
        pickerVC?.dismiss(animated:true, completion:nil)
        selectedCategory = category
        categorySelectButton.setTitle(category?.title, for:.normal)
        if let no = category?.subItems.count {
            indexTextField.text = "\(no + 1)"
        }
    }
    private func onUpdateRealm(currentStaff:StaffData) {
        if let selectedCategory = selectedCategory, selectedCategory.object != currentStaff.findCategory(CompanyData.self) {
            RealmServices.shared.update(currentStaff, with:[
                ProductData.propertyNameOfCategoryID:selectedCategory.object?.categoryID ?? 0,
                ProductData.propertyNameOfDisplayNum:(selectedCategory.subItems.last?.displayNum ?? 0) + 1
            ])
        }
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        setValueToCurrentObject(accountID,                      forKey:"account_id")
        setValueToCurrentObject(staffNameTextField.text,        forKey:"staff_name") // to be checed
        setValueToCurrentObject(genderSelect,                   forKey:"gender")
        setValueToCurrentObject(currentStaff.company_id,        forKey:"company_id")
        setValueToCurrentObject(currentStaff.company_name,      forKey:"company_name")
        currentStaff.updateUpdated()
        onEditingEnded?(currentStaff)
        
        isEdited = false
        view.endEditing(true)
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentStaff = currentStaff else { return }
        RealmServices.shared.saveObjects(objs:currentStaff) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentStaff, with:[key:value])
    }
    private func showDeletionAlert() {
        let alert = UIAlertController(title:nil, message:"スタッフ『\(currentStaff?.staff_name ?? "")』を削除します。この操作は取り消せません。", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentStaff))
        alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
        present(alert, animated:true, completion:nil)
    }
    private func deleteCurrentStaff(alert:UIAlertAction) {
        guard let deleteStaff = currentStaff else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        //API handler
        APIRequest.onDeleteStaff(staffID: deleteStaff.id, completion: { (success) in
            if success {
                RealmServices.shared.delete(deleteStaff)
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

//*****************************************************************
// MARK: - UIImagePicker
//*****************************************************************

extension StaffEditVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let newImage = Utils.imageWithImage(sourceImage: selectedImage, scaledToWidth:768)
        
        self.dismiss(animated: true, completion: { () -> Void in
            let imgRotated = newImage.updateImageOrientionUpSide()
            self.imageTemp = imgRotated
            self.reloadAvatar(photo: imgRotated!)
            self.startEditing()
        })
    }
    
    private func reloadAvatar(photo: UIImage) {
           imvAvatar.image = photo
       }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
