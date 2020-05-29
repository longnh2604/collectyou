//
//  BedPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/15.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

@objc protocol BedPopupVCDelegate: class {
    @objc optional func onRefreshData()
    @objc optional func onDeleteIndex(index:Int)
}

class BedPopupVC: UIViewController,UITextFieldDelegate {

    //IBOutlet
    @IBOutlet weak var tfBedInfo: UITextField!
    @IBOutlet weak var tfBedOrder: UITextField!
    @IBOutlet weak var tvBedNote: UITextView!
    @IBOutlet weak var btnDelete: UIButton!
    
    //Variable
    weak var delegate:BedPopupVCDelegate?
    var bed: BedData?
    var totalBed = 0
    var accountID: Int?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    private func setupLayout() {
        tvBedNote.layer.borderWidth = 2
        tvBedNote.layer.cornerRadius = 5
        
        tfBedOrder.delegate = self
        tfBedOrder.text = "\(totalBed + 1)"
        
        guard let bed = bed else { return }
        tfBedInfo.text = bed.bed_name
        tfBedOrder.text = "\(bed.display_num)"
        tvBedNote.text = bed.note
        
        //unable staff order
        tfBedOrder.isUserInteractionEnabled = false
        btnDelete.isHidden = false
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
    
    @IBAction func onRegister(_ sender: UIButton) {
        if tfBedInfo.text == "" {
            Utils.showAlert(message: "先に設備番号を記入してください。", view: self)
            return
        }
        if tfBedOrder.text == "" {
            Utils.showAlert(message: "設備順番を記入してください。", view: self)
            return
        }
        
        dismiss(animated: true) {
            let bedData = BedData()
            bedData.bed_name = self.tfBedInfo.text!
            bedData.display_num = Int(self.tfBedOrder.text!)!
            bedData.note = self.tvBedNote.text
            //check add new or update
            if (self.bed != nil) {
                guard let bedID = self.bed?.id else { return }
                bedData.id = bedID
                SVProgressHUD.show(withStatus: "読み込み中")
                APIRequest.onUpdateBed(bed: bedData) { (success) in
                    if success {
                        self.dismiss(animated: true) {
                            self.delegate?.onRefreshData?()
                        }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                guard let accountID = self.accountID else { return }
                SVProgressHUD.show(withStatus: "読み込み中")
                APIRequest.onAddNewBed(accID:accountID,bed: bedData, completion: { (status) in
                    if status == 1 {
                        self.dismiss(animated: true) {
                            self.delegate?.onRefreshData?()
                        }
                    } else if status == 2 {
                        Utils.showAlert(message: "同じベッドの順番がありますので他の順番を記入してください。", view: self)
                        self.dismiss(animated: true) {
                            self.delegate?.onRefreshData?()
                        }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                        SVProgressHUD.dismiss()
                    }
                })
            }
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        let alert = UIAlertController(title: "選択している設備を削除しますか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            guard let bed = self.bed else { return }
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onDeleteBed(bedID: bed.id) { (success) in
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
