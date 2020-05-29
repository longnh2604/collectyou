//
//  MessageTemplateVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/28.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class MessageTemplateVC: UIViewController {
    //IBOutlet
    @IBOutlet weak var tblMsgCategory: UITableView!
    @IBOutlet weak var tblMsgCategoryItem: UITableView!
    @IBOutlet weak var tvContent: UITextView!
    
    //Variable
    var msgCategory: Results<MessengerCategoryData>!
    var msgCategoryItem: Results<MessengerCategoryItemData>!
    var accountData = AccountData()
    var textField: UITextField?
    var categoryIndex: Int?
    var itemIndex: Int?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    deinit {
        print("Release Memory")
    }
    
    fileprivate func setupLayout() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "送信テンプレート", comment: "")
        
        tvContent.layer.cornerRadius = 5
        tvContent.layer.borderColor = UIColor.gray.cgColor
        tvContent.layer.borderWidth = 2
        tblMsgCategory.layer.cornerRadius = 5
        tblMsgCategory.layer.borderColor = UIColor.gray.cgColor
        tblMsgCategory.layer.borderWidth = 2
        tblMsgCategoryItem.layer.cornerRadius = 5
        tblMsgCategoryItem.layer.borderColor = UIColor.gray.cgColor
        tblMsgCategoryItem.layer.borderWidth = 2
        
        let nib1 = UINib(nibName: "MessageTemplateCell", bundle: nil)
        tblMsgCategory.register(nib1, forCellReuseIdentifier: "MessageTemplateCell")
        tblMsgCategory.delegate = self
        tblMsgCategory.dataSource = self
        tblMsgCategory.tableFooterView = UIView()
        
        let nib2 = UINib(nibName: "MessageTemplateCell", bundle: nil)
        tblMsgCategoryItem.register(nib2, forCellReuseIdentifier: "MessageTemplateCell")
        tblMsgCategoryItem.delegate = self
        tblMsgCategoryItem.dataSource = self
        tblMsgCategoryItem.tableFooterView = UIView()
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func loadData() {
        onGetMessengerCategory()
    }
    
    fileprivate func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!
            self.textField?.placeholder = "記入して下さい";
        }
    }
    
    fileprivate func onGetMessengerCategory() {
        APIRequest.onGetMessengerCategory { (success) in
            if success {
                let realm = try! Realm()
                self.msgCategory = realm.objects(MessengerCategoryData.self)
                self.categoryIndex = nil
                self.tblMsgCategory.reloadData()
                self.tblMsgCategoryItem.reloadData()
                self.tvContent.text = ""
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func onGetMessengerCategoryItem() {
        APIRequest.onGetMessengerCategoryItem(categoryID: self.msgCategory[self.categoryIndex!].id) { (success) in
            if success {
                let realm = try! Realm()
                self.msgCategoryItem = realm.objects(MessengerCategoryItemData.self)
                self.tblMsgCategoryItem.reloadData()
                self.tvContent.text = ""
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAddCategory(_ sender: UIButton) {
        let alert = UIAlertController(title: "カテゴリー", message: "送信カテゴリー名を記入してください。", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            if (self.textField?.text?.isEmpty)! {
                Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_TITLE, view: self)
            } else {
                if let text = self.textField?.text {
                    SVProgressHUD.show(withStatus: "読み込み中")
                    APIRequest.onAddMessengerCategory(account_id:self.accountData.id,name: text) { (success) in
                        if success {
                            self.onGetMessengerCategory()
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_TITLE, view: self)
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onEditCategory(_ sender: UIButton) {
        if categoryIndex == nil {
            Utils.showAlert(message: "先にカテゴリーを選択してください", view: self)
            return
        }
        
        let alert = UIAlertController(title: "カテゴリー", message: "カテゴリーのタイトルを編集してよろしいですか", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            if (self.textField?.text?.isEmpty)! {
                Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_TITLE, view: self)
            } else {
                if let text = self.textField?.text {
                    SVProgressHUD.show(withStatus: "読み込み中")
                    APIRequest.onEditMessengerCategory(categoryID: self.msgCategory[self.categoryIndex!].id, name: text) { (success) in
                        if success {
                            self.onGetMessengerCategory()
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_TITLE, view: self)
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onDeleteCategory(_ sender: UIButton) {
        if categoryIndex == nil {
            Utils.showAlert(message: "先にカテゴリーを選択してください", view: self)
            return
        }
        
        let alert = UIAlertController(title: "カテゴリー", message: "選択しているカテゴリーを削除します。よろしいですか", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onDeleteMessengerCategory(categoryID: self.msgCategory[self.categoryIndex!].id) { (success) in
                if success {
                    self.onGetMessengerCategory()
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onAddMsgCategory(_ sender: UIButton) {
        if (categoryIndex == nil) {
            Utils.showAlert(message: "先にカテゴリーを選択してください", view: self)
            return
        }
        
        guard let newPopup = MessageTemplatePopupVC(nibName: "MessageTemplatePopupVC", bundle: nil) as MessageTemplatePopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 680, height: 550)
        newPopup.msgCategory = msgCategory[categoryIndex!]
        newPopup.delegate = self
        newPopup.type = 1
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onEditMsgCategory(_ sender: UIButton) {
        if itemIndex == nil {
            Utils.showAlert(message: "先にメッセージを選択してください", view: self)
            return
        }
        
        guard let newPopup = MessageTemplatePopupVC(nibName: "MessageTemplatePopupVC", bundle: nil) as MessageTemplatePopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 680, height: 550)
        newPopup.msgCategory = msgCategory[categoryIndex!]
        newPopup.msgCategoryItem = msgCategoryItem[itemIndex!]
        newPopup.delegate = self
        newPopup.type = 2
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onDeleteMsgCategory(_ sender: UIButton) {
        if itemIndex == nil {
            Utils.showAlert(message: "先にメッセージを選択してください", view: self)
            return
        }
        let alert = UIAlertController(title: "メッセージ", message: "選択しているメッセージを削除します。よろしいですか", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onDeleteMessengerCategoryItem(itemID: self.msgCategoryItem[self.itemIndex!].id) { (success) in
                if success {
                    self.onGetMessengerCategoryItem()
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - TableView Delegate
//*****************************************************************

extension MessageTemplateVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            if (msgCategory != nil) {
                return msgCategory.count
            } else {
                return 0
            }
        case 2:
            if (msgCategoryItem != nil && categoryIndex != nil) {
                return msgCategoryItem.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageTemplateCell.self)) as? MessageTemplateCell else
        { return UITableViewCell() }
        switch tableView.tag {
        case 1:
            cell.configure(content: msgCategory[indexPath.row].category_name)
        case 2:
            cell.configure(content: msgCategoryItem[indexPath.row].title)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            SVProgressHUD.show(withStatus: "読み込み中")
            categoryIndex = indexPath.row
            self.onGetMessengerCategoryItem()
        } else if tableView.tag == 2 {
            itemIndex = indexPath.row
            tvContent.text = msgCategoryItem[indexPath.row].content
        }
    }
}

//*****************************************************************
// MARK: - MessageTemplatePopupVC Delegate
//*****************************************************************

extension MessageTemplateVC: MessageTemplatePopupVCDelegate {
    func onSaveSuccessful() {
        itemIndex = nil
        self.onGetMessengerCategoryItem()
    }
}
