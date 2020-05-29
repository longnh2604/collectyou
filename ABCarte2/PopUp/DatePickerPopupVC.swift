//
//  DatePickerPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/28.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

@objc protocol DatePickerPopupVCDelegate: class {
    @objc optional func onRegisterDate(date:Date,index:Int)
    @objc optional func onRegisterDateLocation(date:Date,loc:Int)
    @objc optional func onRegisterDateOnly(date:Date)
    @objc optional func onRegisterBirthDate(date:Date)
}

class DatePickerPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var onRegister: RoundButton!
    @IBOutlet weak var onCancel: RoundButton!
    
    //Variable
    var daySelected: Date? = nil
    var cellIndex: Int?
    weak var delegate:DatePickerPopupVCDelegate?
    var position: Int?
    var type: Int?
    
    deinit {
        print("Release memory")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //change to Japanese style
        let loc = Locale(identifier: "ja")
        datePicker.locale = loc
        if daySelected == nil {
            daySelected = Date()
        } else {
            datePicker.date = daySelected!
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onDateChange(_ sender: UIDatePicker) {
        daySelected = datePicker.date
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        dismiss(animated: true) {
            if self.type == 1 {
                if let date = self.daySelected {
                    self.delegate?.onRegisterDateLocation?(date: date, loc: self.position!)
                }
            } else if self.type == 2 {
                if let date = self.daySelected {
                    self.delegate?.onRegisterDateOnly?(date: date)
                }
            } else if self.type == 3 {
                if let date = self.daySelected {
                    self.delegate?.onRegisterBirthDate?(date: date)
                }
            } else {
                if let date = self.daySelected,let index = self.cellIndex {
                    self.delegate?.onRegisterDate?(date: date,index:index)
                }
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
