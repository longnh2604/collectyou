//
//  AddCartePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/04.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objc protocol AddCartePopupVCDelegate: class {
    @objc optional func onAddNewCarte(time:Int,staff_name:String,bed_name:String)
    @objc optional func onUpdateCarte(carteID:Int,time:Int,staff_name:String,bed_name:String)
}

class AddCartePopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblTitle: RoundLabel!
    @IBOutlet weak var lblCurrDate: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var btnRepresentative: RoundButton!
    @IBOutlet weak var btnBedNo: RoundButton!
    @IBOutlet weak var viewStaff: RoundUIView!
    @IBOutlet weak var viewBed: RoundUIView!
    
    //Variable
    var carte: CarteData?
    weak var delegate:AddCartePopupVCDelegate?
    var daySelected: Date?
    let staffDropMenu = DropDown()
    var staffs: Results<StaffData>!
    let bedsDropMenu = DropDown()
    var beds: Results<BedData>!
    var dateString = ""
    var timeString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    fileprivate func setupLayout() {
        viewPopup.layer.cornerRadius = 10
        viewPopup.clipsToBounds = true
        
        datePicker.layer.borderColor = UIColor.lightGray.cgColor
        datePicker.layer.borderWidth = 1
        timePicker.layer.borderColor = UIColor.lightGray.cgColor
        timePicker.layer.borderWidth = 1
        
        //check if edit carte or not
        if (carte != nil) {
            if let staff_name = carte?.staff_name,let bed_name = carte?.bed_name,let time = carte?.select_date {
                if staff_name == "" {
                    btnRepresentative.setTitle("氏名を選択", for: .normal)
                } else {
                    btnRepresentative.setTitle(staff_name, for: .normal)
                }
                
                if bed_name == "" {
                    btnBedNo.setTitle("番号を選択", for: .normal)
                } else {
                    btnBedNo.setTitle(bed_name, for: .normal)
                }
                
                let date = Date(timeIntervalSince1970: TimeInterval(time))
                datePicker.setDate(date, animated: false)
                timePicker.setDate(date, animated: false)
                convertDateTime()

                datePicker.isUserInteractionEnabled = false
                datePicker.alpha = 0.5
                lblTitle.text = "作成したカルテの設定"
            }
        } else {
            //get current Date
            convertDateTime()
        }
        checkCondition()
    }
    
    private func checkCondition() {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteTime.rawValue) {
            timePicker.isHidden = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kBedManagement.rawValue) {
            viewBed.isHidden = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kStaffManagement.rawValue) {
            viewStaff.isHidden = false
        }
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetAllStaffBasedOnPermission(permission: StaffPermission.karte.rawValue, completion: { (success) in
            if success {
                self.setupStaffList()
                APIRequest.onGetAllBed { (success) in
                    if success {
                        self.setupBedList()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                SVProgressHUD.dismiss()
            }
        })
    }
    
    private func setupStaffList() {
        staffDropMenu.anchorView = btnRepresentative
        staffDropMenu.bottomOffset = CGPoint(x: 0, y: btnRepresentative.bounds.height)

        let realm = RealmServices.shared.realm
        self.staffs = realm.objects(StaffData.self)

        var staffName : [String] = []
        staffName.append("未選択")
        for i in 0 ..< staffs.count {
            staffName.append(staffs[i].staff_name)
        }

        staffDropMenu.dataSource = staffName
        staffDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnRepresentative.setTitle(item, for: .normal)
        }
    }
    
    private func setupBedList() {
        bedsDropMenu.anchorView = btnBedNo
        bedsDropMenu.bottomOffset = CGPoint(x: 0, y: btnBedNo.bounds.height)

        let realm = RealmServices.shared.realm
        self.beds = realm.objects(BedData.self)

        var bedName : [String] = []
        bedName.append("未選択")
        for i in 0 ..< beds.count {
            bedName.append(beds[i].bed_name)
        }

        bedsDropMenu.dataSource = bedName
        bedsDropMenu.selectionAction = { [weak self] (index, item) in
            self?.btnBedNo.setTitle(item, for: .normal)
        }
    }
    
    fileprivate func convertDateTime() {
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "yyyy年MM月dd日"
        let dayTimeDateFormatter = DateFormatter()
        dayTimeDateFormatter.dateFormat = "HH時mm分"
        
        let strDate = dayDateFormatter.string(from: datePicker.date)
        let strTime = dayTimeDateFormatter.string(from: timePicker.date)
        let strWeek = "\(Utils.getDayOfWeek(strDate) ?? "")"
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteTime.rawValue) {
            lblCurrDate.text = strDate + strWeek + strTime
        } else {
            lblCurrDate.text = strDate + strWeek
        }
        
        let dayDateTimeFullFormatter = DateFormatter()
        dayDateTimeFullFormatter.dateFormat = "yyyy年MM月dd日HH時mm分"
        daySelected = dayDateTimeFullFormatter.date(from: strDate + strTime)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onConfirm(_ sender: UIButton) {
        //check condition
        if let representative = btnRepresentative.titleLabel?.text,let bedno = btnBedNo.titleLabel?.text {
            dismiss(animated: true) {
                if (self.carte != nil) {
                    self.delegate?.onUpdateCarte?(carteID:self.carte!.id,time: Int(self.daySelected!.timeIntervalSince1970), staff_name: representative, bed_name: bedno)
                } else {
                    self.delegate?.onAddNewCarte?(time: Int(self.daySelected!.timeIntervalSince1970), staff_name: representative, bed_name: bedno)
                }
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDateValueChange(_ sender: UIDatePicker) {
        convertDateTime()
    }
    
    @IBAction func onTimeValueChange(_ sender: UIDatePicker) {
        convertDateTime()
    }
    
    @IBAction func onSelectRepresentative(_ sender: UIButton) {
        staffDropMenu.show()
    }
    
    @IBAction func onBedNoSelect(_ sender: UIButton) {
        bedsDropMenu.show()
    }
}
