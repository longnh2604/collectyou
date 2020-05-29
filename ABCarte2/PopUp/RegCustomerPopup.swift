//
//  RegCustomerPopup.swift
//  ABCarte2
//
//  Created by Long on 2018/07/24.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SDWebImage
import SwiftyJSON
import LGButton

protocol RegCustomerPopupDelegate: class {
    func didConfirm(type:Int)
}

class RegCustomerPopup: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate, SecretPopupVCDelegate {

    //Variable
    weak var delegate:RegCustomerPopupDelegate?
    
    var customer = CustomerData()
    var popupType: Int?
    var imagePicker = UIImagePickerController()
    var imageTemp: UIImage? = nil
    var imageConverted: Data?
    var birthDate: Int = 0
    var bloodSelect: Int = 0
    var genderSelect: Int = 0
    var cusIndex: Int?
    var onProgress: Bool = false
    var lat: Double = 0
    var long: Double = 0
    var isEdit: Bool = false
    var dateString : String?
    var cusStatus: Int = 0
    lazy var realm = try! Realm()
    var staffs: Results<StaffData>!
    let staffsDropDown = DropDown()
    
    //IBOutlet
    @IBOutlet weak var viewContent: RoundUIView!
    @IBOutlet var viewEssential: UIView!
    @IBOutlet var viewPrivate: UIView!
    @IBOutlet var viewNote: UIView!
    @IBOutlet weak var btnEssential: RoundButton!
    @IBOutlet weak var btnPrivate: RoundButton!
    @IBOutlet weak var btnNote: RoundButton!
    @IBOutlet weak var lblDayCreate: UILabel!
    @IBOutlet weak var lblDayEdit: RoundLabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnConfirm: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    @IBOutlet weak var btnPreview: RoundButton!
    @IBOutlet weak var lblEssential: UILabel!
    @IBOutlet weak var lblPrivate: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var btnLock: UIButton!
    
    //Essential
    @IBOutlet weak var radioName: RoundUIView!
    @IBOutlet weak var radioNameKana: RoundUIView!
    @IBOutlet weak var radioCusNo: RoundUIView!
    @IBOutlet weak var radioEmergency: RoundUIView!
    @IBOutlet weak var radioResponsible: RoundUIView!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastNameKana: UITextField!
    @IBOutlet weak var tfFirstNameKana: UITextField!
    @IBOutlet weak var tfCusNo: UITextField!
    @IBOutlet weak var tfEmergency: UITextField!
    @IBOutlet weak var btnStaff: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameKana: UILabel!
    @IBOutlet weak var lblCusNo: UILabel!
    @IBOutlet weak var lblEmergency: UILabel!
    @IBOutlet weak var lblResponsible: UILabel!
    
    //Private
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var btnGender: RoundButton!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var btnBirthday: RoundButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var tfPostalCode: UITextField!
    @IBOutlet weak var btnAddConvert: RoundButton!
    @IBOutlet weak var tfPrefecture: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfSubAdd: UITextField!
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var tfMail: UITextField!
    @IBOutlet weak var swMailReceive: UISwitch!
    @IBOutlet weak var lblMailReceive: UILabel!
    @IBOutlet weak var lblBloodType: UILabel!
    @IBOutlet weak var btnBloodType: RoundButton!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var btnAddPhoto: LGButton!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var tvHobby: UITextView!
    @IBOutlet weak var tfAge: UITextField!
    @IBOutlet weak var lblCusStatus: UILabel!
    @IBOutlet weak var btnCusStatus: RoundButton!
    
