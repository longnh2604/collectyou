//
//  OtherInfoVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/31.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class OtherInfoVC: UIViewController, UITextFieldDelegate {

    //IBOutlet
    @IBOutlet weak var btnCompanyName: UIButton!
    @IBOutlet weak var lblCompanyPresident: UILabel!
    @IBOutlet weak var lblCompanyPostCode: UILabel!
    @IBOutlet weak var lblCompanyAddress: UILabel!
    @IBOutlet weak var lblCompanyPhone: UILabel!
    @IBOutlet weak var btnSubCompanyName: UIButton!
    @IBOutlet weak var lblSubCompanyPresident: UILabel!
    @IBOutlet weak var lblSubCompanyPostCode: UILabel!
    @IBOutlet weak var lblSubCompanyAddress: UILabel!
    @IBOutlet weak var lblSubCompanyPhone: UILabel!
    @IBOutlet weak var tfBeginCourseFee: UITextField!
    @IBOutlet weak var tfUsageFeeCharge1: UITextField!
    @IBOutlet weak var tfUsageFeeCharge2: UITextField!
    @IBOutlet weak var tfAdditionNote: UITextField!
    @IBOutlet weak var btnRepresentative: UIButton!
    @IBOutlet weak var btnOption1: UIButton!
    @IBOutlet weak var btnOption2: UIButton!
    @IBOutlet weak var btnSaveDetails: UIButton!
    @IBOutlet weak var tfCusNote: UITextField!
    
    //Variable
    var brochure = BrochureData()
    var companies: Results<CompanyData>!
    var companiesData : [CompanyData] = []
    var comData = CompanyData()
    let subcomData = CompanyData()
    var staffs: Results<StaffData>!
    var staffsData : [StaffData] = []
    var additions: Results<AdditionNoteData>!
    var additionsData : [AdditionNoteData] = []
    let companyDropMenu = DropDown()
    let subcompanyDropMenu = DropDown()
    let representativeDropMenu = DropDown()
    var companyStamp: String?
    lazy var realm = try! Realm()
    let maxLength = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    fileprivate func setupLayout() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "確認画面へ", style: .plain, target: self, action: #selector(onConfirm))
        
        btnOption1.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
        btnOption2.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        
        tfBeginCourseFee.delegate = self
        tfUsageFeeCharge1.delegate = self
        tfUsageFeeCharge2.delegate = self
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetCompanyInfo(accID: brochure.account_id) { (success) in
            if success {
                self.companies = self.realm.objects(CompanyData.self)
                self.companiesData.removeAll()
                
                for i in 0 ..< self.companies.count {
                    self.companiesData.append(self.companies[i])
                }
                self.setupCompanyDropDown()
                APIRequest.onGetAdditionalInfo(accountID: self.brochure.account_id) { (success) in
                    if success {
                        self.additions = self.realm.objects(AdditionNoteData.self)
                        self.setupAdditionNote()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    }
                }
                SVProgressHUD.dismiss()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func setupAdditionNote() {
        if additions.count > 0 {
            tfBeginCourseFee.text = String(additions[0].advance_pay).addFormatAmount()
            tfUsageFeeCharge1.text = additions[0].used_item.addFormatAmount()
            tfUsageFeeCharge2.text = additions[0].used_item2.addFormatAmount()
            tfAdditionNote.text = additions[0].conserva
        }
    }
    
    private func onFetchingOtherInfoData(completion:@escaping(Bool) -> ()) {
        comData.company_name = btnCompanyName.titleLabel!.text!
        comData.president_name = lblCompanyPresident.text!
        comData.zip = lblCompanyPostCode.text!
        comData.address1 = lblCompanyAddress.text!
        comData.tel = lblCompanyPhone.text!
        
        if let comStamp = companyStamp {
            comData.stamp = comStamp
        }
        
        subcomData.company_name = btnSubCompanyName.titleLabel!.text!
        subcomData.president_name = lblSubCompanyPresident.text!
        subcomData.zip = lblSubCompanyPostCode.text!
        subcomData.address1 = lblSubCompanyAddress.text!
        subcomData.tel = lblSubCompanyPhone.text!
        brochure.contract_staff = btnRepresentative.titleLabel!.text!
        
        brochure.advance_pay = tfBeginCourseFee.text!.removeFormatAmount()
        brochure.used_item = tfUsageFeeCharge1.text!
        brochure.used_item2 = tfUsageFeeCharge2.text!
        brochure.note1 = tfCusNote.text!
        
        if btnOption1.currentImage == UIImage(named:"icon_radio_check_button.png") {
            if tfAdditionNote.text == "" {
                Utils.showAlert(message: "前受金保全措置内容を記入してください。", view: self)
                completion(false)
            } else {
                brochure.conserva = tfAdditionNote.text!
                completion(true)
            }
        } else {
            brochure.conserva = ""
            completion(true)
        }
    }
    
    private func setupCompanyDropDown() {
        companyDropMenu.anchorView = btnCompanyName
        companyDropMenu.bottomOffset = CGPoint(x: 0, y: btnCompanyName.bounds.height)
        var compN : [String] = []
        for i in 0 ..< companies.count {
            compN.append(companies[i].company_name)
        }
        companyDropMenu.dataSource = compN
        companyDropMenu.selectionAction = { [weak self] (index, item) in
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            self?.btnCompanyName.setTitle(item, for: .normal)
            self?.lblCompanyPresident.text = self?.companiesData[index].president_name
            self?.lblCompanyAddress.text = "\(self?.companiesData[index].address1 ?? "") \(self?.companiesData[index].address2 ?? "")"
            self?.lblCompanyPhone.text = self?.companiesData[index].tel
            self?.lblCompanyPostCode.text = self?.companiesData[index].zip
            self?.companyStamp = self?.companiesData[index].stamp
            //add comp ID
            self?.comData.id = self?.companiesData[index].id ?? 0
            
            APIRequest.onGetStaffBasedOnPermissionAndCompany(companyID: self!.companies[index].id,permission: StaffPermission.brochure.rawValue) { (success) in
                 if success {
                    self!.setupRepresentative()
                } else {
                    Utils.showAlert(message: "Can not get Staff Info", view: self!)
                }
                SVProgressHUD.dismiss()
            }
        }
        
        subcompanyDropMenu.anchorView = btnSubCompanyName
        subcompanyDropMenu.bottomOffset = CGPoint(x: 0, y: btnSubCompanyName.bounds.height)
        subcompanyDropMenu.dataSource = compN
        subcompanyDropMenu.selectionAction = { [weak self] (index, item) in
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
          
            self?.btnSubCompanyName.setTitle(item, for: .normal)
            self?.btnRepresentative.setTitle("担当者を選択", for: .normal)
            self?.lblSubCompanyPresident.text = self?.companiesData[index].president_name
            self?.lblSubCompanyAddress.text = "\(self?.companiesData[index].address1 ?? "") \(self?.companiesData[index].address2 ?? "")"
            self?.lblSubCompanyPhone.text = self?.companiesData[index].tel
            self?.lblSubCompanyPostCode.text = self?.companiesData[index].zip
            
            //add comp ID
            self?.subcomData.id = self?.companiesData[index].id ?? 0
            
            APIRequest.onGetStaffBasedOnPermissionAndCompany(companyID: self!.companies[index].id,permission: StaffPermission.brochure.rawValue) { (success) in
                if success {
                    self!.setupRepresentative()
                } else {
                    Utils.showAlert(message: "Can not get Staff Info", view: self!)
                }
                SVProgressHUD.dismiss()
            }
        }
        
        if companiesData.count > 0 {
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            companyDropMenu.selectRow(0)
            self.lblCompanyPresident.text = self.companiesData[0].president_name
            self.lblCompanyAddress.text = "\(self.companiesData[0].address1) \(self.companiesData[0].address2)"
            self.lblCompanyPhone.text = self.companiesData[0].tel
            self.lblCompanyPostCode.text = self.companiesData[0].zip
            self.companyStamp = self.companiesData[0].stamp
            //add comp ID
            self.comData.id = self.companiesData[0].id
            
            subcompanyDropMenu.selectRow(0)
            self.lblSubCompanyPresident.text = self.companiesData[0].president_name
            self.lblSubCompanyAddress.text = "\(self.companiesData[0].address1) \(self.companiesData[0].address2)"
            self.lblSubCompanyPhone.text = self.companiesData[0].tel
            self.lblSubCompanyPostCode.text = self.companiesData[0].zip
            //add comp ID
            self.subcomData.id = self.companiesData[0].id
            
            self.btnCompanyName.setTitle(compN[0], for: .normal)
            self.btnSubCompanyName.setTitle(compN[0], for: .normal)
            
            APIRequest.onGetStaffBasedOnPermissionAndCompany(companyID: self.companiesData[0].id,permission: StaffPermission.brochure.rawValue) { (success) in
                if success {
                    self.setupRepresentative()
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func setupRepresentative() {
        representativeDropMenu.anchorView = btnRepresentative
        representativeDropMenu.bottomOffset = CGPoint(x: 0, y: btnRepresentative.bounds.height)
        var staff : [String] = []
        let realm = RealmServices.shared.realm
        self.staffs = realm.objects(StaffData.self)
        
        for i in 0 ..< staffs.count {
            staff.append(staffs[i].staff_name)
        }
        representativeDropMenu.dataSource = staff
        representativeDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnRepresentative.setTitle(item, for: .normal)
        }
        
    }
    
    @objc func onConfirm() {
        if let text = btnRepresentative.titleLabel?.text {
            if text == "担当者を選択" {
                Utils.showAlert(message: "担当者名を選択して下さい", view: self)
                return
            }
        }
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "BrochureConfirmWithoutSignVC") as? BrochureConfirmWithoutSignVC {
            self.onFetchingOtherInfoData { (success) in
                if success {
                    viewController.brochure = self.brochure
                    viewController.company = self.comData
                    viewController.subcompany = self.subcomData
                    if let navigator = self.navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
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

    @IBAction func onCompanyNameSelect(_ sender: UIButton) {
        companyDropMenu.show()
    }
    
    @IBAction func onSubCompanyNameSelect(_ sender: Any) {
        subcompanyDropMenu.show()
    }
    
    @IBAction func onSubCompanyRepresentativeSelect(_ sender: Any) {
        representativeDropMenu.show()
    }
    
    @IBAction func onSaveAddition(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnOption2.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        case 2:
            sender.setImage(UIImage(named:"icon_radio_check_button.png" ), for: .normal)
            btnOption1.setImage(UIImage(named:"icon_radio_uncheck_button.png" ), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func onTextFieldChange(_ sender: UITextField) {
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
        }
    }
    
    @IBAction func onSaveDetail(_ sender: UIButton) {
        
        guard let advance = tfBeginCourseFee.text,let used_item = tfUsageFeeCharge1.text, let used_item2 = tfUsageFeeCharge2.text, let conserva = tfAdditionNote.text else { return }
        
        if conserva == "" {
            let alert = UIAlertController(title: "「前受金保全措置が設定されていません。【行っていません。】に変更しますか？」", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                self.btnOption1.setImage(UIImage(named: "icon_radio_uncheck_button.png"), for: .normal)
                self.btnOption2.setImage(UIImage(named: "icon_radio_check_button.png"), for: .normal)
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let additionalData = AdditionNoteData()
        additionalData.advance_pay = Int(advance.removeFormatAmount())
        additionalData.used_item = String(used_item.removeFormatAmount())
        additionalData.used_item2 = String(used_item2.removeFormatAmount())
        additionalData.conserva = conserva
        
        if additions.count > 0 {
            additionalData.id = additions[0].id
            
            APIRequest.onUpdateAdditionalInfo(additonalData: additionalData) { (success) in
                if success {
                    Utils.showAlert(message: "内容の保存しました。", view: self)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
            additionalData.account_id = accountID
            
            APIRequest.onAddAdditionalInfo(additonalData: additionalData) { (success) in
                if success {
                    self.additions = self.realm.objects(AdditionNoteData.self)
                    Utils.showAlert(message: "内容の保存しました。", view: self)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
}
