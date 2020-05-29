//
//  LoginVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import BarcodeScanner
import TransitionButton
import RealmSwift

class LoginVC: UIViewController {

    //Variable
    var isLogin: Bool?
    var appVersion: String?
    var iosVersion: String?
    var ipadModel: String?
    var appID: Int = 0
    
    // IBOutlet
    @IBOutlet weak var btnLogin: TransitionButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnQRLogin: TransitionButton!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var imvBackground: UIImageView!
    @IBOutlet weak var lblTitleLogin: UILabel!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var lblOtherWay: UILabel!
    @IBOutlet weak var btnWebsite: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupData()
    }
    
    //show popup permission
    override func viewDidAppear(_ animated: Bool) {
        //check app permissions
        let check = checkPermission()
        if !check {
            SPPermission.Dialog.request(with: [.camera,.photoLibrary,.notification], on: self)
        }
    }
    
    private func checkPermission()->Bool {
        let isAllowedCamera = SPPermission.isAllowed(.camera)
        let isAllowedPhoto = SPPermission.isAllowed(.photoLibrary)
        let isAllowedNotification = SPPermission.isAllowed(.notification)
        
        if isAllowedCamera && isAllowedPhoto && isAllowedNotification {
            return true
        }
        return false
    }
    
    private func loadImageData(url:String,name:String) {
        Utils.saveImage(urlString: url, fileName: name) { (success) in
            if success {
                Utils.showSavedImage(url: url, fileName: name) { (url) in
                    self.imvBackground.image = UIImage(contentsOfFile: url)
                }
            }
        }
    }
  
    private func setupLayout() {
        //set template and color
        #if SERMENT
        UserPreferences.appColorSet = AppColorSet.romanpink.rawValue
        loadImageData(url: Constants.SERMENT.LOGIN_BACKGROUND_URL, name: Constants.SERMENT.LOGIN_BACKGROUND_NAME)
        lblVersion.textColor = UIColor.black
        btnFacebook.isEnabled = false
        appID = 2
        #elseif SHISEI
        UserPreferences.appColorSet = AppColorSet.pinkgold.rawValue
        loadImageData(url: Constants.SHISEI.LOGIN_BACKGROUND_URL, name: Constants.SHISEI.LOGIN_BACKGROUND_NAME)
        lblVersion.textColor = UIColor.black
        appID = 4
        #elseif AIMB
        UserPreferences.appColorSet = AppColorSet.jbsattender.rawValue
        loadImageData(url: Constants.AIMB.LOGIN_BACKGROUND_URL, name: Constants.AIMB.LOGIN_BACKGROUND_NAME)
        lblVersion.textColor = UIColor.black
        btnFacebook.isEnabled = false
        appID = 6
        #elseif ESCOS
        UserPreferences.appColorSet = AppColorSet.romanpink.rawValue
        loadImageData(url: Constants.ESCOS.LOGIN_BACKGROUND_URL, name: Constants.ESCOS.LOGIN_BACKGROUND_NAME)
        lblVersion.textColor = UIColor.black
        btnFacebook.isEnabled = false
        appID = 5
        #elseif COVISION
        UserPreferences.appColorSet = AppColorSet.lavender.rawValue
        loadImageData(url: Constants.COVISION.LOGIN_BACKGROUND_URL, name: Constants.COVISION.LOGIN_BACKGROUND_NAME)
        btnWebsite.isEnabled = false
        btnFacebook.isEnabled = false
        appID = 8
        #elseif COLLECTU
        UserPreferences.appColorSet = AppColorSet.hisul.rawValue
        loadImageData(url: Constants.COLLECTU.LOGIN_BACKGROUND_URL, name: Constants.COLLECTU.LOGIN_BACKGROUND_NAME)
        lblVersion.textColor = UIColor.black
        btnFacebook.isEnabled = false
        btnWebsite.isEnabled = false
        appID = 10
        #elseif MIRAIKARTE
        UserPreferences.appColorSet = AppColorSet.gardenparty.rawValue
        loadImageData(url: Constants.MIRAIKARTE.LOGIN_BACKGROUND_URL, name: Constants.MIRAIKARTE.LOGIN_BACKGROUND_NAME)
        lblVersion.textColor = UIColor.black
        btnFacebook.isEnabled = false
        btnWebsite.isEnabled = false
        appID = 7
        #elseif ATTENDER
        UserPreferences.appColorSet = AppColorSet.jbsattender.rawValue
        loadImageData(url: Constants.JBS.LOGIN_BACKGROUND_URL, name: Constants.JBS.LOGIN_BACKGROUND_NAME)
        appID = 1
        #endif
        
        //set ja language first
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "ja")
        localizeLanguage()
    }
    
    fileprivate func setupData() {
        
        //remove old chat data
        Cache.removeAll()
        
        //Set login status
        isLogin = false
        
        //remove hierarchy
        GlobalVariables.sharedManager.hierarchyList.removeAll()
        UserPreferences.appHierarchy = AppHierarchy.unopen.rawValue
        
        //get App version
        appVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        lblVersion.text = "VER \(appVersion ?? "")"
        //get iOS version
        iosVersion = UIDevice.current.systemVersion
        //get ipad Model
        let deviceType = UIDevice().type
        ipadModel = deviceType.rawValue
        
        //Check previous username
        if let status = UserPreferences.accStatus {
            if status == AccStatus.login.rawValue {
                if let userN = UserDefaults.standard.string(forKey: "collectu-usr") {
                    tfUsername.text = userN
                } else {
                    tfUsername.text = ""
                }
                
                if let userP = UserDefaults.standard.string(forKey: "collectu-pwd") {
                    tfPassword.text = userP
                } else {
                    tfPassword.text = ""
                }
            } else {
                if let userN = UserDefaults.standard.string(forKey: "collectu-usr") {
                    tfUsername.text = userN
                } else {
                    tfUsername.text = ""
                }
            }
        } else {
            tfUsername.text = ""
            tfPassword.text = ""
        }
    }
    
    fileprivate func localizeLanguage() {
        lblTitleLogin.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "LOGIN", comment: "")
        lblOr.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "OR", comment: "")
        lblOtherWay.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Other ways to contact us", comment: "")
        btnLogin.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LOGIN", comment: ""), for: .normal)
        btnQRLogin.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LOGIN BY QR CODE", comment: ""), for: .normal)
        tfUsername.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input User ID", comment: "")
        tfPassword.placeholder = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please input Password", comment: "")
    }
    
    fileprivate func goNextPage() {
        SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onCustomerDeviceInfoTracking { (success, msg) in
            self.isLogin = false
            if success {
                #if SERMENT || SHISEI || ESCOS || COLLECTU || MIRAIKARTE || COVISION
                if let story: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? {
                    if let mainPageView =  story.instantiateViewController(withIdentifier: Constants.VC_ID.MAIN) as? MainVC {
                        let navController = UINavigationController(rootViewController: mainPageView)
                        navController.navigationBar.tintColor = UIColor.white
                        navController.modalPresentationStyle = .fullScreen
                        self.present(navController, animated: true, completion: nil)
                    }
                }
                #elseif AIMB
                guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: Constants.VC_ID.APP_SELECT_AIMB) as? AppSelectAIMBVC else { return }
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                #else
                if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kJBS.rawValue) {
                    guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: Constants.VC_ID.APP_SELECT) as? AppSelectVC else { return }
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                } else {
                    if let story: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? {
                        if let mainPageView =  story.instantiateViewController(withIdentifier: Constants.VC_ID.MAIN) as? MainVC {
                            let navController = UINavigationController(rootViewController: mainPageView)
                            navController.navigationBar.tintColor = UIColor.white
                            navController.modalPresentationStyle = .fullScreen
                            self.present(navController, animated: true, completion: nil)
                        }
                    }
                }
                #endif
            } else {
                Utils.showAlert(message: msg, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func callNumber(phoneNumber:String) {
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    fileprivate func confirmAgain2Login(comName:String) {
        var alert = UIAlertController.init()
        let title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "LOGIN WITH USERNAME", comment: "")
        
        if LocalizationSystem.sharedInstance.getLanguage() == "en" {
            alert = UIAlertController(title: "\(title) \(comName)", message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "ユーザー名：\(comName) \(title)", message: nil, preferredStyle: .alert)
        }
        
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .default, handler: nil)
        let confirm = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "OK", comment: ""), style: .default) { UIAlertAction in
            let realm = try! Realm()
            let accounts = realm.objects(AccountData.self)
            SVProgressHUD.show(withStatus: "読み込み中")
            APIRequest.onGetLatestAppVersion(appID: self.appID) { (success) in
                if success {
                    //check parent account existed or not
                    if accounts[0].parent_sub_acc != "" {
                        APIRequest.onGetRootAccount(accountID: accounts[0].id) { (success) in
                            SVProgressHUD.dismiss()
                            if success {
                                self.goNextPage()
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
                            }
                        }
                    } else {
                        SVProgressHUD.dismiss()
                        GlobalVariables.sharedManager.account_chat = accounts[0].account_id
                        self.goNextPage()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func stopLoginProcess(message: String,type:Int) {
        self.isLogin = false
        
        switch type {
        case 1:
            self.btnLogin.stopAnimation()
        case 2:
            self.btnQRLogin.stopAnimation()
        default:
            break
        }
        Utils.showAlert(message: message, view: self)
    }
    
    fileprivate func confirm2LoginbyQR(user:String,pass:String,completion:@escaping(Bool) -> ()) {
        
        self.isLogin = true
        guard let appV = self.appVersion, let iosV = self.iosVersion, let ipadModel = self.ipadModel else { return }
        self.btnQRLogin.startAnimation()
        
        APIRequest.QRauthenticateServer(accID: user) { (success, msg) in
            if success {
                APIRequest.authenticateServer(accID: user, accPassword: pass,appVer: appV,iOSVer: iosV,ipadModel: ipadModel) { (success, msg) in
                    if success {
                        self.btnQRLogin.stopAnimation()
                        self.isLogin = false
                        completion(true)
                    } else {
                        self.stopLoginProcess(message: msg,type: 2)
                        completion(false)
                    }
                }
            } else {
                self.stopLoginProcess(message: msg,type: 2)
                completion(false)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    //handle login process
    @IBAction func onLoginSelect(_ sender: TransitionButton) {
        let check = checkPermission()
        if !check {
            SPPermission.Dialog.request(with: [.camera,.photoLibrary,.notification], on: self)
            return
        }
        
        if isLogin == false {
            isLogin = true
            guard let appV = appVersion, let iosV = iosVersion, let ipadModel = ipadModel else { return }
            sender.startAnimation()
            APIRequest.authenticateServer(accID: tfUsername.text!, accPassword: tfPassword.text!,appVer: appV,iOSVer: iosV,ipadModel:ipadModel) { (success, msg) in
                if success {
                    let realm = try! Realm()
                    let accounts = realm.objects(AccountData.self)
                    APIRequest.onGetLatestAppVersion(appID: self.appID) { (success) in
                        if success {
                            //check parent account existed or not
                            if accounts[0].parent_sub_acc != "" {
                                APIRequest.onGetRootAccount(accountID: accounts[0].id) { (success) in
                                    if success {
                                        self.goNextPage()
                                    } else {
                                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
                                    }
                                    sender.stopAnimation()
                                }
                            } else {
                                GlobalVariables.sharedManager.account_chat = accounts[0].account_id
                                self.goNextPage()
                                sender.stopAnimation()
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
                            self.stopLoginProcess(message: msg,type: 1)
                        }
                    }
                } else {
                    self.stopLoginProcess(message: msg,type: 1)
                }
            }
        }
    }
    
    //open QR View Controller
    @IBAction func onQRLoginSelect(_ sender: UIButton) {
        let check = checkPermission()
        if !check {
            SPPermission.Dialog.request(with: [.camera,.photoLibrary,.notification], on: self)
            return
        }
        
        if isLogin == false { 
            guard let controller = BarcodeScannerViewController() as BarcodeScannerViewController? else { return }
            controller.codeDelegate = self
            controller.errorDelegate = self
            controller.dismissalDelegate = self
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    //redirect to website
    @IBAction func onWebsiteSelect(_ sender: UIButton) {
        #if SERMENT
        UIApplication.tryURL(urls: [Constants.SERMENT.WEBSITE_URL])
        #elseif SHISEI
        UIApplication.tryURL(urls: [Constants.SHISEI.WEBSITE_URL])
        #elseif AIMB
        UIApplication.tryURL(urls: [Constants.AIMB.WEBSITE_URL])
        #elseif ESCOS
        UIApplication.tryURL(urls: [Constants.ESCOS.WEBSITE_URL])
        #elseif ATTENDER
        UIApplication.tryURL(urls: [Constants.JBS.WEBSITE_URL])
        #endif
    }
    
    //call by phone
    @IBAction func onFacebookSelect(_ sender: UIButton) {
        var appURL = ""
        var webURL = ""
        #if SHISEI
        appURL = Constants.SHISEI.FACEBOOK_APP_URL
        webURL = Constants.SHISEI.FACEBOOK_WEB_URL
        #elseif ATTENDER
        appURL = Constants.JBS.FACEBOOK_APP_URL
        webURL = Constants.JBS.FACEBOOK_WEB_URL
        #endif
        UIApplication.tryURL(urls: [
            appURL, // App
            webURL // Website if app fails
            ])
    }
    
    @IBAction func onCallSelect(_ sender: UIButton) {
        callNumber(phoneNumber: Constants.CONTACT_SUPPORT_PHONE)
    }
}

//*****************************************************************
// MARK: - Barcode Delegate
//*****************************************************************

extension LoginVC:BarcodeScannerDismissalDelegate,BarcodeScannerCodeDelegate,BarcodeScannerErrorDelegate {
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        if code.contains("-") {
            let token = code.components(separatedBy: "-")
            let user = token[0]
            let pass = token[1]
            
            controller.dismiss(animated: true) {
                self.confirm2LoginbyQR(user: user, pass: pass, completion: { (success) in
                    if success {
                        if let kaishaN = GlobalVariables.sharedManager.comName {
                            self.confirmAgain2Login(comName: kaishaN)
                        } else {
                            self.confirmAgain2Login(comName: user)
                        }
                    }
                })
            }
        } else {
            controller.dismiss(animated: true) {
                Utils.showAlert(message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "WRONG QR CODE", comment: ""), view: self)
            }
        }
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}
