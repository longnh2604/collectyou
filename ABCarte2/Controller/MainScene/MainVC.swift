//
//  MainVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import UXMPDFKit
import ConnectyCube
import LGButton

class MainVC: BaseVC {

    //Variable
    var customers: Results<CustomerData>!
    var customersData = [CustomerData]()
    var customersDataSearch = [CustomerData]()
    var customersDataHierarchy = [CustomerData]()
    
    var indexDelete = [Int]()
    var needLoad: Bool = true
    var searchActive = false
    var hierarchyActive = false
    var searchPopActive = false
    var isScrolling = false
 
    //IBOutlet
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var btnDelete: LGButton!
    @IBOutlet weak var btnComplete: LGButton!
    @IBOutlet weak var btnSelect: LGButton!
    @IBOutlet weak var btnAddCustomer: LGButton!
    @IBOutlet weak var btnSearch: LGButton!
    @IBOutlet weak var btnShowAll: LGButton!
    @IBOutlet weak var btnCalendar: LGButton!
    @IBOutlet weak var btnSendMsg: LGButton!
    @IBOutlet weak var viewPanelTop: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblLastVisit: UILabel!
    @IBOutlet weak var lblBirth: UILabel!
    @IBOutlet weak var lblCusNo: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        loadData()
        getAllCustomers()
    }
    
    fileprivate func setupLayout() {
        //navigation bar
        let newBackButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = newBackButton

        searchBar.delegate = self
        let nib1 = UINib(nibName: "MainListCell", bundle: nil)
        tblMain.register(nib1, forCellReuseIdentifier: "MainListCell")
        tblMain.delegate = self
        tblMain.dataSource = self
        tblMain.tableFooterView = UIView()
        
        if self.searchPopActive == true {
            self.btnShowAll.isHidden = false
        } else {
            self.btnShowAll.isHidden = true
        }
        
        checkAccOption()
        localizeLanguage()
    }
    
    func updateColor() {
        Utils.setViewColorStyle(view: viewPanelTop, type: 1)
        guard let navi = navigationController else { return }
        if let set = UserPreferences.appColorSet {
            addNavigationBarColor(navigation: navi, type: set)
        } else {
            addNavigationBarColor(navigation: navi,type: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateColor()
        
        if GlobalVariables.sharedManager.customerSwitch == true {
            self.searchBar.text = ""
            self.searchActive = false
            self.btnShowAll.isHidden = true
            self.searchPopActive = false
            
            loadData()
            getAllCustomers()
            Utils.showAlert(message: "顧客の移動が完了しました。", view: self)
            GlobalVariables.sharedManager.customerSwitch = false
            return
        }
        
        if needLoad == false {
            if Profile.currentProfile != nil {
                ChatApp.connect()
                Chat.instance.addDelegate(self)
            }
        }
        
        if GlobalVariables.sharedManager.currentIndex != nil {
            var cusID : Int?
            var update : Int?
            if searchActive {
                cusID = customersDataSearch[GlobalVariables.sharedManager.currentIndex!].id
                update = customersDataSearch[GlobalVariables.sharedManager.currentIndex!].updated_at
            } else {
                cusID = customers[GlobalVariables.sharedManager.currentIndex!].id
                update = customers[GlobalVariables.sharedManager.currentIndex!].updated_at
            }
            
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onCheckCustomerData(cusID: cusID!, update: update!) { (success,cusData) in
                if success > 0 {
                    let dict : [String : Any?] = ["cus_msg_inbox" : cusData.cus_msg_inbox,
                                                  "cus_dialogID": cusData.cus_dialogID]
                    if self.searchActive {
                        RealmServices.shared.update(self.customersDataSearch[GlobalVariables.sharedManager.currentIndex!], with: dict)
                    } else {
                        RealmServices.shared.update(self.customersData[GlobalVariables.sharedManager.currentIndex!], with: dict)
                    }
                    self.tblMain.reloadRows(at: [IndexPath(row: GlobalVariables.sharedManager.currentIndex!, section: 0)], with: .automatic)
                }
                self.tblMain.selectRow(at: IndexPath(row: GlobalVariables.sharedManager.currentIndex!, section: 0), animated: false, scrollPosition: .none)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    fileprivate func loadData() {
        GlobalVariables.sharedManager.onMultiSelect = false
        GlobalVariables.sharedManager.currentIndex = nil
        
        APIRequest.countStorage { (success) in
            if success {
                let status = Utils.checkRemainingStorage()
                if status != "OK" {
                    let alert = UIAlertController(title: "\(status)", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                    let confirm = UIAlertAction(title: "申込", style: .default) { UIAlertAction in
                        APIRequest.onSendEmailStorageExtend(account: self.accounts[0]) { (success) in
                            if success {
                                Utils.showAlert(message: "追加申込を受け付けました。\n追って担当者から連絡を行わせて頂きます。", view: self)
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                            }
                        }
                    }
                    alert.addAction(confirm)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        GlobalVariables.sharedManager.hierarchyList.removeAll()
        UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
        if let story: UIStoryboard = UIStoryboard(name: "Login", bundle: nil) as UIStoryboard? {
            #if AIMB
            guard let vc = story.instantiateViewController(withIdentifier: Constants.VC_ID.APP_SELECT_AIMB) as? AppSelectAIMBVC else { return }
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            #else
            guard let vc = story.instantiateViewController(withIdentifier: Constants.VC_ID.APP_SELECT) as? AppSelectVC else { return }
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            #endif
        }
    }
    
    fileprivate func checkAccOption() {
        #if AIMB || ATTENDER
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kJBS.rawValue) {
            let btnLeftMenu: UIButton = UIButton()
            btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
            btnLeftMenu.contentMode = .scaleAspectFit
            btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
            btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let barButton = UIBarButtonItem(customView: btnLeftMenu)
            self.navigationItem.leftBarButtonItem = barButton
        }
        #endif
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCalendar.rawValue) {
            btnCalendar.isHidden = false
        } else {
            btnCalendar.isHidden = true
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
            btnSendMsg.isHidden = false
            bottomPanelView.viewMsgTemp.isHidden = false
        } else {
            btnSendMsg.isHidden = true
            bottomPanelView.viewMsgTemp.isHidden = true
        }
    }
    
    fileprivate func localizeLanguage() {
        //navigation title
        let button = LGButton()
        button.leftImageSrc = UIImage(named: "icon_person_white.png")
        button.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Customer Management", comment: "")
        button.titleFontSize = 20.0
        button.bgColor = UIColor.clear
        button.backgroundColor = UIColor.clear
        navigationItem.titleView = button

        btnShowAll.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Show All", comment: "")
        btnComplete.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Complete", comment: "")
        btnDelete.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Delete", comment: "")
        btnAddCustomer.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Add Customer", comment: "")
        btnCalendar.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Calendar", comment: "")
        btnSearch.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Search", comment: "")
        btnSelect.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Select", comment: "")
        btnSendMsg.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Messenger", comment: "")
     
        searchBar.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input Customer's Surname", comment: "")
        lblName.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Name", comment: "")
        lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Sex", comment: "")
        lblLastVisit.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Last Visited", comment: "")
        lblBirth.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Birthdate", comment: "")
        lblCusNo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cus's No", comment: "")
    }
    
    fileprivate func getAllCustomers() {
        SVProgressHUD.show(withStatus: "読み込み中")
        
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        DispatchQueue.global(qos: .background).async {
            APIRequest.onGetAllCustomers { [unowned self] (success) in
                if success {
                    self.customers = self.realm.objects(CustomerData.self)
                    self.accounts = self.realm.objects(AccountData.self)

                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }

                    if self.hierarchyActive == true {
                        if GlobalVariables.sharedManager.hierarchyList.count > 0 {
                            self.onUpdateHierarchyData(arrIDs: GlobalVariables.sharedManager.hierarchyList)

                            if self.searchActive == true && !self.searchBar.text!.isEmpty {
                                self.customersDataSearch = self.customersData.filter({ $0.last_name_kana.hasPrefix("\(self.searchBar.text!.lowercased())")})
                            }
                        }
                    } else {
                        if self.searchActive == true && !self.searchBar.text!.isEmpty {
                            self.customersDataSearch = self.customersData.filter({ $0.last_name_kana.hasPrefix("\(self.searchBar.text!.lowercased())")})
                        }
                        self.tblMain.reloadData {
                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
                                if Chat.instance.isConnected {
                                    //do nothing
                                } else {
                                    self.onConnectChat()
                                }
                            }
                            SVProgressHUD.dismiss()
                        }
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
                    SVProgressHUD.dismiss()
                }
                if self.searchPopActive == true {
                    self.btnShowAll.isHidden = false
                } else {
                    self.btnShowAll.isHidden = true
                }
                self.updateTotalCus()
            }
        }
    }
    
    fileprivate func showNewVersionUpdate() {
        let alert = UIAlertController(title: "新しいバージョンがございますのでインストールページを移動しますか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            //do update
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func onConnectChat() {
        if let accID = GlobalVariables.sharedManager.account_chat {
            SVProgressHUD.show(withStatus: "読み込み中")
            btnSendMsg.isUserInteractionEnabled = false
            ConnectyCubeRequest.onLogin(user: accID, pass: "abcd1234") { (status, user) in
                if status == 1 {
                    //login success
                    Profile.currentProfile = user
                    ChatApp.connect()
                    Chat.instance.addDelegate(self)
                } else if status == 3 {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "サーバーと接続できませんでした。ネットワークを確認してください。", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                    let confirm = UIAlertAction(title: "再接続", style: .default) { UIAlertAction in
                        self.onLoginChatServer()
                    }
                    alert.addAction(confirm)
                    alert.addAction(cancel)

                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    SVProgressHUD.dismiss()
                    self.onCreateShopAccount()
                }
                self.btnSendMsg.isUserInteractionEnabled = true
            }
        }
    }
    
    fileprivate func onCreateShopAccount() {
        let alert = UIAlertController(title: "メッセージを送信するための店舗アカウントを作成しますか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            //add loading view
            guard let accID = GlobalVariables.sharedManager.account_chat else { return }
            //check account name
            if self.accounts[0].acc_name != "" {
                SVProgressHUD.show(withStatus: "読み込み中")
                ConnectyCubeRequest.onCreateUser(login: accID, pass: "abcd1234", email: "", fullName: self.accounts[0].acc_name, tags: [], completion: { (success, id) in
                    if success {
                        //success
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CREATE_CUSTOMER_CHAT_ACCOUNT, view: self)
                    }
                    SVProgressHUD.dismiss()
                })
            }
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func updateTotalCus() {
        if searchActive == true {
            self.navigationItem.rightBarButtonItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Total", comment: "") + " \(customersDataSearch.count)"
        } else {
            self.navigationItem.rightBarButtonItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Total", comment: "") + " \(customersData.count)"
        }
    }

    fileprivate func goToCarteDetail() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "CarteListVC") as? CarteListVC {
            if let navigator = navigationController {
                if let cus = customersData.count as Int?,let currIndex = GlobalVariables.sharedManager.currentIndex {
                    if cus == 0 {
                       Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                       return
                    }
                   
                    if searchActive == true {
                        vc.customer = customersDataSearch[currIndex]
                    } else {
                        vc.customer = customersData[currIndex]
                    }
                    vc.accounts = accounts
                    self.needLoad = false
                    navigator.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - BaseVC
    //*****************************************************************
    
    override func onColorStyleChange() {
        GlobalVariables.sharedManager.onMultiSelect = false
        bottomPanelView.updateLayout()
        updateColor()
    }
    
    override func onLanguageChange() {
        localizeLanguage()
        updateTotalCus()
        tblMain.reloadData()
    }
    
    override func onRefreshData() {
        GlobalVariables.sharedManager.hierarchyList.removeAll()
        UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
        hierarchyActive = false
        getAllCustomers()
    }
    
    override func onUpdateHierarchyData(arrIDs: [Int]) {
        GlobalVariables.sharedManager.currentIndex = nil
        customersDataHierarchy.removeAll()
        customersData.removeAll()
        GlobalVariables.sharedManager.hierarchyList = arrIDs
        hierarchyActive = true
        
        for i in 0 ..< self.customers.count {
            self.customersDataHierarchy.append(self.customers[i])
        }
        
        for i in 0 ..< arrIDs.count {
            let cus = customersDataHierarchy.filter({ $0.fc_account_id == arrIDs[i] })
            customersData.append(contentsOf: cus)
        }
        //sorted data again
        customersData = customersData.sorted(by: { ($0.last_name_kana,$0.first_name_kana) < ($1.last_name_kana,$1.first_name_kana) })
        updateTotalCus()
        
        tblMain.reloadData {
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
                if !Chat.instance.isConnected {
                    self.onConnectChat()
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func onConnectChatServer() {
        APIRequest.onCreateCustomerChat(customerID: self.accounts[0].account_id, password: "abc123", isShop: 1) { (success) in
            if success {
                APIRequest.onLoginChatServer(customerID: self.accounts[0].account_id, password: "abc123", isShop: 1) { (success) in
                    if success {
                        
                    } else {
                        Utils.showAlert(message: "Failed to Login Chat Server", view: self)
                    }
                }
            } else {
                Utils.showAlert(message: "Failed to Create Shop Account", view: self)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSendMessage(_ sender: LGButton) {
        onLoginChatServer()
    }
    
    fileprivate func onLoginChatServer() {
        guard let accID = GlobalVariables.sharedManager.account_chat else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        btnSendMsg.isUserInteractionEnabled = false
        ConnectyCubeRequest.onLogin(user: accID, pass: "abcd1234") { (status, user) in
            if status == 1 {
                //login success
                Profile.currentProfile = user
                let storyBoard: UIStoryboard = UIStoryboard(name: "Messenger", bundle: nil)
                if let vc = storyBoard.instantiateViewController(withIdentifier: "DialogsVC") as? DialogsVC {
                    //check search condition
                    var arrDialogID: [String] = []
                    if self.searchActive {
                        for i in 0 ..< self.customersDataSearch.count {
                            if self.customersDataSearch[i].cus_dialogID != "" {
                                arrDialogID.append(self.customersDataSearch[i].cus_dialogID)
                            }
                        }
                        vc.arrDialogID = arrDialogID
                        vc.customersData = self.customersDataSearch
                    } else {
                        for i in 0 ..< self.customersData.count {
                            if self.customersData[i].cus_dialogID != "" {
                                arrDialogID.append(self.customersData[i].cus_dialogID)
                            }
                        }
                        vc.arrDialogID = arrDialogID
                        vc.customersData = self.customersData
                    }
                    vc.accountsData = self.accounts[0]
                    vc.shopID = user.id
                    let user = Profile.currentProfile
                    ChatApp.logOut {
                        Profile.currentProfile = user
                        self.navigationController?.pushViewController(vc, animated: true)
                        self.btnSendMsg.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                    }
                }
            } else if status == 3 {
                self.btnSendMsg.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "サーバーと接続できませんでした。ネットワークを確認してください。", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "再接続", style: .default) { UIAlertAction in
                    self.onLoginChatServer()
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                self.btnSendMsg.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CONNECT_CHAT, view: self)
            }
        }
    }
    
    @IBAction func onAddCustomer(_ sender: LGButton) {
        NetworkManager.isUnreachable { _ in
            Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            return
        }
        NetworkManager.isReachable { _ in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
                vc.modalTransitionStyle   = .crossDissolve;
                vc.modalPresentationStyle = .overCurrentContext
                vc.popupType = PopUpType.AddNew.rawValue
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    @IBAction func onSearchSelect(_ sender: LGButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchPopupVC") as? SearchPopupVC {
            vc.modalTransitionStyle   = .crossDissolve;
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func onSelectOption(_ sender: LGButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async(execute: {() -> Void in
                GlobalVariables.sharedManager.currentIndex = nil
                GlobalVariables.sharedManager.onMultiSelect = !GlobalVariables.sharedManager.onMultiSelect!
                self.tblMain.allowsMultipleSelection = GlobalVariables.sharedManager.onMultiSelect!
                self.showDeleteOption(status: true)
                for i in 0 ..< self.customers.count {
                    let dict : [String : Any?] = ["selected_status" : 0]
                    RealmServices.shared.update(self.customers[i], with: dict)
                }
                self.tblMain.reloadData()
            })
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onComplete(_ sender: LGButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async(execute: {() -> Void in
                GlobalVariables.sharedManager.onMultiSelect = false
                self.tblMain.allowsMultipleSelection = false
                self.showDeleteOption(status: false)
                self.checkAccOption()
                for i in 0 ..< self.customers.count {
                    let dict : [String : Any?] = ["selected_status" : 0]
                    RealmServices.shared.update(self.customers[i], with: dict)
                }
                self.tblMain.reloadData()
            })
            SVProgressHUD.dismiss()
        }
    }
    
    func showDeleteOption(status:Bool) {
        btnAddCustomer.isHidden = status
        btnSelect.isHidden = status
        btnSearch.isHidden = status
        btnCalendar.isHidden = status
        btnSendMsg.isHidden = status
        
        btnComplete.isHidden = !status
        btnDelete.isHidden = !status
    }
    
    @IBAction func onDelete(_ sender: LGButton) {
        
        indexDelete.removeAll()
        if searchActive == true {
            let cus = customersDataSearch.filter {
                $0.selected_status == 1
            }
            for i in 0 ..< cus.count {
                indexDelete.append(cus[i].id)
            }
        } else {
            let cus = customersData.filter {
                $0.selected_status == 1
            }
            for i in 0 ..< cus.count {
                indexDelete.append(cus[i].id)
            }
        }
        
        if indexDelete.count > 0 {
            let alert = UIAlertController(title: "選択しているお客様を削除しますか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                //add loading view
                SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                APIRequest.deleteCustomer(ids: self.indexDelete) { (success) in
                    if success {
                        SVProgressHUD.showProgress(0.6, status: "サーバーにアップロード中:60%")
                        self.getAllCustomers()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                        self.tblMain.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_SELECT_CUSTOMER_2_DELETE, view: self)
        }
    }
    
    @IBAction func onShowAllRecord(_ sender: LGButton) {
        self.btnShowAll.isHidden = true
        searchPopActive = false
        getAllCustomers()
    }
    
    @IBAction func onShowCalendar(_ sender: LGButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as? CalendarVC {
            self.needLoad = false
            if let navigator = navigationController {
                SVProgressHUD.show(withStatus: "読み込み中")
                
                APIRequest.getAccountHierarchyWithAlliance(accountID: accounts[0].id) { (success,treeData) in
                    SVProgressHUD.dismiss()
                    if success {
                        if treeData.count > 0 {
                            viewController.treeData = treeData
                        }
                        navigator.pushViewController(viewController, animated: true)
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                        return
                    }
                }
            }
        }
    }
}

//*****************************************************************
// MARK: - RegCustomerPopup Delegate
//*****************************************************************

extension MainVC: RegCustomerPopupDelegate {
    
    func didConfirm(type:Int) {
        switch type {
        case 1:
            searchPopActive = false
            getAllCustomers()
        case 2:
            self.customers = realm.objects(CustomerData.self)
            
            self.customersData.removeAll()
            for i in 0 ..< self.customers.count {
                self.customersData.append(self.customers[i])
            }
            self.tblMain.reloadData()
            
            if let currIndex = GlobalVariables.sharedManager.currentIndex {
                let indexPath = IndexPath(row: 0, section: currIndex)
                self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        default:
            break
        }
       
    }
}

//*****************************************************************
// MARK: - UITableView Delegate
//*****************************************************************

extension MainVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == true {
            return customersDataSearch.count
        } else {
            return customersData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainListCell.self)) as! MainListCell
        
        if searchActive == true {
            cell.configure(with: customersDataSearch[indexPath.row],accName: accounts[0].acc_name)
        } else {
            cell.configure(with: customersData[indexPath.row],accName: accounts[0].acc_name)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currIndex = GlobalVariables.sharedManager.currentIndex {
            if currIndex == indexPath.row {
                goToCarteDetail()
            } else {
                if GlobalVariables.sharedManager.onMultiSelect == true {
                    let dict : [String : Any?] = ["selected_status" : 1]
                    if searchActive == true {
                        RealmServices.shared.update(customersDataSearch[indexPath.row], with: dict)
                    } else {
                        RealmServices.shared.update(customersData[indexPath.row], with: dict)
                    }
                } else {
                    GlobalVariables.sharedManager.currentIndex = indexPath.row
                }
            }
        } else {
            if GlobalVariables.sharedManager.onMultiSelect == true {
                let dict : [String : Any?] = ["selected_status" : 1]
                if searchActive == true {
                    RealmServices.shared.update(customersDataSearch[indexPath.row], with: dict)
                } else {
                    RealmServices.shared.update(customersData[indexPath.row], with: dict)
                }
            } else {
                GlobalVariables.sharedManager.currentIndex = indexPath.row
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if GlobalVariables.sharedManager.onMultiSelect == true {
            let dict : [String : Any?] = ["selected_status" : 0]
            if searchActive == true {
                RealmServices.shared.update(customersDataSearch[indexPath.row], with: dict)
            } else {
                RealmServices.shared.update(customersData[indexPath.row], with: dict)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if searchPopActive {
            onScrollLogicHandle(on: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchPopActive {
            onScrollLogicHandle(on: false)
        }
    }
    
    func onScrollLogicHandle(on:Bool) {
        if on {
            btnShowAll.isUserInteractionEnabled = true
            btnShowAll.alpha = 1.0
            isScrolling = false
        } else {
            btnShowAll.isUserInteractionEnabled = false
            btnShowAll.alpha = 0.6
            isScrolling = true
        }
    }
}

//*****************************************************************
// MARK: - Search Delegate
//*****************************************************************

extension MainVC:SearchPopupVCDelegate,SyllabaryPopupVCDelegate,CusNamePopupVCDelegate,CusPhonePopupVCDelegate,VisitPopupVCDelegate,GenderPopupVCDelegate,CustomerNoPopupVCDelegate,ResponsiblePopupVCDelegate,CustomerAddressPopupVCDelegate,BirthdayPopupVCDelegate,CustomerNotePopupVCDelegate,CustomerMemoPopupDelegate,CustomerStampMemoPopupDelegate {
    
    //*****************************************************************
    // MARK: - SearchPopup Delegate
    //*****************************************************************
    
    func selectSearchType(title: String) {
        switch title {
        case "五 十 音( 頭 文 字 )検 索":
            guard let newPopup = SyllabaryPopupVC(nibName: "SyllabaryPopupVC", bundle: nil) as SyllabaryPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 700)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "お客様の姓・名で検索":
            guard let newPopup = CusNamePopupVC(nibName: "CusNamePopupVC", bundle: nil) as CusNamePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 460)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "電話番号検索":
            guard let newPopup = CusPhonePopupVC(nibName: "CusPhonePopupVC", bundle: nil) as CusPhonePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 440)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "性別検索":
            guard let newPopup = GenderPopupVC(nibName: "GenderPopupVC", bundle: nil) as GenderPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "お客様番号検索":
            guard let newPopup = CustomerNoPopupVC(nibName: "CustomerNoPopupVC", bundle: nil) as CustomerNoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "担当者名検索":
            guard let newPopup = ResponsiblePopupVC(nibName: "ResponsiblePopupVC", bundle: nil) as ResponsiblePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "住所検索":
            guard let newPopup = CustomerAddressPopupVC(nibName: "CustomerAddressPopupVC", bundle: nil) as CustomerAddressPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 320)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "来店日検索":
            guard let newPopup = VisitPopupVC(nibName: "VisitPopupVC", bundle: nil) as VisitPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 490)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "誕生日検索":
            guard let newPopup = BirthdayPopupVC(nibName: "BirthdayPopupVC", bundle: nil) as BirthdayPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 380)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "備考検索":
            guard let newPopup = CustomerNotePopupVC(nibName: "CustomerNotePopupVC", bundle: nil) as CustomerNotePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 300)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "シークレットメモ検索":
            guard let newPopup = CustomerMemoPopup(nibName: "CustomerMemoPopup", bundle: nil) as CustomerMemoPopup? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 300)
            newPopup.type = 1
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "フリーメモ検索":
            guard let newPopup = CustomerMemoPopup(nibName: "CustomerMemoPopup", bundle: nil) as CustomerMemoPopup? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 300)
            newPopup.type = 2
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        case "スタンプメモ検索":
            guard let newPopup = CustomerStampMemoPopup(nibName: "CustomerStampMemoPopup", bundle: nil) as CustomerStampMemoPopup? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            if #available(iOS 13.0, *) {
                newPopup.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            newPopup.preferredContentSize = CGSize(width: 700, height: 600)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    //*****************************************************************
    // MARK: - Syllabary Popup Delegate
    //*****************************************************************
    
    func onSyllabarySearch(characters: [String]) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        GlobalVariables.sharedManager.currentIndex = nil
        APIRequest.onSearchSyllabary(characters: characters,page: nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
               
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Cus Name Popup Delegate
    //*****************************************************************
    
    func onCusNameSearch(LName1:String,FName1:String,LNameKana1:String,FNameKana1:String,LName2:String,FName2:String,LNameKana2:String,FNameKana2:String,LName3:String,FName3:String,LNameKana3:String,FNameKana3:String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
     
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
      
        APIRequest.onSearchName(LName1: LName1, FName1: FName1, LNameKana1: LNameKana1, FNameKana1: FNameKana1, LName2: LName2, FName2: FName2, LNameKana2: LNameKana2, FNameKana2: FNameKana2, LName3: LName3, FName3: FName3, LNameKana3: LNameKana3, FNameKana3: FNameKana3, page: nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }

                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Cus Phone Popup Delegate
    //*****************************************************************
    
    func onCusPhoneSearch(phoneNo: [String]) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
      
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
       
        APIRequest.onSearchMobile(mobileNo: phoneNo, page:nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
               
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - VisitPopup Delegate
    //*****************************************************************
    
    func onVisitSearch(params: String,type:Int) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
       
        switch type {
        case 1:
            APIRequest.onSearchSelectedDate(params: params) { (success) in
                if success {
                    self.customers = self.realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                    
                    self.searchBar.text = ""
                    self.btnShowAll.isHidden = false
                    self.searchActive = false
                    self.searchPopActive = true
                    self.tblMain.reloadData {
                        self.onScrollLogicHandle(on: true)
                    }
                    self.updateTotalCus()
                    
                    GlobalVariables.sharedManager.hierarchyList.removeAll()
                    UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        case 2:
            APIRequest.onSearchDate(params: params,page:nil) { (success) in
                if success {
                    self.customers = self.realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
               
                    self.searchBar.text = ""
                    self.searchActive = false
                    self.btnShowAll.isHidden = false
                    self.searchPopActive = true
                    self.tblMain.reloadData {
                        self.onScrollLogicHandle(on: true)
                    }
                    self.updateTotalCus()
                    
                    GlobalVariables.sharedManager.hierarchyList.removeAll()
                    UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        case 3:
            APIRequest.onSearchInterval(params: params,page:nil) { (success) in
                if success {
                    self.customers = self.realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                  
                    self.searchBar.text = ""
                    self.searchActive = false
                    self.btnShowAll.isHidden = false
                    self.searchPopActive = true
                    self.tblMain.reloadData {
                        self.onScrollLogicHandle(on: true)
                    }
                    self.updateTotalCus()
                    
                    GlobalVariables.sharedManager.hierarchyList.removeAll()
                    UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        default:
            break
        }
    }
    
    //*****************************************************************
    // MARK: - GenderPopupVC Delegate
    //*****************************************************************
    
    func onGenderSearch(gen: Int) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
       
        APIRequest.onSearchGender(gender: gen,page:nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
       
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - CustomerNo Popup Delegate
    //*****************************************************************
    
    func onCustomerNoSearch(number: String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
      
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
    
        APIRequest.onSearchCustomerNumber(customerNo: number,page:nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
             
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Responsible Popup Delegate
    //*****************************************************************
    
    func onResponsibleSearch(responsible: String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
       
        APIRequest.onSearchResponsiblePerson(name: responsible,page:nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
        
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
 
    
    //*****************************************************************
    // MARK: - Responsible Popup Delegate
    //*****************************************************************
    
    func onCustomerAddressSearch(address: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
    
        APIRequest.onSearchCustomerAddress(address: address, page: nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
            
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Birthday Popup Delegate
    //*****************************************************************
    
    func onCustomerBirthdaySearch(date:String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
     
        APIRequest.onSearchCustomerBirthday(day: date, page: nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
           
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func onCustomerBirthdayM2MSearch(month1: String, month2: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
    
        APIRequest.onSearchCustomerBirthdayM2M(month1: month1, month2: month2, page: nil) { (success) in
            
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
            
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func onCustomerBirthdayY2YSearch(year1: String, year2: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
    
        APIRequest.onSearchCustomerBirthdayY2Y(year1: year1, year2: year2, page: nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
           
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - CustomerNote Popup Delegate
    //*****************************************************************
    
    func onCustomerNoteSearch(note1: String, note2: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        APIRequest.onSearchCustomerNote(memo1: note1, memo2: note2, page: nil) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
           
                self.searchBar.text = ""
                self.searchActive = false
                self.btnShowAll.isHidden = false
                self.searchPopActive = true
                self.tblMain.reloadData {
                    self.onScrollLogicHandle(on: true)
                }
                self.updateTotalCus()
                
                GlobalVariables.sharedManager.hierarchyList.removeAll()
                UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Customer Memo Popup Delegate
    //*****************************************************************
    
    func onCustomerMemoPopupSearch(content:String,type:Int) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.currentIndex = nil
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        if type == 1 {
            APIRequest.onSearchCustomerSecretMemo(content: content, completion: { (success) in
                if success {
                     self.customers = self.realm.objects(CustomerData.self)
                     
                     self.customersData.removeAll()
                     for i in 0 ..< self.customers.count {
                         self.customersData.append(self.customers[i])
                     }
                
                     self.searchBar.text = ""
                     self.searchActive = false
                     self.btnShowAll.isHidden = false
                     self.searchPopActive = true
                     self.tblMain.reloadData {
                         self.onScrollLogicHandle(on: true)
                     }
                     self.updateTotalCus()
                     
                     GlobalVariables.sharedManager.hierarchyList.removeAll()
                     UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
                 } else {
                     Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                 }
                 SVProgressHUD.dismiss()
            })
        } else if type == 2 {
            APIRequest.onSearchCustomerFreeMemo(content: content, completion: { (success) in
                if success {
                     self.customers = self.realm.objects(CustomerData.self)
                     
                     self.customersData.removeAll()
                     for i in 0 ..< self.customers.count {
                         self.customersData.append(self.customers[i])
                     }
                     self.customersData.removeDuplicates()
                
                     self.searchBar.text = ""
                     self.searchActive = false
                     self.btnShowAll.isHidden = false
                     self.searchPopActive = true
                     self.tblMain.reloadData {
                         self.onScrollLogicHandle(on: true)
                     }
                     self.updateTotalCus()
                     
                     GlobalVariables.sharedManager.hierarchyList.removeAll()
                     UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
                 } else {
                     Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                 }
                 SVProgressHUD.dismiss()
            })
        }
    }
    
    //*****************************************************************
    // MARK: - Customer Stamp Memo Popup Delegate
    //*****************************************************************
    
    func onStampMemoSearch(content: String) {
         SVProgressHUD.show(withStatus: "読み込み中")
         SVProgressHUD.setDefaultMaskType(.clear)
         
         GlobalVariables.sharedManager.currentIndex = nil
         try! realm.write {
             realm.delete(realm.objects(CustomerData.self))
         }
        
        APIRequest.onSearchCustomerStampMemo(content: content) { (success) in
            if success {
                self.customers = self.realm.objects(CustomerData.self)
                 
                 self.customersData.removeAll()
                 for i in 0 ..< self.customers.count {
                     self.customersData.append(self.customers[i])
                 }
                 self.customersData.removeDuplicates()
            
                 self.searchBar.text = ""
                 self.searchActive = false
                 self.btnShowAll.isHidden = false
                 self.searchPopActive = true
                 self.tblMain.reloadData {
                     self.onScrollLogicHandle(on: true)
                 }
                 self.updateTotalCus()
                 
                 GlobalVariables.sharedManager.hierarchyList.removeAll()
                 UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - SearchBar Delegate
//*****************************************************************

extension MainVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let textConvert = searchText.hiragana
        let dict : [String : Any?] = ["selected_status" : 0]
        //check if search Text is empty or not
        guard !textConvert.isEmpty else {
            searchActive = false
            
            let cus = customersData.filter {
                $0.selected_status == 1
            }
            for i in 0 ..< cus.count {
                RealmServices.shared.update(cus[i], with: dict)
            }
            tblMain.reloadData()
            updateTotalCus()
            return
        }
        
        //remove currIndex
        if GlobalVariables.sharedManager.currentIndex != nil {
            GlobalVariables.sharedManager.currentIndex = nil
        }
        
        customersDataSearch.removeAll()
        searchActive = true
        customersDataSearch = customersData.filter({ $0.last_name_kana.hasPrefix("\(textConvert.lowercased())")})
        tblMain.reloadData()
        self.updateTotalCus()
    }
}

//*****************************************************************
// MARK: - Chat Delegate
//*****************************************************************

extension MainVC: ChatDelegate {
    
    func chatDidConnect() {
        print("Did connect")
        SVProgressHUD.dismiss()
    }
    
    func chatDidReconnect() {
        print("Did reconnect")
    }
    
    func chatDidDisconnectWithError(_ error: Error) {
        print("Did disconnect")
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
        print("Did not connect")
    }
    
    private func receive(_ message: ChatMessage) {
        let vc = UIApplication.topViewController()
        SVProgressHUD.show()
        if searchActive {
            for i in 0 ..< customersDataSearch.count {
                if customersDataSearch[i].cus_dialogID == message.dialogID {
                    let dict : [String : Any?] = ["cus_msg_inbox" : 1]
                    RealmServices.shared.update(customersDataSearch[i], with: dict)
                    
                    APIRequest.onUpdateNewMessageCustomer(customer: customersDataSearch[i]) { (success) in
                        if success {
                            if let className = vc?.className {
                                if className == "MainVC" {
                                    if i >= self.tblMain.numberOfRows(inSection: 0) {
                                        self.tblMain.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                                    }
                                }
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                    break
                }
            }
        } else {
            for i in 0 ..< customersData.count {
                if customersData[i].cus_dialogID == message.dialogID {
                    let dict : [String : Any?] = ["cus_msg_inbox" : 1]
                    RealmServices.shared.update(customersData[i], with: dict)
                
                    APIRequest.onUpdateNewMessageCustomer(customer: customersData[i]) { (success) in
                        if success {
                            if let className = vc?.className {
                                if className == "MainVC" {
                                    if i >= self.tblMain.numberOfRows(inSection: 0) {
                                        self.tblMain.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                                    }
                                }
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                    break
                }
            }
        }
    }
    
    func chatRoomDidReceive(_ message: ChatMessage, fromDialogID dialogID: String) {
        self.receive(message)
    }
    
    func chatDidReceive(_ message: ChatMessage) {
        self.receive(message)
    }
}

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIViewController {
    var className: String {
        return NSStringFromClass(self.classForCoder).components(separatedBy: (".")).last!
    }
}
