//
//  MessageTemplatePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/08/23.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol MessageTemplatePopupVCDelegate: class {
    func onSaveSuccessful()
}

class MessageTemplatePopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var tfTitleCategoryItem: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    //Variable
    var msgCategory = MessengerCategoryData()
    var msgCategoryItem = MessengerCategoryItemData()
    weak var delegate:MessageTemplatePopupVCDelegate?
    var type: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    deinit {
        print("Release Memory")
    }
    
    fileprivate func setupLayout() {
        tvContent.layer.cornerRadius = 5
        if type == 1 {
            btnSave.setTitle("登録", for: .normal)
        }
    }
    
    fileprivate func loadData() {
        lblCategory.text = msgCategory.category_name
        
        if msgCategoryItem.title != "" {
            tfTitleCategoryItem.text = msgCategoryItem.title
            tvContent.text = msgCategoryItem.content
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    @IBAction func onAutoGenerate(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            tvContent.text += "{顧客名}"
        case 2:
            tvContent.text += "{店舗名}"
        default:
            break
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        if tfTitleCategoryItem.text!.isEmpty {
            Utils.showAlert(message: "メッセージタイトルを記入してください", view: self)
            return
        }
        
        if tvContent.text.isEmpty {
            Utils.showAlert(message: "メッセージ内容を記入してください", view: self)
            return
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        if type == 1 {
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onAddMessengerCategoryItem(categoryID: msgCategory.id, title: tfTitleCategoryItem.text!, content: tvContent.text) { (success) in
                if success {
                    self.dismiss(animated: true) {
                        self.delegate?.onSaveSuccessful()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            APIRequest.onEditMessengerCategoryItem(itemID: msgCategoryItem.id, title:tfTitleCategoryItem.text!, content: tvContent.text) { (success) in
                if success {
                    self.dismiss(animated: true) {
                        self.delegate?.onSaveSuccessful()
                    }
                } else {
                    Utils.showAlert(message: "メッセージの保存に失敗しました。", view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
