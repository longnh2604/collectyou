//
//  ContractConfirmVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/28.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContractConfirmVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfCusAddress: UITextField!
    @IBOutlet weak var tfWorkAddress: UITextField!
    @IBOutlet weak var tfCusPostCode1: UITextField!
    @IBOutlet weak var tfCusPostCode2: UITextField!
    @IBOutlet weak var tfWorkPostCode1: UITextField!
    @IBOutlet weak var tfWorkPostCode2: UITextField!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnBirthday: UIButton!
    
    //Variable
    var customer = CustomerData()
    let yearArr = ["2010",
                "2011",
                "2012",
                "2013",
                "2014",
                "2015",
                "2016",
                "2017",
                "2018",
                "2019",
                "2020",
                "2021",
                "2022",
                "2023",
                "2024",
                "2025",
                "2026",
                "2027",
                "2028",
                "2029",
                "2030"]
    let monthArr = ["1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7",
                    "8",
                    "9",
                    "10",
                    "11",
                    "12"]
    let dayArr = ["1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7",
                    "8",
                    "9",
                    "10",
                    "11",
                    "12",
                    "13",
                    "14",
                    "15",
                    "16",
                    "17",
                    "18",
                    "19",
                    "20",
                    "21",
                    "22",
                    "23",
                    "24",
                    "25",
                    "26",
                    "27",
                    "28",
                    "29",
                    "30",
                    "31"]
    let yearDropDown = DropDown()
    let monthDropDown = DropDown()
    let dayDropDown = DropDown()
    var currentY : Int?
    var currentM : Int?
    var currentD : Int?
    var dateString : String?
    var birthDate: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupDropDowns()
    }

    fileprivate func setupLayout() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "確認画面へ", style: .plain, target: self, action: #selector(onConfirm))
    }
    
    private func setupDropDowns() {
        let currDate = Date()
        let calendar = Calendar.current
        currentY = calendar.component(.year, from: currDate)
        currentM = calendar.component(.month, from: currDate)
        currentD = calendar.component(.day, from: currDate)
        //year
        yearDropDown.anchorView = btnYear
        yearDropDown.bottomOffset = CGPoint(x: 0, y: btnYear.bounds.height)
        yearDropDown.dataSource = yearArr
        //select current year
        for i in 0 ..< yearDropDown.dataSource.count {
            if yearDropDown.dataSource[i].contains(String(self.currentY!)) {
                yearDropDown.selectRow(i, scrollPosition: .middle)
            }
        }
        
        yearDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnYear.setTitle(item, for: .normal)
            self?.currentY = Int(item)
        }
        
        //year
        monthDropDown.anchorView = btnMonth
        monthDropDown.bottomOffset = CGPoint(x: 0, y: btnMonth.bounds.height)
        monthDropDown.dataSource = monthArr
        //select current year
        for i in 0 ..< monthDropDown.dataSource.count {
            if monthDropDown.dataSource[i].contains(String(self.currentM!)) {
                monthDropDown.selectRow(i, scrollPosition: .middle)
            }
        }
        
        monthDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnMonth.setTitle(item, for: .normal)
            self?.currentM = Int(item)
        }
        
        //year
        dayDropDown.anchorView = btnDay
        dayDropDown.bottomOffset = CGPoint(x: 0, y: btnDay.bounds.height)
        dayDropDown.dataSource = dayArr
        //select current year
        for i in 0 ..< dayDropDown.dataSource.count {
            if dayDropDown.dataSource[i].contains(String(self.currentD!)) {
                dayDropDown.selectRow(i, scrollPosition: .middle)
            }
        }
        
        dayDropDown.selectionAction = { [weak self] (index, item) in
            self?.btnDay.setTitle(item, for: .normal)
            self?.currentD = Int(item)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func onConfirm(sender: UIBarButtonItem) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"CustomerSignVC") as? CustomerSignVC {
            
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        birthDate = Int(datePicker.date.timeIntervalSince1970)
        btnBirthday.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
        dateString = dateFormatter.string(from: datePicker.date)
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
            let posCode = tfCusPostCode1.text! + "" + tfCusPostCode2.text!
            getLocationFromPostalCode(postalCode: posCode, location: sender.tag)
        case 2:
            let posCode = tfWorkPostCode1.text! + "" + tfWorkPostCode2.text!
            getLocationFromPostalCode(postalCode: posCode, location: sender.tag)
        default:
            break
        }
    }
    
    @IBAction func onSelectDate(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            yearDropDown.show()
        case 2:
            monthDropDown.show()
        case 3:
            dayDropDown.show()
        default:
            break
        }
    }
    
    @IBAction func onBirthdateSelect(_ sender: UIButton) {
        let datePicker = UIDatePicker()//Date picker
               datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
               datePicker.datePickerMode = .date
               datePicker.minuteInterval = 5
               
               //change to Japanese style
               let loc = Locale(identifier: "ja")
               datePicker.locale = loc
               
               if (dateString == nil) {
                   dateString = "1990年01月01日"
               }
        
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy年MM月dd日"
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
}