    //Note
    @IBOutlet weak var lblNote1: UILabel!
    @IBOutlet weak var tvNote1: UITextView!
    @IBOutlet weak var lblNote2: UILabel!
    @IBOutlet weak var tvNote2: UITextView!
    @IBOutlet weak var tfSecretCode: UITextField!
    @IBOutlet weak var btnSecretAccess: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupLayout()
    }
    
    private func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetAllStaffBasedOnPermission(permission: StaffPermission.customer.rawValue) { (success) in
            if success {
                self.staffs = self.realm.objects(StaffData.self).sorted(byKeyPath: "display_num")
                self.setupStaffDropDown()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    private func setupStaffDropDown() {
        staffsDropDown.anchorView = btnStaff
        staffsDropDown.bottomOffset = CGPoint(x: 0, y: btnStaff.bounds.height)
        var jobN : [String] = []
        for i in 0 ..< staffs.count {
            jobN.append(staffs[i].staff_name)
        }
        staffsDropDown.dataSource = jobN
        staffsDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnStaff.setTitle(item, for: .normal)
        }
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = UIColor.gray
        
        btnEssential.layer.borderWidth = 5
        btnEssential.layer.borderColor = UIColor.white.cgColor
        btnEssential.roundTopCorner()
        btnPrivate.layer.borderWidth = 5
        btnPrivate.layer.borderColor = UIColor.white.cgColor
        btnPrivate.roundTopCorner()
        btnNote.layer.borderWidth = 5
        btnNote.layer.borderColor = UIColor.white.cgColor
        btnNote.roundTopCorner()
        
        viewContent.addSubview(viewEssential)
        tfFirstName.delegate = self
        tfLastName.delegate = self
        tfFirstNameKana.delegate = self
        tfLastNameKana.delegate = self
        tfCusNo.delegate = self
        tfEmergency.delegate = self
        tfMail.delegate = self
        tfPostalCode.delegate = self
        
        resetAllButtonState()
        btnEssential.alpha = 1
        
        //check if open exist user
        if popupType == PopUpType.Edit.rawValue {
            //Essential
            tfLastName.text = customer.last_name
            tfFirstName.text = customer.first_name
            tfLastNameKana.text = customer.last_name_kana
            tfFirstNameKana.text = customer.first_name_kana
            tfCusNo.text = customer.customer_no
            tfEmergency.text = customer.urgent_no
            if customer.responsible != "" {
                btnStaff.setTitle(customer.responsible, for: .normal)
            }
            
            //Private
            tfPostalCode.text = customer.postal_code
            tfPrefecture.text = customer.address1
            tfCity.text = customer.address2
            tfSubAdd.text = customer.address3
            tfMail.text = customer.email
            
            switch customer.cus_status {
            case 1:
                let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: customer.cus_status), attributes: Strokes_SET.hiddenS)
                self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            case 2:
                let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: customer.cus_status), attributes: Strokes_SET.troubleS)
                self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            case 3:
                let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: customer.cus_status), attributes: Strokes_SET.trialS)
                self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            case 4:
                let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: customer.cus_status), attributes: Strokes_SET.repeatS)
                self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            case 5:
                let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: customer.cus_status), attributes: Strokes_SET.vipS)
                self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            default:
                let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: customer.cus_status), attributes: Strokes_SET.noreg)
                self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
                break
            }
            cusStatus = customer.cus_status
            
            if customer.thumb != "" {
                let url = URL(string: customer.thumb)
                imvCus.sd_setImage(with: url, completed: nil)
            } else {
                imvCus.image = UIImage(named: "img_no_photo")
            }
            imvCus.layer.cornerRadius = 5
            imvCus.clipsToBounds = true
            
            tvHobby.text = customer.hobby

            //Note
            tvNote1.text = customer.memo1
            tvNote2.text = customer.memo2
            
            checkCondition()
            
            enableUserInput(status: false)
        } else {
            let attributedString = NSAttributedString(string: Utils.checkCusStatus(status: 0), attributes: Strokes_SET.noreg)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            
            btnLock.isHidden = true
        }
        
        checkAccType()
        localizeLanguage()
        changeButtonText()
    }
    
    fileprivate func localizeLanguage() {
        lblEssential.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Basic", comment: "")
        lblPrivate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Private Info", comment: "")
        lblNote.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Remarks", comment: "")
        //Essential
        lblTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Customer Info Registration/Modification", comment: "")
        lblName.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Customer's Name", comment: "")
        lblNameKana.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Customer's Name (Kana)", comment: "")
        lblCusNo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Customer Number", comment: "")
        lblEmergency.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Emergency Contact No", comment: "")
        lblResponsible.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Responsible", comment: "")
        btnCancel.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), for: .normal)
        
        if popupType == PopUpType.Edit.rawValue || popupType == PopUpType.Review.rawValue {
            let dayCreate = Utils.convertUnixTimestamp(time: customer.created_at)
            lblDayCreate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Created Date", comment: "") + ": \(dayCreate)"
            
            let dayUpdate = Utils.convertUnixTimestamp(time: customer.updated_at)
            lblDayEdit.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Last Modified Date", comment: "") + ": \(dayUpdate)"
        } else {
            lblDayCreate.isHidden = true
            lblDayEdit.isHidden = true
        }
        
        if tfFirstName.text!.isEmpty {
            tfFirstName.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input first name", comment: "")
        }
        if tfLastName.text!.isEmpty {
            tfLastName.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input last name", comment: "")
        }
        if tfFirstNameKana.text!.isEmpty {
            tfFirstNameKana.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "First Name", comment: "")
        }
        if tfLastNameKana.text!.isEmpty {
            tfLastNameKana.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Last Name", comment: "")
        }
        if tfCusNo.text!.isEmpty {
            tfCusNo.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input", comment: "")
        }
        if tfEmergency.text!.isEmpty {
            tfEmergency.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input contact number", comment: "")
        }
        
        //Private
        lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Sex", comment: "")
        lblBirthday.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Birthdate", comment: "")
        lblAddress.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Address", comment: "")
        lblMail.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "E-mail", comment: "")
        lblBloodType.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Blood Type", comment: "")
        lblCusStatus.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Rank", comment: "")
        lblHobby.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Hobby", comment: "")
        btnAddPhoto.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Photo Insert", comment: "")
        btnAddConvert.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Convert", comment: ""), for: .normal)
        tfPostalCode.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Postal Code", comment: "")
        tfSubAdd.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Building Name - Room No", comment: "")
        tfPrefecture.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Prefecture", comment: "")
        tfCity.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "City", comment: "")
        tfMail.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "E-mail", comment: "")
        
        if customer.gender == 0 {
            btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            genderSelect = 0
        } else if customer.gender == 1 {
            btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: ""), for: .normal)
            genderSelect = 1
        } else {
            btnGender.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: ""), for: .normal)
            genderSelect = 2
        }
        
        if customer.birthday == 0 {
            btnBirthday.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
        } else {
            btnBirthday.setTitle(Utils.convertUnixTimestamp(time: customer.birthday), for: .normal)
            birthDate = customer.birthday
            
            let dateB = Date(timeIntervalSince1970: TimeInterval(customer.birthday))
            if let age = Calendar.current.dateComponents([.year], from: dateB, to: Date()).year {
                tfAge.text = "\(age) " + LocalizationSystem.sharedInstance.localizedStringForKey(key: "years old", comment: "")
            }
        }
        
        if customer.bloodtype == 0 {
            btnBloodType.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
        } else {
            btnBloodType.setTitle(Utils.checkBloodType(type: customer.bloodtype), for: .normal)
        }
        bloodSelect = customer.bloodtype
        
        //Note
        lblNote1.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Note 1", comment: "")
        lblNote2.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Note 2", comment: "")
        tfSecretCode.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input secret memo password", comment: "")
        btnSecretAccess.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Access", comment: ""), for: .normal)
    }
    
    fileprivate func checkAccType() {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCustomerFlag.rawValue) {
            lblCusStatus.isHidden = false
            btnCusStatus.isHidden = false
        }
    }
    
    fileprivate func checkCondition() {
        if (tfFirstName.text?.count)! > 0 && (tfLastName.text?.count)! > 0 {
            radioName.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfFirstNameKana.text?.count)! > 0 && (tfLastNameKana.text?.count)! > 0 {
            radioNameKana.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfCusNo.text?.count)! > 0 {
            radioCusNo.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfEmergency.text?.count)! > 0 {
            radioEmergency.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if btnStaff.titleLabel?.text != "未登録" {
            radioResponsible.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
    }
    
    fileprivate func removeView() {
        if viewContent.subviews.count > 0 {
            for subview in viewContent.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    fileprivate func changeButtonText() {
        if popupType == PopUpType.Edit.rawValue {
            btnConfirm.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Update", comment: ""), for: .normal)
            btnConfirm.alpha = 0.5
            btnConfirm.isEnabled = false
        }
        if popupType == PopUpType.AddNew.rawValue {
            btnConfirm.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Register", comment: ""), for: .normal)
        }
    }
    
    fileprivate func reloadAvatar(photo: UIImage) {
        imvCus.image = photo
    }
    
    @objc fileprivate func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年 MM月 dd日"
        
        if let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year {
            tfAge.text = "\(age) " + LocalizationSystem.sharedInstance.localizedStringForKey(key: "years old", comment: "")
        }
        
        birthDate = Int(datePicker.date.timeIntervalSince1970)
        btnBirthday.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
        
        dateString = dateFormatter.string(from: datePicker.date)
    }
    
    //Get location from api zipaddress
    fileprivate func getLocationFromPostalCode(postalCode : String){
        
        let url = "https://api.zipaddress.net/?zipcode=\(postalCode)"
            
        Alamofire.request(url, method: .get, parameters: nil, encoding:  JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                let code = json["code"]
                if code == 200 {
                    self.tfPrefecture.text = json["data"]["pref"].stringValue
                    self.tfCity.text = json["data"]["city"].stringValue
                    self.tfSubAdd.text = json["data"]["town"].stringValue
                } else {
                    if code == 400 {
                        Utils.showAlert(message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input 7 numbers of Postal Code", comment: ""), view: self)
                    } else if code == 404 {
                        Utils.showAlert(message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "The address can not be found", comment: ""), view: self)
                    } else {
                        Utils.showAlert(message: json["message"].stringValue, view: self)
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func resetAllButtonState() {
        btnEssential.alpha = 0.6
        btnPrivate.alpha = 0.6
        btnNote.alpha = 0.6
    }
    
    fileprivate func enableUserInput(status:Bool) {
        
        tfLastName.isEnabled = status
        tfFirstName.isEnabled = status
        tfLastNameKana.isEnabled = status
        tfFirstNameKana.isEnabled = status
        tfCusNo.isEnabled = status
        tfEmergency.isEnabled = status
        btnStaff.isEnabled = status
        //Private
        btnGender.isEnabled = status
        btnBirthday.isEnabled = status
        tfPostalCode.isEnabled = status
        btnAddConvert.isEnabled = status
        tfPrefecture.isEnabled = status
        tfCity.isEnabled = status
        tfSubAdd.isEnabled = status
        tfMail.isEnabled = status
        btnBloodType.isEnabled = status
        btnAddPhoto.isEnabled = status
        tvHobby.isSelectable = status
        tvHobby.isEditable = status
        btnCusStatus.isEnabled = status
        //Note
        tvNote1.isSelectable = status
        tvNote1.isEditable = status
        tvNote2.isSelectable = status
        tvNote2.isEditable = status
        tfSecretCode.isEnabled = status
        btnSecretAccess.isEnabled = status

        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {

        } else {
            tfSecretCode.isEnabled = false
            btnSecretAccess.isEnabled = false
        }
        
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onTabSelect(_ sender: UIButton) {
        removeView()
        resetAllButtonState()
        switch sender.tag {
        case 0:
            btnEssential.alpha = 1
            viewContent.addSubview(viewEssential)
            break
        case 1:
            btnPrivate.alpha = 1
            viewContent.addSubview(viewPrivate)
            tvHobby.layer.cornerRadius = 5
            tvHobby.clipsToBounds = true
            break
        case 2:
            btnNote.alpha = 1
            viewContent.addSubview(viewNote)
            break
        default:
            break
        }
    }
    
    fileprivate func onCheckAllInput()->(status: Bool,msg: String) {
        if let count = tfLastName.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 5)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfFirstName.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 6)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfLastNameKana.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 7)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfFirstNameKana.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 8)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfFirstNameKana.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 8)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfCusNo.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 9)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfEmergency.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 10)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfPostalCode.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 12)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfPrefecture.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 13)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfCity.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 14)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfSubAdd.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 15)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tfMail.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 16)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        
        if let count = tvHobby.text?.count {
            if count > 0 {
                let value = Utils.checkLimitCharacter(number: count, type: 17)
                if value.status != true {
                    return (false,value.msg)
                }
            }
        }
        return (true,"")
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        
        if onProgress == false {
            onProgress = true
            
            //check network connection first
            NetworkManager.isUnreachable { _ in
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                self.onProgress = false
                return
            }
            
            //Check Popup type
            if popupType == PopUpType.AddNew.rawValue {
                if (tfLastName.text?.count)! > 0 && (tfFirstName.text?.count)! > 0 {
                    if (tfLastNameKana.text?.count)! > 0 && (tfFirstNameKana.text?.count)! > 0 {
                        if imageTemp != nil {
                            imageConverted = imageTemp?.jpegData(compressionQuality: 0.75)
                        }
                        
                        let check = onCheckAllInput()
                        if check.status != true {
                            Utils.showAlert(message: check.msg, view: self)
                            onProgress = false
                            return
                        }
            
                        SVProgressHUD.show(withStatus: "読み込み中")
                        SVProgressHUD.setDefaultMaskType(.clear)
                        
                        APIRequest.addCustomer(first_name: tfFirstName.text!, last_name: tfLastName.text!, first_name_kana: tfFirstNameKana.text!, last_name_kana: tfLastNameKana.text!, gender: genderSelect, bloodtype: bloodSelect,avatar_image: imageConverted, birthday: birthDate, hobby:tvHobby.text,email: tfMail.text!, postal_code: tfPostalCode.text!, address1: tfPrefecture.text!, address2: tfCity.text!, address3: tfSubAdd.text!, responsible: btnStaff.titleLabel!.text!, mail_block: 0, urgent_no: tfEmergency.text!, memo1: tvNote1.text!, memo2: tvNote2.text!,cusNo:tfCusNo.text!,cusStatus: cusStatus) { (success) in
                                        if success {
                                            self.dismiss(animated: true) {
                                                Utils.showAlert(message: MSG_ALERT.kALERT_CREATE_CUSTOMER_INFO_SUCCESS, view: self)
                                                self.onProgress = false
                                                self.delegate?.didConfirm(type: 1)
                                            }
                                        } else {
                                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                            self.onProgress = false
                                        }
                            SVProgressHUD.dismiss()
                                    }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME_KANA, view: self)
                        onProgress = false
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME, view: self)
                    onProgress = false
                }
            }
            
            if popupType == PopUpType.Edit.rawValue {
                    
                if (tfLastName.text?.count)! > 0 && (tfFirstName.text?.count)! > 0 {
                    if (tfLastNameKana.text?.count)! > 0 && (tfFirstNameKana.text?.count)! > 0 {
                        
                        let check = onCheckAllInput()
                        if check.status != true {
                            Utils.showAlert(message: check.msg, view: self)
                            return
                        }
                        
                        if imageTemp != nil {
                                        imageConverted = imageTemp?.jpegData(compressionQuality: 0.75)
                            
                                        onCheckCustomerIsUp2DateOrNot(cusID: customer.id, update: customer.updated_at) { (success) in
                                            if success {
                                                SVProgressHUD.show(withStatus: "読み込み中")
                                                SVProgressHUD.setDefaultMaskType(.clear)
                                                
                                                APIRequest.editCustomerInfowAvatar(cusID:self.customer.id,first_name: self.tfFirstName.text!, last_name: self.tfLastName.text!, first_name_kana: self.tfFirstNameKana.text!, last_name_kana: self.tfLastNameKana.text!, gender: self.genderSelect, bloodtype: self.bloodSelect,avatar_image:self.imageConverted!, birthday: self.birthDate, hobby:self.tvHobby.text,email: self.tfMail.text!, postal_code: self.tfPostalCode.text!, address1: self.tfPrefecture.text!, address2: self.tfCity.text!, address3: self.tfSubAdd.text!, responsible: self.btnStaff.titleLabel!.text!, mail_block: 0, urgent_no: self.tfEmergency.text!, memo1: self.tvNote1.text!, memo2: self.tvNote2.text!,cusNo:self.tfCusNo.text!,cusStatus: self.cusStatus) { (success,cusData)  in
                                                    if success {
                                                        
                                                        self.customer = cusData
                                                        
                                                        let customerDB = self.realm.objects(CustomerData.self).filter("id == \(cusData.id)").first
                                                        try! self.realm.write {
                                                            customerDB?.last_name_kana = self.customer.last_name_kana
                                                            customerDB?.first_name_kana = self.customer.first_name_kana
                                                            customerDB?.last_name = self.customer.last_name
                                                            customerDB?.first_name = self.customer.first_name
                                                            customerDB?.urgent_no = self.customer.urgent_no
                                                            customerDB?.customer_no = self.customer.customer_no
                                                            customerDB?.responsible = self.customer.responsible
                                                            customerDB?.gender = self.customer.gender
                                                            customerDB?.bloodtype = self.customer.bloodtype
                                                            customerDB?.first_daycome = self.customer.first_daycome
                                                            customerDB?.last_daycome = self.customer.last_daycome
                                                            customerDB?.update_date = self.customer.update_date
                                                            customerDB?.pic_url = self.customer.pic_url
                                                            customerDB?.birthday = self.customer.birthday
                                                            customerDB?.hobby = self.customer.hobby
                                                            customerDB?.email = self.customer.email
                                                            customerDB?.postal_code = self.customer.postal_code
                                                            customerDB?.address1 = self.customer.address1
                                                            customerDB?.address2 = self.customer.address2
                                                            customerDB?.address3 = self.customer.address3
                                                            customerDB?.mail_block = self.customer.mail_block
                                                            customerDB?.memo1 = self.customer.memo1
                                                            customerDB?.memo2 = self.customer.memo2
                                                            customerDB?.created_at = self.customer.created_at
                                                            customerDB?.updated_at = self.customer.updated_at
                                                            customerDB?.selected_status = self.customer.selected_status
                                                            customerDB?.thumb = self.customer.thumb
                                                            customerDB?.resize = self.customer.resize
                                                            customerDB?.onSecret = self.customer.onSecret
                                                            customerDB?.created_at = self.customer.created_at
                                                            customerDB?.cus_status = self.customer.cus_status
                                                        }
                                                        self.dismiss(animated: true) {
                                                            Utils.showAlert(message: MSG_ALERT.kALERT_UPDATE_CUSTOMER_INFO_SUCCESS, view: self)
                                                            self.delegate?.didConfirm(type: 2)
                                                        }
                                                    } else {
                                                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                                    }
                                                    self.onProgress = false
                                                    self.isEdit = false
                                                    self.enableUserInput(status: false)
                                                    SVProgressHUD.dismiss()
                                                }
                                            } else {
                                                self.onProgress = false
                                            }
                                        }
                                    } else {
                                        onCheckCustomerIsUp2DateOrNot(cusID: customer.id, update: customer.updated_at) { (success) in
                                            if success {
                                                SVProgressHUD.show(withStatus: "読み込み中")
                                                SVProgressHUD.setDefaultMaskType(.clear)
                                                
                                                APIRequest.editCustomerInfo(cusID:self.customer.id,first_name: self.tfFirstName.text!, last_name: self.tfLastName.text!, first_name_kana: self.tfFirstNameKana.text!, last_name_kana: self.tfLastNameKana.text!,gender: self.genderSelect, bloodtype: self.bloodSelect, birthday: self.birthDate, hobby:self.tvHobby.text,email: self.tfMail.text!, postal_code: self.tfPostalCode.text!, address1: self.tfPrefecture.text!, address2: self.tfCity.text!, address3: self.tfSubAdd.text!, responsible: self.btnStaff.titleLabel!.text!, mail_block: 0, urgent_no: self.tfEmergency.text!, memo1: self.tvNote1.text!, memo2: self.tvNote2.text!,cusNo:self.tfCusNo.text!,cusStatus: self.cusStatus) { (success,cusData)  in
                                                    if success {
                                                        
                                                        self.customer = cusData
                                                        
                                                        let customerDB = self.realm.objects(CustomerData.self).filter("id == \(cusData.id)").first
                                                        try! self.realm.write {
                                                            customerDB?.last_name_kana = self.customer.last_name_kana
                                                            customerDB?.first_name_kana = self.customer.first_name_kana
                                                            customerDB?.last_name = self.customer.last_name
                                                            customerDB?.first_name = self.customer.first_name
                                                            customerDB?.urgent_no = self.customer.urgent_no
                                                            customerDB?.customer_no = self.customer.customer_no
                                                            customerDB?.responsible = self.customer.responsible
                                                            customerDB?.gender = self.customer.gender
                                                            customerDB?.bloodtype = self.customer.bloodtype
                                                            customerDB?.first_daycome = self.customer.first_daycome
                                                            customerDB?.last_daycome = self.customer.last_daycome
                                                            customerDB?.update_date = self.customer.update_date
                                                            customerDB?.pic_url = self.customer.pic_url
                                                            customerDB?.birthday = self.customer.birthday
                                                            customerDB?.hobby = self.customer.hobby
                                                            customerDB?.email = self.customer.email
                                                            customerDB?.postal_code = self.customer.postal_code
                                                            customerDB?.address1 = self.customer.address1
                                                            customerDB?.address2 = self.customer.address2
                                                            customerDB?.address3 = self.customer.address3
                                                            customerDB?.mail_block = self.customer.mail_block
                                                            customerDB?.memo1 = self.customer.memo1
                                                            customerDB?.memo2 = self.customer.memo2
                                                            customerDB?.created_at = self.customer.created_at
                                                            customerDB?.updated_at = self.customer.updated_at
                                                            customerDB?.selected_status = self.customer.selected_status
                                                            customerDB?.thumb = self.customer.thumb
                                                            customerDB?.resize = self.customer.resize
                                                            customerDB?.onSecret = self.customer.onSecret
                                                            customerDB?.created_at = self.customer.created_at
                                                            customerDB?.cus_status = self.customer.cus_status
                                                        }
                                                        
                                                        self.dismiss(animated: true) {
                                                            Utils.showAlert(message: MSG_ALERT.kALERT_UPDATE_CUSTOMER_INFO_SUCCESS, view: self)
                                                            self.delegate?.didConfirm(type: 2)
                                                        }
                                                    } else {
                                                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                                    }
                                                    self.onProgress = false
                                                    self.isEdit = false
                                                    self.enableUserInput(status: false)
                                                    SVProgressHUD.dismiss()
                                                }
                                            } else {
                                                self.onProgress = false
                                            }
                                        }
                                    }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME_KANA, view: self)
                        self.onProgress = false
                        self.isEdit = false
                        enableUserInput(status: false)
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME, view: self)
                    self.onProgress = false
                    self.isEdit = false
                    enableUserInput(status: false)
                }
            }
        }
    }
    
    func onCheckCustomerIsUp2DateOrNot(cusID:Int, update:Int,completion:@escaping(Bool) -> ()) {
        APIRequest.onCheckCustomerData(cusID: cusID, update: update) { (success,cusData) in
            if success == 1 {
                completion(true)
            } else if success == 2 {
                let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "A new data of this customer has existed on the Server, Do you want to refresh to get new data?", comment: ""), message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .default, handler: nil)
                let confirm = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "OK", comment: ""), style: .default) { UIAlertAction in

                    self.customer = cusData
                    
                    let customerDB = self.realm.objects(CustomerData.self).filter("id == \(cusData.id)").first
                    try! self.realm.write {
                        customerDB?.last_name_kana = self.customer.last_name_kana
                        customerDB?.first_name_kana = self.customer.first_name_kana
                        customerDB?.last_name = self.customer.last_name
                        customerDB?.first_name = self.customer.first_name
                        customerDB?.urgent_no = self.customer.urgent_no
                        customerDB?.customer_no = self.customer.customer_no
                        customerDB?.responsible = self.customer.responsible
                        customerDB?.gender = self.customer.gender
                        customerDB?.bloodtype = self.customer.bloodtype
                        customerDB?.first_daycome = self.customer.first_daycome
                        customerDB?.last_daycome = self.customer.last_daycome
                        customerDB?.update_date = self.customer.update_date
                        customerDB?.pic_url = self.customer.pic_url
                        customerDB?.birthday = self.customer.birthday
                        customerDB?.hobby = self.customer.hobby
                        customerDB?.email = self.customer.email
                        customerDB?.postal_code = self.customer.postal_code
                        customerDB?.address1 = self.customer.address1
                        customerDB?.address2 = self.customer.address2
                        customerDB?.address3 = self.customer.address3
                        customerDB?.mail_block = self.customer.mail_block
                        customerDB?.memo1 = self.customer.memo1
                        customerDB?.memo2 = self.customer.memo2
                        customerDB?.created_at = self.customer.created_at
                        customerDB?.updated_at = self.customer.updated_at
                        customerDB?.selected_status = self.customer.selected_status
                        customerDB?.thumb = self.customer.thumb
                        customerDB?.resize = self.customer.resize
                        customerDB?.onSecret = self.customer.onSecret
                        customerDB?.created_at = self.customer.created_at
                        customerDB?.cus_status = self.customer.cus_status
                    }
                    
                    self.dismiss(animated: true) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_UPDATE_CUSTOMER_INFO_SUCCESS, view: self)
                        self.delegate?.didConfirm(type: 2)
                    }
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                completion(false)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                completion(false)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        if popupType == PopUpType.AddNew.rawValue {
            if (tfLastName.text?.count)! > 0 || (tfFirstName.text?.count)! > 0 || (tfLastNameKana.text?.count)! > 0 || (tfFirstNameKana.text?.count)! > 0 {
                
                let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: MSG_ALERT.kALERT_CANCEL_WITHOUT_SAVE, comment: ""), message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .default) { UIAlertAction in
                    //do nothing
                }
                let confirm = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "OK", comment: ""), style: .default) { UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
             dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onLockChange(_ sender: UIButton) {
        if isEdit == false {
            isEdit = true
            btnLock.isHidden = true
            enableUserInput(status: true)
            btnConfirm.isEnabled = true
            btnConfirm.alpha = 1.0
        } else {
            isEdit = false
            enableUserInput(status: false)
            btnConfirm.isEnabled = false
            btnConfirm.alpha = 0.5
        }
    }
    
    @IBAction func onCusStatusChange(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let vipS = UIAlertAction(title: "VIP", style: .default) { UIAlertAction in
            let attributedString = NSAttributedString(string: "VIP", attributes: Strokes_SET.vipS)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            self.cusStatus = 5
        }
        let repeatS = UIAlertAction(title: "リピート", style: .default) { UIAlertAction in
            let attributedString = NSAttributedString(string: "リピート", attributes: Strokes_SET.repeatS)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            self.cusStatus = 4
        }
        let trialS = UIAlertAction(title: "お試し", style: .default) { UIAlertAction in
            let attributedString = NSAttributedString(string: "お試し", attributes: Strokes_SET.trialS)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            self.cusStatus = 3
        }
        
        let troubleS = UIAlertAction(title: "問題有", style: .default) { UIAlertAction in
            let attributedString = NSAttributedString(string: "問題有", attributes: Strokes_SET.troubleS)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            self.cusStatus = 2
        }
        
        let hiddenS = UIAlertAction(title: "非表示", style: .default) { UIAlertAction in
            let attributedString = NSAttributedString(string: "非表示", attributes: Strokes_SET.hiddenS)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            self.cusStatus = 1
        }
        
        let noreg = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Unregistered", comment: ""), style: .default) { UIAlertAction in
            let attributedString = NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Unregistered", comment: ""), attributes: Strokes_SET.noreg)
            self.btnCusStatus.setAttributedTitle(attributedString, for: .normal)
            self.cusStatus = 0
        }
    
        alert.addAction(vipS)
        alert.addAction(repeatS)
        alert.addAction(trialS)
        alert.addAction(troubleS)
        alert.addAction(hiddenS)
        alert.addAction(noreg)
        
        alert.popoverPresentationController?.sourceView = self.btnCusStatus
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnCusStatus.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPreview(_ sender: UIButton) {
        
    }
    
    @IBAction func onGenderChange(_ sender: UIButton) {
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
    
    @IBAction func onBirthdayChange(_ sender: UIButton) {
        let datePicker = UIDatePicker()//Date picker
        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 5
        
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        datePicker.locale = loc
        
        if (dateString == nil) {
            dateString = "1990年 01月 01日"
        }
 
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年 MM月 dd日"
        let date = dateFormatter.date(from: dateString!)
        datePicker.setDate(date!, animated: false)
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        let timeInterval = Int(date!.timeIntervalSince1970)
        
        btnBirthday.setTitle(dateFormatter.string(from: date!), for: .normal)
        birthDate = timeInterval
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    @IBAction func onBloodTypeChange(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let bloodA = UIAlertAction(title: " A ", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle(" A ", for: .normal)
            self.bloodSelect = 1
        }
        let bloodB = UIAlertAction(title: " B ", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle(" B ", for: .normal)
            self.bloodSelect = 2
        }
        let bloodO = UIAlertAction(title: " O ", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle(" O ", for: .normal)
            self.bloodSelect = 3
        }
        let bloodAB = UIAlertAction(title: " AB ", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle(" AB ", for: .normal)
            self.bloodSelect = 4
        }
        let bloodUndefined = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), style: .default) { UIAlertAction in
            self.btnBloodType.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: ""), for: .normal)
            self.bloodSelect = 0
        }
        alert.addAction(cancel)
        alert.addAction(bloodA)
        alert.addAction(bloodB)
        alert.addAction(bloodO)
        alert.addAction(bloodAB)
        alert.addAction(bloodUndefined)
        alert.popoverPresentationController?.sourceView = self.btnBloodType
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnBloodType.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onAddPhoto(_ sender: UIButton) {
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
        
        let selectGallery = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Choose Photo from Gallery", comment: ""), style: .default) { UIAlertAction in
            let newPopup = CustomerGalleryPopupVC(nibName: "CustomerGalleryPopupVC", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 600, height: 800)
            newPopup.customer = self.customer
            newPopup.delegate = self
            newPopup.type = 2
            self.present(newPopup, animated: true, completion: nil)
        }
        
        let selectNoPhoto = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Delete Representative Image", comment: ""), style: .default) { UIAlertAction in
            guard let img = UIImage(named: "img_no_photo") else { return }
            self.imageTemp = img
            self.reloadAvatar(photo: img)
        }
        
        alert.addAction(takeNew)
        alert.addAction(selectPhoto)
        alert.addAction(selectGallery)
        alert.addAction(selectNoPhoto)
        
        alert.popoverPresentationController?.sourceView = self.btnAddPhoto
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnAddPhoto.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didCloseSecret() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onConvertAddress(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:"郵便番号から検索した住所を設定します。既に住所を入力している場合は上書きされます。", comment: ""), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .default, handler: nil)
        let confirm = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "OK", comment: ""), style: .default) { UIAlertAction in
            self.getLocationFromPostalCode(postalCode: self.tfPostalCode.text!)
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSwitchMailReceive(_ sender: UISwitch) {
        
    }
    
    @IBAction func onSecretMemoAccess(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            if popupType == PopUpType.AddNew.rawValue {
                Utils.showAlert(message: MSG_ALERT.kALERT_CREATE_CUSTOMER_FIRST_ADD_SECRET_LATER, view: self)
            } else {
                if tfSecretCode.text != "" {
                    SVProgressHUD.show(withStatus: "読み込み中")
                    SVProgressHUD.setDefaultMaskType(.clear)
                    
                    APIRequest.getAccessSecretMemo(password: tfSecretCode.text!) { (success, msg) in
                        if success {
                            let newPopup = SecretPopupVC(nibName: "SecretPopupVC", bundle: nil)
                            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                            newPopup.preferredContentSize = CGSize(width: 560, height: 450)
                            newPopup.customer = self.customer
                            newPopup.authenPass = self.tfSecretCode.text!
                            newPopup.delegate = self
                            self.present(newPopup, animated: true, completion: nil)
                        } else {
                            Utils.showAlert(message: msg, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_PASSWORD, view: self)
                }
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
    @IBAction func onStaffSelect(_ sender: UIButton) {
        staffsDropDown.show()
    }
    
    //*****************************************************************
    // MARK: - UIImagePicker Delegate
    //*****************************************************************
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let newImage = Utils.imageWithImage(sourceImage: selectedImage, scaledToWidth:768)
        
        self.dismiss(animated: true, completion: { () -> Void in
            let imgRotated = newImage.updateImageOrientionUpSide()
            
            if self.popupType == PopUpType.Edit.rawValue || self.popupType == PopUpType.Review.rawValue {
                self.imageTemp = imgRotated
            } else {
                self.imageTemp = imgRotated
            }
            self.reloadAvatar(photo: selectedImage)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - Textfield Delegate
    //*****************************************************************
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 6 || textField.tag == 7 {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil && newString.length <= 20
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //add hiragana from kanji
        switch textField.tag {
        case 1:
            tfLastNameKana.text = TextConverter.convert(tfLastName.text!, to: .hiragana)
        case 2:
            tfFirstNameKana.text = TextConverter.convert(tfFirstName.text!, to: .hiragana)
        case 3:
            tfLastNameKana.text = tfLastNameKana.text?.toHiragana()
        case 4:
            tfFirstNameKana.text = tfFirstNameKana.text?.toHiragana()
        default:
            break
        }
        
        if (tfLastName.text?.count)! > 0 && (tfFirstName.text?.count)! > 0 {
            radioName.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioName.backgroundColor = UIColor.white
        }
        if (tfLastNameKana.text?.count)! > 0 && (tfFirstNameKana.text?.count)! > 0 {
            radioNameKana.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioNameKana.backgroundColor = UIColor.white
        }
        if (tfCusNo.text?.count)! > 0 {
            radioCusNo.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioCusNo.backgroundColor = UIColor.white
        }
        if (tfEmergency.text?.count)! > 0 {
            radioEmergency.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioEmergency.backgroundColor = UIColor.white
        }
        if btnStaff.titleLabel?.text != "未登録" {
            radioResponsible.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioResponsible.backgroundColor = UIColor.white
        }
        
        //check email validation
        if (tfMail.text?.count)! > 0 {
            
            switch Utils.isValidEmail(email: tfMail.text!) {
            case true:
                print("Mail is valid")
            case false:
                Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_EMAIL, view: self)
            }
        }
        
        if (tfEmergency.text?.count)! > 0 {
            let isPhone = tfEmergency.text?.isPhoneNumber
        
            if isPhone == true {
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_PHONE, view: self)
            }
        }
    }
}

//*****************************************************************
// MARK: - CustomerGalleryPopupVC Delegate
//*****************************************************************

extension RegCustomerPopup: CustomerGalleryPopupVCDelegate {
    
    func onSelectImage(image: UIImage) {
        self.imageTemp = image
        self.reloadAvatar(photo: image)
    }
}
