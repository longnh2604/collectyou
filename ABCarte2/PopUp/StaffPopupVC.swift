//
//  StaffPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/09.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objc protocol StaffPopupVCDelegate: class {
    @objc optional func onRefreshData()
    @objc optional func onDeleteIndex(index:Int)
}

class StaffPopupVC: UIViewController,UITextFieldDelegate {

    //Variable
    var imagePicker = UIImagePickerController()
    var imageTemp: UIImage?
    weak var delegate:StaffPopupVCDelegate?
    var staff: StaffData?
    var companies: Results<CompanyData>!
    lazy var realm = try! Realm()
    let companyDropMenu = DropDown()
    
    var accountID: Int?
    var index: Int?
    var companyIndex: Int?
    var totalStaff = 0
    var genderSelect = 0
    var roleSelect = 0
    
    //IBOutlet
    @IBOutlet weak var tfStaffName: UITextField!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var btnRole: UIButton!
    @IBOutlet weak var imvStaff: UIImageView!
    @IBOutlet weak var btnPhotoUpload: UIButton!
    @IBOutlet weak var tfStaffOrder: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCompany: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
        setupLayout()
    }
    
    private func setupLayout() {
        tfStaffOrder.delegate = self
        tfStaffOrder.text = "\(totalStaff + 1)"
        
        guard let staff = staff else { return }
        tfStaffName.text = staff.staff_name
        tfStaffOrder.text = "\(staff.display_num)"
        updateStaffGender(type: staff.gender)
        if staff.company_name != "" {
            btnCompany.setTitle(staff.company_name, for: .normal)
        }
        if staff.avatar_url != "" {
            imvStaff.sd_setImage(with: URL(string: staff.avatar_url), completed: nil)
        }
        
        //unable staff order
        tfStaffOrder.isUserInteractionEnabled = false
        btnDelete.isHidden = false
    }
    
    private func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        guard let accountID = self.accountID else { return }
        APIRequest.onGetCompanyInfo(accID: accountID) { (success) in
            if success {
                self.companies = self.realm.objects(CompanyData.self)
                self.setupCompanyDropDown()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    private func updateStaffGender(type:Int) {
        switch type {
        case 0:
            btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            genderSelect = 0
        case 1:
            btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), for: .normal)
            genderSelect = 1
        case 2:
            btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), for: .normal)
            genderSelect = 2
        default:
            break
        }
    }
    
    private func updateStaffRole(type:Int) {
        switch type {
        case 0:
            btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            roleSelect = 0
        case 1:
            btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "パート", comment: ""), for: .normal)
            roleSelect = 1
        case 2:
            btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "通常", comment: ""), for: .normal)
            roleSelect = 2
        case 3:
            btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "医師", comment: ""), for: .normal)
            roleSelect = 3
        default:
            break
        }
    }
    
    private func reloadAvatar(photo: UIImage) {
        imvStaff.image = photo
    }
    
    private func setupCompanyDropDown() {
        companyDropMenu.anchorView = btnCompany
        companyDropMenu.bottomOffset = CGPoint(x: 0, y: btnCompany.bounds.height)
        var compN : [String] = []
        for i in 0 ..< companies.count {
            compN.append(companies[i].company_name)
        }
        companyDropMenu.dataSource = compN
        companyDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnCompany.setTitle("\(item)", for: .normal)
            self?.companyIndex = index
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let no = Int(textField.text ?? "") else { return }
        textField.text = "\(no)"
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onCompanySelect(_ sender: UIButton) {
        companyDropMenu.show()
    }
    
    @IBAction func onRoleSelect(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let part = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "パート", comment: ""), style: .default) { UIAlertAction in
            self.btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "パート", comment: ""), for: .normal)
            self.roleSelect = 1
        }
        let normal = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "通常", comment: ""), style: .default) { UIAlertAction in
            self.btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "通常", comment: ""), for: .normal)
            self.roleSelect = 2
        }
        let doctor = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "医師", comment: ""), style: .default) { UIAlertAction in
            self.btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "医師", comment: ""), for: .normal)
            self.roleSelect = 3
        }
        let undefined = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), style: .default) { UIAlertAction in
            self.btnRole.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            self.roleSelect = 0
        }
        
        alert.addAction(cancel)
        alert.addAction(part)
        alert.addAction(normal)
        alert.addAction(doctor)
        alert.addAction(undefined)
        alert.popoverPresentationController?.sourceView = self.btnRole
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnRole.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onGenderSelect(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let male = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), style: .default) { UIAlertAction in
            self.btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), for: .normal)
            self.genderSelect = 1
        }
        let female = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), style: .default) { UIAlertAction in
            self.btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), for: .normal)
            self.genderSelect = 2
        }
        let undefined = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), style: .default) { UIAlertAction in
            self.btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            self.genderSelect = 0
        }
        
        alert.addAction(cancel)
        alert.addAction(female)
        alert.addAction(male)
        alert.addAction(undefined)
        alert.popoverPresentationController?.sourceView = self.btnGender
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnGender.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTakePhoto(_ sender: UIButton) {
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
            guard let img = UIImage(named: "img_no_photo") else { return }
            self.imageTemp = img
            self.reloadAvatar(photo: img)
        }
        
        alert.addAction(takeNew)
        alert.addAction(selectPhoto)
        alert.addAction(selectNoPhoto)
        
        alert.popoverPresentationController?.sourceView = self.btnPhotoUpload
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnPhotoUpload.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        if tfStaffName.text == "" {
            Utils.showAlert(message: "氏名を記入してください", view: self)
            return
        }
        if tfStaffOrder.text == "" {
            Utils.showAlert(message: "順番を記入してください", view: self)
            return
        }
        
        let staffData = StaffData()
        staffData.staff_name = self.tfStaffName.text!
        staffData.gender = self.genderSelect
        staffData.display_num = Int(self.tfStaffOrder.text!)!
        if (companyIndex != nil) {
            staffData.company_id = self.companies[companyIndex!].id
        }
        
        //check add new or update
        if (self.staff != nil) {
            guard let staffID = self.staff?.id else { return }
            staffData.id = staffID
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onUpdateStaff(staff: staffData) { (success) in
                if success {
                    if (self.imageTemp != nil) {
                        APIRequest.onUpdateStaffAvatar(staffID: staffID, imageData:self.imageTemp!.jpegData(compressionQuality: 1.0)!) { (url) in
                            if url != "" {
                                self.dismiss(animated: true) {
                                    self.delegate?.onRefreshData?()
                                }
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                                SVProgressHUD.dismiss()
                            }
                        }
                    } else {
                        self.dismiss(animated: true) {
                            self.delegate?.onRefreshData?()
                        }
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            guard let accountID = self.accountID else { return }
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onAddNewStaff(accID: accountID, staff: staffData) { (status) in
                if status == "false" {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    SVProgressHUD.dismiss()
                    return
                }
                
                if status == "existed" {
                    Utils.showAlert(message: "同じスタッフの順番があります。", view: self)
                    self.dismiss(animated: true) {
                        self.delegate?.onRefreshData?()
                    }
                }
                
                if (self.imageTemp != nil) {
                    APIRequest.onUpdateStaffAvatar(staffID:Int(status)!,imageData:self.imageTemp!.jpegData(compressionQuality: 1.0)!) { (url) in
                        if url != "" {
                            self.dismiss(animated: true) {
                                self.delegate?.onRefreshData?()
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                            SVProgressHUD.dismiss()
                        }
                    }
                } else {
                    self.dismiss(animated: true) {
                        self.delegate?.onRefreshData?()
                    }
                }
            }
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        let alert = UIAlertController(title: "選択しているスタッフを削除しますか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            guard let staff = self.staff else { return }
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onDeleteStaff(staffID: staff.id) { (success) in
                if success {
                    self.dismiss(animated: true) {
                        self.delegate?.onDeleteIndex?(index: self.index!)
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UIImagePicker
//*****************************************************************

extension StaffPopupVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let newImage = Utils.imageWithImage(sourceImage: selectedImage, scaledToWidth:768)
        
        self.dismiss(animated: true, completion: { () -> Void in
            let imgRotated = newImage.updateImageOrientionUpSide()
            self.imageTemp = imgRotated
            self.reloadAvatar(photo: imgRotated!)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
