//
//  BaseVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/26.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class BaseVC: UIViewController,BottomPanelViewDelegate {
    
    //Variable
    weak var bottomPanelView: BottomPanelView!
    lazy var realm = try! Realm()
    var accounts: Results<AccountData>!
    var textField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData()
    }
    
    private func setupUI() {
        bottomPanelView = BottomPanelView.instanceFromNib(self)
        view.addSubview(bottomPanelView)
        bottomPanelView.snp.makeConstraints { (make) -> Void in
            make.height.height.equalTo(50)
            make.leading.equalTo(self.view).inset(0)
            make.trailing.equalTo(self.view).inset(0)
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin)
            } else {
                make.bottom.equalTo(self.view)
            }
        }

        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShop.rawValue) {
            bottomPanelView.viewHierarchy.isHidden = false
        } else {
            bottomPanelView.viewHierarchy.isHidden = true
        }
        
        bottomPanelView.updateLocalize()
        bottomPanelView.updateLayout()
    }
    
    private func loadData() {
        self.accounts = realm.objects(AccountData.self)
    }
    
    func tapSetting() {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)

        //user
        let user = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Account", comment: ""), style: .default) { UIAlertAction in
            guard let newPopup = UserInfoPopupVC(nibName: "UserInfoPopupVC", bundle: nil) as UserInfoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet

            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
                newPopup.preferredContentSize = CGSize(width: 400, height: 700)
            } else {
                newPopup.preferredContentSize = CGSize(width: 400, height: 600)
            }
            
            newPopup.accountsData = self.accounts[0]
            self.present(newPopup, animated: true, completion: nil)
        }

        //device
        let device = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Device", comment: ""), style: .default) { UIAlertAction in
            guard let newPopup = DeviceInfoPopupVC(nibName: "DeviceInfoPopupVC", bundle: nil) as DeviceInfoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 400)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        }

        //secret
        let secret = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Secret Memo", comment: ""), style: .default) { UIAlertAction in
            guard let newPopup = SecretMemoSettingPopupVC(nibName: "SecretMemoSettingPopupVC", bundle: nil) as SecretMemoSettingPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 380, height: 280)
            self.present(newPopup, animated: true, completion: nil)
        }

        //language
        let language = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Language", comment: ""), style: .default) { UIAlertAction in
            self.bottomPanelView.updateLocalize()
            self.languagePop()
        }

        //color style
        let colorStyle = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Theme", comment: ""), style: .default) { UIAlertAction in
            guard let newPopup = ColorStylePopupVC(nibName: "ColorStylePopupVC", bundle: nil) as ColorStylePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 380, height: 500)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        }
        
        let db = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "DB設定", comment: ""), style: .default) { UIAlertAction in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Database", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "DatabaseVC") as? DatabaseVC {
                viewController.dataType = .company
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        alert.addAction(user)
        alert.addAction(device)
        alert.addAction(db)
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            alert.addAction(secret)
        }

        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMultiLanguage.rawValue) {
            alert.addAction(language)
        }

        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMultiTheme.rawValue) {
            alert.addAction(colorStyle)
        }
        alert.addAction(cancel)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tapInfo() {
        guard let newPopup = AppInfoPopupVC(nibName: "AppInfoPopupVC", bundle: nil) as AppInfoPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 350, height: 350)
        newPopup.currentVer = accounts[0].needUpdate
        newPopup.urlLink = accounts[0].linkUpdate
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func tapRefresh() {
        onRefreshData()
    }
    
    func languagePop() {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        
        let english = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "English", comment: ""), style: .default) { UIAlertAction in
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
            self.onLanguageChange()
        }
        let japanese = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Japanese", comment: ""), style: .default) { UIAlertAction in
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "ja")
            self.onLanguageChange()
        }
        let chinese = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Chinese", comment: ""), style: .default) { UIAlertAction in
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "zh-Hans")
            self.onLanguageChange()
        }
        
        alert.addAction(cancel)
        alert.addAction(english)
        alert.addAction(japanese)
        alert.addAction(chinese)

        self.present(alert, animated: true, completion: nil)
    }
    
    func tapStamp() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "OtherSettingVC") as? OtherSettingVC {
            if let navigator = self.navigationController {
                viewController.maxStamp = accounts[0].acc_stamp_memo_max
                GlobalVariables.sharedManager.currentIndex = nil
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func tapMsgTemp() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Messenger", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "MessageTemplateVC") as? MessageTemplateVC {
            viewController.accountData = accounts[0]
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func tapHierarchy() {
        APIRequest.getAccountHierarchyWithAlliance(accountID: accounts[0].id) { (success,treeData) in
            if success {
                if treeData.count > 0 {
                    guard let newPopup = HierarchyPopup(nibName: "HierarchyPopup", bundle: nil) as HierarchyPopup? else { return }
                    newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    newPopup.preferredContentSize = CGSize(width: 400, height: 700)
                    newPopup.accountsData = self.accounts[0]
                    newPopup.treeData = treeData
                    newPopup.type = 1
                    newPopup.delegate = self
                    self.present(newPopup, animated: true, completion: nil)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_DONT_HAVE_BRANCH, view: self)
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
        }
    }
}

//*****************************************************************
// MARK: - Popup Delegate
//*****************************************************************

extension BaseVC: ColorStylePopupVCDelegate,DeviceInfoPopupVCDelegate,HierarchyPopupDelegate {
    @objc func onUpdateHierarchyData(arrIDs: [Int]) {}
    @objc func onLanguageChange() {}
    @objc func onColorStyleChange() {}
    @objc func onRefreshData() {}
    
    @objc func onEraseDevice() {
        let alert = UIAlertController(title: "", message: MSG_ALERT.kALERT_INPUT_ACCOUNT_PASSWORD, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            guard
                let text = self.textField?.text,
                let device = UserDefaults.standard.string(forKey: "mac_address"),
                let token = UserDefaults.standard.string(forKey: "token") else { return }
            
            APIRequest.onEraseDeviceToken(userName: self.accounts[0].account_id,userPass: text, deviceID: device,token:token, completion: { (success, msg) in
                
                if success {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                    if let vc = storyBoard.instantiateViewController(withIdentifier: Constants.VC_ID.LOGIN) as? LoginVC {
                        vc.modalPresentationStyle = .fullScreen
                        UserPreferences.accStatus = AccStatus.logout.rawValue
                        GlobalVariables.sharedManager.clearData()
                        UserPreferences.removeUserInfo()

                        //Remove Keychain
                        let secItemClasses =  [kSecClassGenericPassword]
                        for itemClass in secItemClasses {
                            let spec: NSDictionary = [kSecClass: itemClass]
                            SecItemDelete(spec)
                        }
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    Utils.showAlert(message: msg, view: self)
                }
                SVProgressHUD.dismiss()
            })
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
        
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "入力して下さい";
        }
    }
}
