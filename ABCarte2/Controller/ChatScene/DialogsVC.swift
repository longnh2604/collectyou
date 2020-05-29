//
//  DialogsVC.swift
//  ABCarte2
//
//  Created by Long on 2019/09/27.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import ConnectyCube
import RealmSwift

class DialogsVC: UIViewController {

    //Variable
    var accountsData = AccountData()
    var customersData : [CustomerData] = []
    var ids: [Int] = []
    var shopID: UInt?
    var arrDialogID: [String] = []
    var msgCategory: Results<MessengerCategoryData>!
    var msgCategoryItem: Results<MessengerCategoryItemData>!
    let categoryDD = DropDown()
    let itemDD = DropDown()
    var categoryIndex: Int?
    var itemIndex: Int?
    var needLoad = true
    var limitCharacter = 140
    
    //IBOutlet
    @IBOutlet weak var tblDialogs: UITableView!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnCategory: RoundButton!
    @IBOutlet weak var btnItem: RoundButton!
    @IBOutlet weak var lblCharacterCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ChatApp.dialogs.sortedData.addPresenter(self.tblDialogs)
        setupLayout()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        onConnectChatFunction()
    }
    
    fileprivate func setupLayout() {
        tblDialogs.delegate = self
        tblDialogs.dataSource = self
        tblDialogs.tableFooterView = UIView()
        tblDialogs.allowsMultipleSelection = true
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "送受信管理画面", comment: "")
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessageLimitCharacter.rawValue) {
            limitCharacter = 1000
        }
        tvMessage.layer.cornerRadius = 10
        tvMessage.delegate = self
        lblCharacterCount.text = "\(tvMessage.text.count)/\(limitCharacter)"
    }
    
    fileprivate func loadData() {
        APIRequest.onGetMessengerCategory { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.msgCategory = realm.objects(MessengerCategoryData.self)
                self.setupCategoryDropDown()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
        }
    }
    
    fileprivate func setupCategoryDropDown() {
        categoryDD.anchorView = btnCategory
        categoryDD.bottomOffset = CGPoint(x: 0, y: btnCategory.bounds.height)
        var arrCategory : [String] = []
        for i in 0 ..< self.msgCategory.count {
            arrCategory.append(self.msgCategory[i].category_name)
        }
        categoryDD.dataSource = arrCategory
        categoryDD.selectionAction = { [weak self] (index, item) in
            self?.btnCategory.setTitle(item, for: .normal)
            self?.categoryIndex = index
            APIRequest.onGetMessengerCategoryItem(categoryID: (self?.msgCategory[index].id)!, completion: { (success) in
                if success {
                    let realm = RealmServices.shared.realm
                    self?.msgCategoryItem = realm.objects(MessengerCategoryItemData.self)
                    self?.setupItemDropDown()
                    self?.btnItem.setTitle("アイテム", for: .normal)
                    self?.tvMessage.text = ""
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self!)
                }
            })
        }
    }
    
    fileprivate func setupItemDropDown() {
        itemDD.anchorView = btnItem
        itemDD.bottomOffset = CGPoint(x: 0, y: btnItem.bounds.height)
        var arrItem : [String] = []
        for i in 0 ..< self.msgCategoryItem.count {
           arrItem.append(self.msgCategoryItem[i].title)
        }
        itemDD.dataSource = arrItem
        itemDD.selectionAction = { [weak self] (index, item) in
            self?.btnItem.setTitle(item, for: .normal)
            self?.itemIndex = index
            self?.tvMessage.text = self?.msgCategoryItem[index].content
            self?.lblCharacterCount.text = "\(self!.countCharacters(text: self!.tvMessage.text))/\(self!.limitCharacter)"
        }
    }
    
    private func countCharacters(text:String)->Int {
        var total = text.count
        if text.contains("{顧客名}") {
            total -= 5
        }
        if text.contains("{店舗名}") {
            total -= 5
        }
        return total
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
        needLoad = true
    }
    
    fileprivate func onConnectChatFunction() {
        if needLoad {
            if Chat.instance.isConnected {
                // do nothing
            } else {
                SVProgressHUD.show(withStatus: "読み込み中")
                ChatApp.connectWithSelectedDialogs(dialogsID: arrDialogID) {
                    self.tblDialogs.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }

    @IBAction func onSendAll(_ sender: UIButton) {
        if tvMessage.text.isEmpty {
            Utils.showAlert(message: "送信メッセージを記入してください。", view: self)
            return
        }
        
        if ids.count < 1 {
            Utils.showAlert(message: "先に顧客を選択してください。", view: self)
            return
        }
        
        SVProgressHUD.showProgress(0)
        let newIds = ids
        for i in 0 ..< newIds.count {
            if let dialog: ChatDialog = ChatApp.dialogs.sortedData.object(IndexPath(row: newIds[i], section: 0)) {
                var msg = tvMessage.text
                if tvMessage.text.contains("{顧客名}") {
                    let cus = customersData.filter({ $0.cus_dialogID == dialog.id })
                    if cus.count > 0 {
                        let cusName = cus[0].first_name + " " + cus[0].last_name
                        msg = msg?.replacingOccurrences(of: "{顧客名}", with: cusName)
                    }
                }
                if tvMessage.text.contains("{店舗名}") {
                    msg = msg?.replacingOccurrences(of: "{店舗名}", with: accountsData.acc_name)
                }
                ChatApp.messages.sendMessage(with: msg!, to: dialog) {
                    self.tblDialogs.deselectRow(at: IndexPath(row: newIds[i], section: 0), animated: true)
                    self.ids.remove(object: newIds[i])
                }
            }
        }
        SVProgressHUD.dismiss()
    }
    
    @IBAction func onCheckAll(_ sender: UIButton) {
        ids.removeAll()
        for row in 0 ..< tblDialogs.numberOfRows(inSection: 0) {
            tblDialogs.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            ids.append(IndexPath(row: row, section: 0).row)
        }
    }
    
    @IBAction func onMsgCategorySelect(_ sender: UIButton) {
        categoryDD.show()
    }
    
    @IBAction func onMsgCategoryItemSelect(_ sender: UIButton) {
        itemDD.show()
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension DialogsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfObjects = ChatApp.dialogs.sortedData.numberOfObjects()
        return numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dialogCell(forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ids.append(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        ids.removeAll(where: { $0 == indexPath.row })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func dialogCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblDialogs.dequeueReusableCell(for: indexPath, cellType: DialogCell.self)
        let dialog: ChatDialog = ChatApp.dialogs.sortedData.object(indexPath)!
        let bgColorView = UIView()
        bgColorView.backgroundColor = COLOR_SET.kOCEANGREEN
        cell.selectedBackgroundView = bgColorView
        cell.setTitle(title: dialog.name, imageUrl: dialog.photo)
        cell.setLastMessageText(lastMessageText: dialog.lastMessageText, date: dialog.updatedAt!, unreadMessageCount:dialog.unreadMessagesCount)
        cell.dialog = dialog
        cell.delegate = self
        return cell
    }
}

//*****************************************************************
// MARK: - DialogsCell Delegate
//*****************************************************************

extension DialogsVC: DialogCellDelegate {
    func onMoveChat(dialog: ChatDialog) {
        SVProgressHUD.show(withStatus: "読み込み中")
        guard var no = dialog.occupantIDs else { return }
        if no.count > 1 {
            no = [no[1]]
        }
        
        ConnectyCubeRequest.onRetrieveUserByID(id: no.first ?? 0) { (success, users) in
            if success {
                for i in 0 ..< self.customersData.count {
                    if self.customersData[i].id == Int(users[0].login!) {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil)
                        if let vc = storyBoard.instantiateViewController(withIdentifier: "CarteChatVC") as? CarteChatVC {
                            if let navigator = self.navigationController {
                                //remove check cell first
                                for i in 0 ..< self.ids.count {
                                    self.tblDialogs.deselectRow(at: IndexPath(row: self.ids[i], section: 0), animated: true)
                                    self.ids.remove(object: self.ids[i])
                                }
                                self.needLoad = true
                                vc.customerData = self.customersData[i]
                                vc.accountsData = self.accountsData
                                
                                navigator.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.showError(withStatus: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN)
            }
        }
    }
}

//*****************************************************************
// MARK: - TextView Delegate
//*****************************************************************

extension DialogsVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        lblCharacterCount.text = "\(countCharacters(text: textView.text))/\(limitCharacter)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let rangeOfTextToReplace = Range(range, in: textView.text) else {
            return false
        }
        let substringToReplace = textView.text[rangeOfTextToReplace]
        let count = countCharacters(text: textView.text) - substringToReplace.count + text.count
        return count <= limitCharacter
    }
}
