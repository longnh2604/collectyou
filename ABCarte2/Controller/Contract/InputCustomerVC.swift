//
//  InputCustomerVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/31.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UXMPDFKit
import RealmSwift

class InputCustomerVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfCusAddress: UITextField!
    @IBOutlet weak var tfWorkAddress: UITextField!
    @IBOutlet weak var tfCusPost: UITextField!
    @IBOutlet weak var tfWorkPostCode: UITextField!
    @IBOutlet weak var btnContractDay: UIButton!
    @IBOutlet weak var btnBirthday: UIButton!
    @IBOutlet weak var tfCusNameFurigana: UITextField!
    @IBOutlet weak var tfCusName: UITextField!
    @IBOutlet weak var tfCusCode: UITextField!
    @IBOutlet weak var btnJob: UIButton!
    @IBOutlet weak var tfWorkplaceName: UITextField!
    @IBOutlet weak var tfCusPhone: UITextField!
    @IBOutlet weak var btnRepresentative: UIButton!
    
    //Variable
    var customer = CustomerData()
    var dateString : String?
    var brochure = BrochureData()
    var jobs: Results<JobData>!
    var jobsData : [JobData] = []
    let jobsDropDown = DropDown()
    var staffs: Results<StaffData>!
    var staffsData : [StaffData] = []
    let staffsDropDown = DropDown()
    
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
        
        tfCusCode.text = customer.customer_no
        tfCusNameFurigana.text = customer.last_name_kana + customer.first_name_kana
        tfCusName.text = customer.last_name + customer.first_name
        tfCusAddress.text = customer.address1 + customer.address2 + customer.address3
        tfCusPost.text = customer.postal_code
        tfCusPhone.text = customer.urgent_no
        
        if customer.responsible != "" {
            btnRepresentative.setTitle("\(customer.responsible)", for: .normal)
        } else {
            btnRepresentative.setTitle("未登録", for: .normal)
        }
        
        if customer.birthday != 0 {
            btnBirthday.setTitle(Utils.convertUnixTimestamp(time: customer.birthday), for: .normal)
            dateString = Utils.convertUnixTimestamp(time: customer.birthday)
        }
        
        let currDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        btnContractDay.setTitle(dateFormatter.string(from: currDate), for: .normal)
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = RealmServices.shared.realm
       
        APIRequest.onGetJobInfo { (success) in
            if success {
                self.jobs = realm.objects(JobData.self).sorted(byKeyPath: "display_num")
                self.setupJobDropDown()
                APIRequest.onGetAllStaffBasedOnPermission(permission: StaffPermission.contract.rawValue, completion: { (success) in
                    if success {
                        self.staffs = realm.objects(StaffData.self)
                        self.setupStaffDropDown()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    }
                    SVProgressHUD.dismiss()
                })
            } else {
                SVProgressHUD.dismiss()
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
        }
    }
    
    fileprivate func setupJobDropDown() {
        jobsDropDown.anchorView = btnJob
        jobsDropDown.bottomOffset = CGPoint(x: 0, y: btnJob.bounds.height)
        var jobN : [String] = []
        for i in 0 ..< jobs.count {
            jobN.append(jobs[i].job)
        }
        jobsDropDown.dataSource = jobN
        jobsDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnJob.setTitle(item, for: .normal)
        }
    }
    
    fileprivate func setupStaffDropDown() {
        staffsDropDown.anchorView = btnRepresentative
        staffsDropDown.bottomOffset = CGPoint(x: 0, y: btnRepresentative.bounds.height)
        var jobN : [String] = []
        for i in 0 ..< staffs.count {
            jobN.append(staffs[i].staff_name)
        }
        staffsDropDown.dataSource = jobN
        staffsDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnRepresentative.setTitle(item, for: .normal)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func onConfirm(sender: UIBarButtonItem) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let newContract = ContractCustomerData()
        if let contractDate = dateFormatter.date(from: btnContractDay.titleLabel!.text!)?.timeIntervalSince1970 {
            newContract.contract_date = Int(contractDate)
        } else {
            newContract.contract_date = 0
        }
        newContract.last_name = customer.last_name
        newContract.first_name = customer.first_name
        newContract.last_name_kana = customer.last_name_kana
        newContract.first_name_kana = customer.first_name_kana
        
        if let job = btnJob.titleLabel?.text {
            if job != "勤務を選択" {
                newContract.job = job
            } else {
                newContract.job = ""
            }
        }
        
        if let birthDate = dateFormatter.date(from: btnBirthday.titleLabel!.text!)?.timeIntervalSince1970 {
            newContract.birthday = Int(birthDate)
        } else {
            newContract.birthday = 0
        }
        newContract.customer_no = customer.customer_no
        if let zip = tfCusPost.text {
            newContract.zip = zip
        }
        if let add = tfCusAddress.text {
            newContract.address1 = add
        }
        if let tel = tfCusPhone.text {
            newContract.tel = tel
        }
        if let job = tfWorkplaceName.text {
            newContract.company_name = job
        }
        if let cozip = tfWorkPostCode.text {
            newContract.company_zip = cozip
        }
        if let coadd = tfWorkAddress.text {
            newContract.company_address1 = coadd
        }
        
        if let rep = btnRepresentative.titleLabel?.text {
            if rep != "未登録" {
                newContract.contract_representative = rep
            } else {
                newContract.contract_representative = ""
            }
        }

        APIRequest.onUpdateBrochureData(brochure: brochure) { (success) in
            if success {
                APIRequest.onAddContractCustomer(brochureID: self.brochure.id, contractCus: newContract) { (success,contractid) in
                    if success {
                        APIRequest.onGetContractWithoutSign(brochureID: self.brochure.id) { (success, url) in
                            if success {
                                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContractConfirmWithoutSignVC") as? ContractConfirmWithoutSignVC {
                                    viewController.url = url
                                    viewController.contractID = contractid
                                    viewController.brochure.id = self.brochure.id
                                    if let navigator = self.navigationController {
                                        navigator.pushViewController(viewController, animated: true)
                                    }
                                }
                            } else {
                                Utils.showAlert(message: "契約書の鵜読み込むに失敗しました。", view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        Utils.showAlert(message: "顧客情報の追加に失敗しました。", view: self)
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                Utils.showAlert(message: "契約の更新に失敗しました。", view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    fileprivate func getLocationFromPostalCode(postalCode : String,location: Int){
        
        let url = "https://api.zipaddress.net/?zipcode=\(postalCode)"
            
        Alamofire.request(url, method: .get, parameters: nil, encoding:  JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                let code = json["code"]
                if code == 200 {
                    if location == 1 {
                        self.tfCusAddress.text = json["data"]["fullAddress"].stringValue
                    } else {
                        self.tfWorkAddress.text = json["data"]["fullAddress"].stringValue
                    }
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
    
    @IBAction func onConvertPostCode(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let posCode = tfCusPost.text!
            getLocationFromPostalCode(postalCode: posCode, location: sender.tag)
        case 2:
            let posCode = tfWorkPostCode.text!
            getLocationFromPostalCode(postalCode: posCode, location: sender.tag)
        default:
            break
        }
    }
    
    @IBAction func onContractDateSelect(_ sender: UIButton) {
        guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 450, height: 300)
        newPopup.delegate = self
        newPopup.position = sender.tag
        newPopup.type = 2
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onBirthdateSelect(_ sender: UIButton) {
        guard let newPopup = DatePickerPopupVC(nibName: "DatePickerPopupVC", bundle: nil) as DatePickerPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 450, height: 300)
        newPopup.delegate = self
        newPopup.position = sender.tag
        newPopup.type = 3
        
        if (dateString == nil) {
           dateString = "1990年01月01日"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let date = dateFormatter.date(from: dateString!)
        newPopup.daySelected = date
        self.present(newPopup, animated: true, completion: nil)
    }

    @IBAction func onSelectJob(_ sender: UIButton) {
        jobsDropDown.show()
    }
    
    @IBAction func onSelectRepresentative(_ sender: UIButton) {
        staffsDropDown.show()
    }
}

extension InputCustomerVC: DatePickerPopupVCDelegate {
    func onRegisterDateOnly(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let contractD = dateFormatter.string(from: date)
        btnContractDay.setTitle(contractD, for: .normal)
    }
    
    func onRegisterBirthDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let birthdate = dateFormatter.string(from: date)
        dateString = birthdate
        btnBirthday.setTitle(birthdate, for: .normal)
    }
}
