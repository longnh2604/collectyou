//
//  SettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/31.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class SettingPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfSecretPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
    @IBAction func onSaveSetting(_ sender: UIButton) {
        if tfSecretPass.text == "" {
            Utils.showAlert(message: "シークレットメモのパスワードを設定してください。", view: self)
        } else {
            //add loading view
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            APIRequest.updateAccountSecretMemoPass(password: tfSecretPass.text!) { (success) in
                if success {
                    Utils.showAlert(message: "シークレットメモのパスワードを更新しました。", view: self)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    Utils.showAlert(message: "シークレットメモのパスワード更新に失敗しました。", view: self)
                    self.dismiss(animated: true, completion: nil)
                }
                SVProgressHUD.dismiss()
            }
        }
        
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
