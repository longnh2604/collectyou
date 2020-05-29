//
//  AddContractPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/04.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol AddContractPopupVCDelegate: class {
    func didAddContract(time:Int)
}

class AddContractPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblTitle: RoundLabel!
    @IBOutlet weak var lblCurrDate: UILabel!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var viewPopup: UIView!
    
    //Variable
    weak var delegate:AddContractPopupVCDelegate?
    var daySelected: Date? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        viewPopup.layer.cornerRadius = 10
        viewPopup.clipsToBounds = true
        
        convertDateTime()
        
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        dateTimePicker.locale = loc
    }
    
    private func convertDateTime() {
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let strDate = dayDateFormatter.string(from: dateTimePicker.date)
        let strWeek = "\(Utils.getDayOfWeek(strDate) ?? "")"
        lblCurrDate.text = strDate + strWeek
        
        daySelected = dayDateFormatter.date(from: strDate)
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onConfirm(_ sender: UIButton) {
        if daySelected != nil {
            let time = Int((daySelected?.timeIntervalSince1970)!)
            delegate?.didAddContract(time: time)
        } else {
            let time = Date()
            delegate?.didAddContract(time: Int(time.timeIntervalSince1970))
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDateTimeSelect(_ sender: UIDatePicker) {
        convertDateTime()
    }
}
