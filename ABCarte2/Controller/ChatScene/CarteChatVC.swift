//
//  CarteChatVC.swift
//  ABCarte2
//
//  Created by long nguyen on 6/19/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import ConnectyCube
import SDWebImage

class CarteChatVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var viewChat: UIView!
    //top
    @IBOutlet weak var imvCusTop: UIImageView!
    @IBOutlet weak var lblCusNameTop: UILabel!
    @IBOutlet weak var lblCusVisitTop: UILabel!
    
    //middle
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lblCusNo: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var viewGender: RoundUIView!
    @IBOutlet weak var lblCusStatus: UILabel!
    @IBOutlet weak var lblLastVisit: UILabel!
    @IBOutlet weak var lblFirstVisit: UILabel!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblBirthdate: UILabel!
    @IBOutlet weak var lblBloodType: UILabel!
    @IBOutlet weak var btnMemo1: RoundButton!
    @IBOutlet weak var btnMemo2: RoundButton!
    @IBOutlet weak var btnSecretMemo: RoundButton!
    @IBOutlet weak var lblLastVisitTitle: UILabel!
    @IBOutlet weak var lblFirstVisitTitle: UILabel!
    @IBOutlet weak var lblHobbyTitle: UILabel!
    @IBOutlet weak var lblContactNoTitle: UILabel!
    @IBOutlet weak var lblBirthdayTitle: UILabel!
    @IBOutlet weak var lblBloodTypeTitle: UILabel!
    @IBOutlet weak var lblCusNoTitle: UILabel!
    @IBOutlet weak var lblCusEditTitle: UILabel!
    @IBOutlet weak var cusView: GradientView!
    @IBOutlet weak var btnQR: UIButton!
    
    //Variable
    var accountsData = AccountData()
    var customerData = CustomerData()
    var cartesData  = [CarteData]()
    weak var chatDialog: ChatDialog?
    var accID: UInt?
    var cusID: UInt?
    var cusPass: String?
    var cusName: String?
    var firstCreated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupLayout()
        onRequestLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cartesData.removeAll()
    }
    
    fileprivate func onRequestLogin() {
        guard let accID = GlobalVariables.sharedManager.account_chat else { return }
        SVProgressHUD.show(withStatus: "読み込み中")
        ConnectyCubeRequest.onLogin(user: accID, pass: "abcd1234") { (status, user) in
            if status == 1 {
                //login success
                Profile.currentProfile = user
                self.accID = Profile.currentProfile?.id
                self.onCheckCustomerChatAccount()
            } else if status == 3 {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "サーバーと接続できませんでした。ネットワークを確認してください。", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "再接続", style: .default) { UIAlertAction in
                    self.onRequestLogin()
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
        }
    }
    
    fileprivate func onCheckCustomerChatAccount() {
        ConnectyCubeRequest.onRetrieveUser(user: String(customerData.id)) { (success, user) in
            if success {
                //retrieve customer success
                self.cusID = user.id
                self.cusPass = user.customData
                self.cusName = user.fullName
                self.onConnectToChat()
            } else {
                SVProgressHUD.dismiss()
                
                let alert = UIAlertController(title: MSG_ALERT.kALERT_CUSTOMER_CHAT_ACCOUNT_NOT_EXISTED, message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    if String(self.customerData.last_name + " " + self.customerData.first_name) != "" {
                        SVProgressHUD.show(withStatus: "読み込み中")
                        ConnectyCubeRequest.onCreateUser(login: String(self.customerData.id), pass: Utils.onGenerateRandomPassword(length: 8), email: "", fullName: String(self.customerData.last_name + " " + self.customerData.first_name), tags: [], completion: { (success, user) in
                            if success {
                                self.firstCreated = true
                                self.cusID = user.id
                                self.cusPass = user.customData
                                self.cusName = user.fullName
                                self.onConnectToChat()
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CREATE_CUSTOMER_CHAT_ACCOUNT, view: self)
                                SVProgressHUD.dismiss()
                            }
                        })
                    }
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func onConnectToChat() {
        guard let accID = accID else { return }
        ConnectyCubeRequest.onConnectToChat(userID: accID, pass: "abcd1234") { (success) in
            if success {
                //connect chat success
                self.onCreate1vs1Dialog()
            } else {
                SVProgressHUD.dismiss()
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CONNECT_CHAT, view: self)
            }
        }
    }
    
    fileprivate func onCreateShopAccount() {
        let alert = UIAlertController(title: "メッセージを送信するための店舗アカウントを作成しますか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            //add loading view
            if self.accountsData.acc_name != "" {
                SVProgressHUD.show(withStatus: "読み込み中")
                
                ConnectyCubeRequest.onCreateUser(login: self.accountsData.account_id, pass: "abcd1234", email: "", fullName: self.accountsData.acc_name, tags: [], completion: { (success, id) in
                    if success {
                        self.onRequestLogin()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CREATE_CUSTOMER_CHAT_ACCOUNT, view: self)
                        SVProgressHUD.dismiss()
                    }
                })
            }
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func onCreate1vs1Dialog() {
        guard let cusID = cusID,let accID = accID else { return }
        ConnectyCubeRequest.onOpen1vs1Chat(with: NSNumber(value: cusID),imgDescription: customerData.pic_url) { (success,dialog) in
            if success {
                //open 1vs1 chat success
                self.chatDialog = dialog
                
                let news = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                news.hostID = accID
                news.customer = self.customerData
                news.view.frame = self.viewChat.bounds
                news.dialog = dialog
                news.imgAvatar = self.customerData.thumb
                news.didMove(toParent: self)
                news.delegate = self
                self.viewChat.addSubview(news.view)
                self.viewChat.layer.cornerRadius = 5
                self.viewChat.clipsToBounds = true
                self.addChild(news)
                
                if self.firstCreated == true {
                    self.onOpenQRCode()
                    self.firstCreated = false
                }
                
                var changed = false
                //check inbox msg
                if self.customerData.cus_msg_inbox > 0 {
                    let dict : [String : Any?] = ["cus_msg_inbox" : 0]
                    RealmServices.shared.update(self.customerData, with: dict)
                    changed = true
                }
                
                //check cus Dialog exists or not
                if self.customerData.cus_dialogID == "" {
                    let dict : [String : Any?] = ["cus_dialogID" : dialog.id!]
                    RealmServices.shared.update(self.customerData, with: dict)
                    changed = true
                }
                
                if changed {
                    //on Update Customer Dialog ID to Customer Data
                    APIRequest.onUpdateCustomer(customer: self.customerData) { (success) in
                        if success {
                            //update success
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_UPDATE_CUSTOMER_INFO_FAIL, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    SVProgressHUD.dismiss()
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CONNECT_FACE2FACE_CHAT, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    fileprivate func onGetDialogData() {
        guard let id = chatDialog?.id else { return }
        ConnectyCubeRequest.onGetChatHistory(with: id) { (success) in
            if success {
                //get chat history success
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CHAT_HISTORY, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func onRequestLogout(completion:@escaping(Bool) -> ()) {
        ConnectyCubeRequest.onDisconnectChat { (success) in
            if success {
                ConnectyCubeRequest.onLogout(completion: { (success) in
                    if success {
                        completion(true)
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_DISCONNECT_CHAT, view: self)
                        completion(false)
                    }
                })
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_DISCONNECT_CHAT, view: self)
                completion(false)
            }
        }
    }
    
    fileprivate func setupLayout() {
        //set navigation bar title
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Message", comment: "")
        //back button
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        updateTopView()
        localizeLanguage()
    }
    
    fileprivate func updateTopView() {
        if customerData.thumb != "" {
            let url = URL(string: customerData.thumb)
            imvCus.sd_setImage(with: url, completed: nil)
            imvCusTop.sd_setImage(with: url, completed: nil)
        } else {
            imvCus.image = UIImage(named: "img_no_photo")
            imvCusTop.image = UIImage(named: "img_no_photo")
        }
        
        imvCusTop.layer.cornerRadius = 25
        imvCusTop.clipsToBounds = true
        lblCusNameTop.text = customerData.last_name + " " + customerData.first_name
        
        if customerData.gender == 0 {
            lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
            viewGender.backgroundColor = UIColor.lightGray
        } else if customerData.gender == 1 {
            lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: "")
            viewGender.backgroundColor = COLOR_SET.kMALE_COLOR
        } else {
            lblGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: "")
            viewGender.backgroundColor = COLOR_SET.kFEMALE_COLOR
        }
        
        lblCusNo.text = customerData.customer_no
        lblHobby.text = customerData.hobby
        lblMobileNo.text = customerData.urgent_no
        
        if customerData.birthday != 0 {
            let birthday = Utils.convertUnixTimestamp(time: customerData.birthday)
            lblBirthdate.text = birthday
        } else {
            lblBirthdate.text = ""
        }
        
        lblBloodType.text = Utils.checkBloodType(type: customerData.bloodtype)
        
        if customerData.last_daycome != 0 {
            let ldayCome = Utils.convertUnixTimestamp(time: customerData.last_daycome)
            lblLastVisit.text = ldayCome
            lblCusVisitTop.text = ldayCome
        } else {
            lblLastVisit.text = ""
            lblCusVisitTop.text = ""
        }
        
        if customerData.first_daycome != 0 {
            let fdayCome = Utils.convertUnixTimestamp(time: customerData.first_daycome)
            lblFirstVisit.text = fdayCome
        } else {
            lblFirstVisit.text = ""
        }
        
        if customerData.memo1.count > 0 {
            Utils.setButtonColorStyle(button: btnMemo1,type: 0)
        } else {
            btnMemo1.backgroundColor = UIColor.lightGray
        }
        
        if customerData.memo2.count > 0 {
            Utils.setButtonColorStyle(button: btnMemo2,type: 0)
        } else {
            btnMemo2.backgroundColor = UIColor.lightGray
        }
        
        if customerData.onSecret == 1 {
            Utils.setButtonColorStyle(button: btnSecretMemo,type: 0)
        } else {
            btnSecretMemo.backgroundColor = UIColor.lightGray
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            btnSecretMemo.isHidden = false
        } else {
            btnSecretMemo.isHidden = true
        }
        
        //Cus Status
        lblCusStatus.layer.cornerRadius = 5
        lblCusStatus.layer.backgroundColor = COLOR_SET000.kSELECT_BACKGROUND_COLOR.cgColor
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCustomerFlag.rawValue) {
            lblCusStatus.isHidden = false
        }
        
        switch customerData.cus_status {
        case 1:
            lblCusStatus.text = "非表示"
            lblCusStatus.textColor = UIColor.lightGray
        case 2:
            lblCusStatus.text = "問題有"
            lblCusStatus.textColor = COLOR_SET.kRED
        case 3:
            lblCusStatus.text = "お試し"
            lblCusStatus.textColor = COLOR_SET.kGREEN
        case 4:
            lblCusStatus.text = "リピート"
            lblCusStatus.textColor = COLOR_SET.kORANGE
        case 5:
            lblCusStatus.text = "VIP"
            lblCusStatus.textColor = COLOR_SET.kYELLOW
        default:
            lblCusStatus.isHidden = true
            break
        }
        
        btnQR.layer.cornerRadius = 10
        btnQR.clipsToBounds = true
        btnEdit.layer.cornerRadius = 10
        btnEdit.clipsToBounds = true
        Utils.setButtonColorStyle(button: btnEdit, type: 1)
        Utils.setButtonColorStyle(button: btnQR, type: 1)
        
        if let set = UserPreferences.appColorSet {
            switch set {
            case AppColorSet.standard.rawValue:
                cusView.topColor = COLOR_SET000.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET000.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.jbsattender.rawValue:
                cusView.topColor = COLOR_SET001.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET001.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.romanpink.rawValue:
                cusView.topColor = COLOR_SET002.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET002.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.hisul.rawValue:
                cusView.topColor = COLOR_SET003.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET003.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.lavender.rawValue:
                cusView.topColor = COLOR_SET004.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET004.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.pinkgold.rawValue:
                cusView.topColor = COLOR_SET005.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET005.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.mysteriousnight.rawValue:
                cusView.topColor = COLOR_SET006.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET006.kHEADER_BACKGROUND_COLOR_DOWN
            case AppColorSet.gardenparty.rawValue:
                cusView.topColor = COLOR_SET007.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET007.kHEADER_BACKGROUND_COLOR_DOWN
            default:
                break
            }
        }
    }
    
    fileprivate func localizeLanguage() {
        lblLastVisitTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Last Visited", comment: "")
        lblFirstVisitTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "First Visited", comment: "")
        lblHobbyTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Hobby", comment: "")
        lblContactNoTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Contact", comment: "")
        lblBirthdayTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Birthdate", comment: "")
        lblBloodTypeTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Blood Type", comment: "")
        lblCusNoTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cus's No", comment: "")
        
        btnMemo1.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Note 1", comment: ""), for: .normal)
        btnMemo2.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Note 2", comment: ""), for: .normal)
        
        lblCusEditTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "View / Edit", comment: "")
    }
    
    @objc func back(sender: UIBarButtonItem) {
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onEdit(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.customer = customerData
            vc.popupType = PopUpType.Edit.rawValue
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onQRGenerate(_ sender: UIButton) {
        ConnectyCubeRequest.onRetrieveUser(user: String(customerData.id)) { (success, user) in
            if success {
                //retrieve customer success
                self.cusID = user.id
                self.cusPass = user.customData
                self.cusName = user.fullName
                self.onOpenQRCode()
            } else {
                SVProgressHUD.dismiss()
                
                let alert = UIAlertController(title: MSG_ALERT.kALERT_CUSTOMER_CHAT_ACCOUNT_NOT_EXISTED, message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    if String(self.customerData.last_name + " " + self.customerData.first_name) != "" {
                        SVProgressHUD.show(withStatus: "読み込み中")
                        
                        ConnectyCubeRequest.onCreateUser(login: String(self.customerData.id), pass: Utils.onGenerateRandomPassword(length: 8), email: "", fullName: String(self.customerData.last_name + " " + self.customerData.first_name), tags: [], completion: { (success, user) in
                            SVProgressHUD.dismiss()
                            if success {
                                self.firstCreated = true
                                self.cusID = user.id
                                self.cusPass = user.customData
                                self.cusName = user.fullName
                                self.onOpenQRCode()
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_CREATE_CUSTOMER_CHAT_ACCOUNT, view: self)
                            }
                        })
                    }
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func onOpenQRCode() {
        guard let newPopup = GeneratedQRCodePopupVC(nibName: "GeneratedQRCodePopupVC", bundle: nil) as GeneratedQRCodePopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 500, height: 850)
        
        if cusPass == nil || cusPass == "" {
            cusPass = "abcd1234"
        }
        
        guard let accID = GlobalVariables.sharedManager.account_chat else { return }
        let qrString = String(accID) + "-" + String(self.customerData.id) + "-" + cusPass!
        newPopup.imgQR = Utils.onGenerateQRCode(from: qrString)
        newPopup.shopID = accID
        newPopup.userID = String(self.customerData.id)
        newPopup.userPassword = cusPass
        newPopup.accountData = accountsData
        self.present(newPopup, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - RegCustomerPopup Delegate
//*****************************************************************

extension CarteChatVC: RegCustomerPopupDelegate {
    func didConfirm(type:Int) {
        let realm = RealmServices.shared.realm
        if let customerDB = realm.objects(CustomerData.self).filter("id == \(customerData.id)").first {
            self.customerData = customerDB
            self.updateTopView()
        }
    }
}

//*****************************************************************
// MARK: - ChatVC Delegate
//*****************************************************************

extension CarteChatVC: ChatVCDelegate {
    func onAddNewCarte(time: Int, staff_name: String, bed_name: String, mediaData: Data) {
        var isAllow: Bool = true
        
        let dateAdd = Date(timeIntervalSince1970: TimeInterval(time))
        for i in 0 ..< cartesData.count {
            let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
            let isSame = date.isInSameDay(date: dateAdd)
            if isSame {
                isAllow = false
            }
        }
        
        if isAllow {
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            APIRequest.addCarte(cusID: self.customerData.id, date: time,staff_name:staff_name,bed_name:bed_name,mediaData: mediaData) { (success) in
                if success == 1 {
                    Utils.showAlert(message: MSG_ALERT.kALERT_ADD_KARTE_SUCCESS, view: self)
                } else if success == 2 {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
        }
    }
    
    func onUpdateCarte(mediaData: Data) {
        guard let newPopup = CarteListPopupVC(nibName: "CarteListPopupVC", bundle: nil) as CarteListPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 400, height: 500)
        newPopup.cartesData = cartesData
        newPopup.mediaData = mediaData
        self.present(newPopup, animated: true, completion: nil)
    }
}
