//
//  SecretMemoSettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class SecretMemoSettingPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfCurrPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCurrentP: UILabel!
    @IBOutlet weak var lblNewP: UILabel!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        localizeLanguage()
    }
    
    fileprivate func localizeLanguage() {
        lblTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Secret Memo Password", comment: "")
        btnSave.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Save",comment: ""), for: .normal)
        btnCancel.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel",comment: ""), for: .normal)
        lblCurrentP.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Current Password", comment: "")
        lblNewP.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "New Password", comment: "")
    }
 
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
   
        if tfCurrPassword.text == "" {
            Utils.showAlert(message: "現在のパスワードが入力されていません。", view: self)
        } else if tfNewPassword.text == "" {
            Utils.showAlert(message: "新しいパスワードが入力されていません。", view: self)
        } else if tfCurrPassword.text == tfNewPassword.text {
            Utils.showAlert(message: "同じパスワードで更新はできません。", view: self)
        } else {
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
        
            APIRequest.getAccessSecretMemo(password: tfCurrPassword.text!) { (success, msg) in
                if success {
                    APIRequest.updateAccountSecretMemoPass(password: self.tfNewPassword.text!) { (success) in
                        if success {
                            Utils.showAlert(message: msg, view: self)
                            UserDefaults.standard.set(self.tfNewPassword.text, forKey: "secret_pass")
                        } else {
                            Utils.showAlert(message: msg, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Utils.showAlert(message: msg, view: self)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
