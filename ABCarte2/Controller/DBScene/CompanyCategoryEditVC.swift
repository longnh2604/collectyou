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

class CompanyCategoryEditVC:UIViewController, CanEditDatabaseObject {
    
    //MARK: - properties & outlets
    var currentObject:Object? {
        didSet {
            if currentCompanyCategory != nil {
                loadInputValues()
            }
            else {
                deactivateInputs()
            }
        }
    }
    private var currentCompanyCategory:CompanyData? {
        get { return currentObject as? CompanyData }
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
    var imagePicker = UIImagePickerController()
    var imageTemp: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var presidentNameTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var buildingnoTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var imvStamp: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    //MARK: - lifecycle & actions
    override func viewDidLoad() {
        deactivateInputs()
    }
    @IBAction func companyNameTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func presidentNameTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func postcodeTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func addressTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func buildnoTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func phoneTextFieldChanged(_ sender: UITextField) {
        startEditing()
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        finishEditing()
    }
    @IBAction func onAddStamp(_ sender: UIButton) {
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
            self.imageTemp = nil
            self.imvStamp.image = nil
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
        showDeletionAlert(categoryString:"会社", subItemString:"スタッフ")
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
        companyNameTextField.text = ""
        presidentNameTextField.text = ""
        postcodeTextField.text = ""
        addressTextField.text = ""
        buildingnoTextField.text = ""
        phoneTextField.text = ""
        imvStamp.image = nil
        scrollView.alpha = 0.5
        scrollView.isUserInteractionEnabled = false
        scrollView.contentOffset = .zero
        view.endEditing(true)
        isNewObject = false
    }
    private func loadInputValues() {
        companyNameTextField.text = currentCompanyCategory?.company_name
        presidentNameTextField.text = currentCompanyCategory?.president_name
        postcodeTextField.text = currentCompanyCategory?.zip
        addressTextField.text = currentCompanyCategory?.address1
        buildingnoTextField.text = currentCompanyCategory?.address2
        phoneTextField.text = currentCompanyCategory?.tel
        if let stringURL = currentCompanyCategory?.stamp {
            imvStamp.sd_setImage(with: URL(string: stringURL), completed: nil)
        } else {
            imvStamp.image = nil
        }
        imageTemp = nil
        scrollView.alpha = 1
        scrollView.isUserInteractionEnabled = true
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    private func reloadAvatar(photo: UIImage) {
        imvStamp.image = photo
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
        guard let companyCategoryNameText = companyNameTextField.text, companyCategoryNameText != "" else {
            showCantSaveAlert(message:"カテゴリー名を入力して下さい。", completion:{ self.companyNameTextField.becomeFirstResponder() })
            return
        }
        
        guard let presidentNameText = presidentNameTextField.text, presidentNameText != "" else {
            showCantSaveAlert(message:"社長名を入力して下さい。", completion:{ self.presidentNameTextField.becomeFirstResponder() })
            return
        }
        
        guard let postcodeText = postcodeTextField.text, postcodeText != "" else {
            showCantSaveAlert(message:"郵便コードを入力して下さい。", completion:{ self.postcodeTextField.becomeFirstResponder() })
            return
        }
        
        guard let addressText = addressTextField.text, addressText != "" else {
            showCantSaveAlert(message:"住所を入力して下さい。", completion:{ self.addressTextField.becomeFirstResponder() })
            return
        }
        
        guard let buildingnoText = buildingnoTextField.text, buildingnoText != "" else {
            showCantSaveAlert(message:"ビル・番号を入力して下さい。", completion:{ self.buildingnoTextField.becomeFirstResponder() })
            return
        }
        
        guard let phoneText = phoneTextField.text, phoneText != "" else {
            showCantSaveAlert(message:"連絡先を入力して下さい。", completion:{ self.phoneTextField.becomeFirstResponder() })
            return
        }
        
        //API handler
        let object = currentObject as! CompanyData
        SVProgressHUD.show(withStatus: "読み込み中")
        if isNewObject {
            object.account_id = UserDefaults.standard.integer(forKey: "collectu-accid")
            object.company_name = companyCategoryNameText
            object.president_name = presidentNameText
            object.zip = postcodeText
            object.address1 = addressText
            object.address2 = buildingnoText
            object.tel = phoneText
            
            APIRequest.onAddCompanyCategory(companyCategory: object,stampData: imageTemp?.jpegData(compressionQuality: 1.0), completion: { (url) in
                if url == "true" {
                    self.onUpdateRealm()
                } else if url == "false" {
                    self.showCantSaveAlert(message:MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, completion:{ self.companyNameTextField.becomeFirstResponder() })
                } else {
                    RealmServices.shared.update(object, with: ["stamp": url])
                    self.onUpdateRealm()
                }
                SVProgressHUD.dismiss()
            })
        } else {
            let dict : [String : Any?] = ["company_name" : companyCategoryNameText,
                                          "president_name": presidentNameText,
                                          "zip" : postcodeText,
                                          "address1": addressText,
                                          "address2": buildingnoText,
                                          "tel": phoneText]
            RealmServices.shared.update(object, with: dict)
            
            APIRequest.onUpdateCompanyCategory(companyCategory: object,stampData: imageTemp?.jpegData(compressionQuality: 1.0), completion: { (url) in
                if url == "true" {
                    self.onUpdateRealm()
                } else if url == "false" {
                    self.showCantSaveAlert(message:MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, completion:{ self.companyNameTextField.becomeFirstResponder() })
                } else {
                    RealmServices.shared.update(object, with: ["stamp":url])
                    self.onUpdateRealm()
                }
                SVProgressHUD.dismiss()
            })
        }
    }
    private func onUpdateRealm() {
        isEdited = false
        view.endEditing(true)
        setValueToCurrentObject(companyNameTextField.text, forKey:"company_name")
        setValueToCurrentObject(presidentNameTextField.text, forKey:"president_name")
        setValueToCurrentObject(postcodeTextField.text, forKey:"zip")
        setValueToCurrentObject(addressTextField.text, forKey:"address1")
        setValueToCurrentObject(buildingnoTextField.text, forKey:"address2")
        setValueToCurrentObject(phoneTextField.text, forKey:"tel")
        currentCompanyCategory?.updateUpdated()
        onEditingEnded?(currentCompanyCategory)
    }
    private func showCantSaveAlert(message:String, completion:(()->())?=nil) {
        let alert = UIAlertController(title:"保存できません", message:message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"閉じる", style:.cancel, handler:{ (action) in completion?() }))
        present(alert, animated:true, completion:nil)
    }
    private func setValueToCurrentObject(_ value:Any?, forKey key:String) {
        guard let currentCompanyCategory = currentCompanyCategory else { return }
        RealmServices.shared.saveObjects(objs:currentCompanyCategory) // Adds to the database if object haven't saved yet.
        RealmServices.shared.update(currentCompanyCategory, with:[key:value])
    }
    private func showDeletionAlert(categoryString:String, subItemString:String) {
        if let subItems = currentCompanyCategory?.getSubItems(StaffData.self),subItems.count != 0 {
            showCantSaveAlert(message: "\nこの\(categoryString)に\(subItems.count)件の\(subItemString)がありますので削除出来ません。")
        } else {
            let alert = UIAlertController(title:"\(categoryString)『\(currentCompanyCategory?.titleForTable ?? "")』を削除します。この操作は取り消せません。", message:nil, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title:"削除する", style:.destructive, handler:deleteCurrentObject))
            alert.addAction(UIAlertAction(title:"キャンセル", style:.cancel, handler:nil))
            present(alert, animated:true, completion:nil)
        }
    }
    private func deleteCurrentObject(alert:UIAlertAction) {
        // set new category to items which belongs the category to be delete.
        if let subItems = self.currentCompanyCategory?.getSubItems(StaffData.self), let picker = picker {
            let index = picker.pickerView.selectedRow(inComponent:0)
            picker.dbmStaff.appendSubItems(subItems, at:index)
        }
        // delete
        guard let objectToDelete = currentCompanyCategory else { return }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        //API handler
        APIRequest.onDeleteCompanyCategory(companyCategoryID: objectToDelete.id,completion: { (success) in
            if success {
                RealmServices.shared.delete(objectToDelete)
                self.currentObject = nil
                self.onEditingEnded?(nil)
            } else {
                self.showCantSaveAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
            SVProgressHUD.dismiss()
        })
    }
}

//*****************************************************************
// MARK: - UIImagePicker
//*****************************************************************

extension CompanyCategoryEditVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
