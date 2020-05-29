//
//  CarteListVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/10.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SDWebImage
import LGButton

class CarteListVC: BaseVC {
    
    //Variable
    var needLoad: Bool = true
    
    var customer = CustomerData()
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    
    var categories: Results<StampCategoryData>!
    var categoriesData : [String] = []
    
    var documents: Results<DocumentData>!
    var consentData : [DocumentData] = []
    var consentTempData: [DocumentData] = []
    var counsellingData : [DocumentData] = []
    var counsellingTempData : [DocumentData] = []
    var handwrittingData : [DocumentData] = []
    var handwrittingTempData : [DocumentData] = []
    
    var indexDelete : [Int] = []
    var carteID: Int?
    var cellIndex: Int?
    var completionHandler:((String) -> ())?

    //IBOutlet
    @IBOutlet weak var tblCarte: UITableView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var imvCusTop: UIImageView!
    @IBOutlet weak var imvCustomer: UIImageView!
    @IBOutlet weak var lblCusGender: UILabel!
    @IBOutlet weak var lblCusNo: UILabel!
    @IBOutlet weak var lblLastCome: UILabel!
    @IBOutlet weak var lblFirstCome: UILabel!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblBirthdate: UILabel!
    @IBOutlet weak var lblBloodtype: UILabel!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var btnComplete: LGButton!
    @IBOutlet weak var btnAddCarte: LGButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSelect: LGButton!
    @IBOutlet weak var btnDelete: LGButton!
    @IBOutlet weak var btnMemo1: RoundButton!
    @IBOutlet weak var btnMemo2: RoundButton!
    @IBOutlet weak var btnSecret: RoundButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnExchange: UIButton!
    @IBOutlet weak var btnKessai: UIButton!
    @IBOutlet weak var btnContract: UIButton!
    @IBOutlet weak var lblTitleChat: UILabel!
    @IBOutlet weak var lblLastComeTop: UILabel!
    @IBOutlet weak var btnGallery: LGButton!
    @IBOutlet weak var viewPanelTop: UIView!
    @IBOutlet weak var cusView: GradientView!
    @IBOutlet weak var lblCusStatus: UILabel!
    @IBOutlet weak var titleLastVisit: UILabel!
    @IBOutlet weak var titleFirstVisit: UILabel!
    @IBOutlet weak var titleHobby: UILabel!
    @IBOutlet weak var titleContact: UILabel!
    @IBOutlet weak var titleBirthdate: UILabel!
    @IBOutlet weak var titleBloodType: UILabel!
    @IBOutlet weak var titleCusNo: UILabel!
    @IBOutlet weak var titleDisplayEdit: UILabel!
    @IBOutlet weak var titleContract: UILabel!
    @IBOutlet weak var titleKessai: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()  
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
    }

    func loadData() {
        if needLoad == true {
            //add loading view
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
          
            APIRequest.onGetStampCategoryDynamicOrStatic { (success) in
                if success {
                    self.categories = self.realm.objects(StampCategoryData.self)
                    self.categoriesData.removeAll()
                    
                    for i in 0 ..< self.categories.count {
                        self.categoriesData.append(self.categories[i].title)
                    }
                    
                    //get document template
                    APIRequest.onGetDocumentsTemplate(accID: self.customer.fc_account_id) { (success) in
                        if success {
                            self.documents = self.realm.objects(DocumentData.self)
                            self.consentTempData.removeAll()
                            self.counsellingTempData.removeAll()
                            self.handwrittingTempData.removeAll()
                            
                            for i in 0 ..< self.documents.count {
                                
                                if self.documents[i].type == 1 {
                                    if self.documents[i].is_template == 1 {
                                        self.counsellingTempData.append(self.documents[i])
                                    }
                                }
                                
                                if self.documents[i].type == 2 {
                                    if self.documents[i].is_template == 1 {
                                        self.consentTempData.append(self.documents[i])
                                    }
                                }
                                
                                if self.documents[i].type == 3 {
                                    if self.documents[i].is_template == 1 {
                                        self.handwrittingTempData.append(self.documents[i])
                                    }
                                }
                            }
                            
                            APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                                if success {
                                    self.cartes = self.realm.objects(CarteData.self)
                                    self.cartesData.removeAll()
                                    var index = 0
                                    
                                    for i in 0 ..< self.cartes.count {
                                        self.cartesData.append(self.cartes[i])
                                        
                                        if (self.carteID != nil) {
                                            if self.carteID == self.cartes[i].id {
                                                index = i
                                            }
                                        }
                                    }
                                    
                                    self.tblCarte.reloadData()
                                    
                                    if self.cartes.count > 0  {
                                        self.tblCarte.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
                                        }
                                    }
                                
                                    APIRequest.onViewCustomer(cusID: self.customer.id) { (success,cusData)  in
                                        if success {
                                            self.customer = cusData
                                            let realm = RealmServices.shared.realm
                                            let customerDB = realm.objects(CustomerData.self).filter("id == \(cusData.id)").first
                                            try! realm.write {
                                                customerDB?.last_name_kana = self.customer.last_name_kana
                                                customerDB?.first_name_kana = self.customer.first_name_kana
                                                customerDB?.last_name = self.customer.last_name
                                                customerDB?.first_name = self.customer.first_name
                                                customerDB?.urgent_no = self.customer.urgent_no
                                                customerDB?.customer_no = self.customer.customer_no
                                                customerDB?.responsible = self.customer.responsible
                                                customerDB?.gender = self.customer.gender
                                                customerDB?.bloodtype = self.customer.bloodtype
                                                customerDB?.first_daycome = self.customer.first_daycome
                                                customerDB?.last_daycome = self.customer.last_daycome
                                                customerDB?.update_date = self.customer.update_date
                                                customerDB?.pic_url = self.customer.pic_url
                                                customerDB?.birthday = self.customer.birthday
                                                customerDB?.hobby = self.customer.hobby
                                                customerDB?.email = self.customer.email
                                                customerDB?.postal_code = self.customer.postal_code
                                                customerDB?.address1 = self.customer.address1
                                                customerDB?.address2 = self.customer.address2
                                                customerDB?.address3 = self.customer.address3
                                                customerDB?.mail_block = self.customer.mail_block
                                                customerDB?.memo1 = self.customer.memo1
                                                customerDB?.memo2 = self.customer.memo2
                                                customerDB?.created_at = self.customer.created_at
                                                customerDB?.updated_at = self.customer.updated_at
                                                customerDB?.selected_status = self.customer.selected_status
                                                customerDB?.thumb = self.customer.thumb
                                                customerDB?.resize = self.customer.resize
                                                customerDB?.onSecret = self.customer.onSecret
                                                customerDB?.created_at = self.customer.created_at
                                                customerDB?.cus_status = self.customer.cus_status
                                            }
                                            self.updateTopView()
                                        } else {
                                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                        }
                                        SVProgressHUD.dismiss()
                                    }
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                            SVProgressHUD.dismiss()
                        }
                    }
                    
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                    SVProgressHUD.dismiss()
                }
            }
            needLoad = false
        }
    }

    func setupLayout() {
        //set navigation bar title
        let button = LGButton()
        button.leftImageSrc = UIImage(named: "icon_carteview_white.png")
        button.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "List of Karte", comment: "")
        button.titleFontSize = 20.0
        button.bgColor = UIColor.clear
        button.backgroundColor = UIColor.clear
        navigationItem.titleView = button
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        viewGender.layer.cornerRadius = 5
        viewGender.clipsToBounds = true
        viewTop.layer.cornerRadius = 5
        viewTop.clipsToBounds = true

        tblCarte.delegate = self
        tblCarte.dataSource = self
        tblCarte.allowsMultipleSelection = false
        tblCarte.allowsSelection = true

        btnEdit.layer.cornerRadius = 10
        btnEdit.clipsToBounds = true
        btnChat.layer.cornerRadius = 10
        btnChat.clipsToBounds = true
        btnContract.layer.cornerRadius = 10
        btnContract.clipsToBounds = true
        btnExchange.layer.cornerRadius = 5
        btnExchange.clipsToBounds = true
        btnKessai.layer.cornerRadius = 10
        btnKessai.clipsToBounds = true
        
        updateTopView()
        
        localizeLanguage()
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
            btnChat.isHidden = false
            lblTitleChat.isHidden = false
        } else {
            btnChat.isHidden = true
            lblTitleChat.isHidden = true
        }
  
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCustomerSwitch.rawValue) {
            btnExchange.isHidden = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSettlement.rawValue) {
            btnKessai.isHidden = false
            titleKessai.isHidden = false
        }
        
        updateColor()
        bottomPanelView.deactiveBottomPanelButtons()
    }
    
    private func updateColor() {
        guard let navi = navigationController else { return }
        if let set = UserPreferences.appColorSet {
            addNavigationBarColor(navigation: navi, type: set)
        } else {
            addNavigationBarColor(navigation: navi,type: 0)
        }
        
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
        
        Utils.setViewColorStyle(view: viewPanelTop, type: 1)
        Utils.setButtonColorStyle(button: btnEdit, type: 1)
        Utils.setButtonColorStyle(button: btnChat, type: 1)
        Utils.setButtonColorStyle(button: btnContract, type: 1)
        Utils.setButtonColorStyle(button: btnExchange, type: 1)
        Utils.setButtonColorStyle(button: btnKessai, type: 1)
    }
    
    fileprivate func localizeLanguage() {
        btnAddCarte.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Add New", comment: "")
        btnGallery.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "List of Image", comment: "")
        btnSelect.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Select", comment: "")
        btnDelete.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Delete", comment: "")
        btnComplete.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Complete", comment: "")
       
        titleLastVisit.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Last Visited", comment: "")
        titleFirstVisit.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "First Visited", comment: "")
        titleHobby.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Hobby", comment: "")
        titleContact.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Contact", comment: "")
        titleBirthdate.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Birthdate", comment: "")
        titleBloodType.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Blood Type", comment: "")
        titleCusNo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cus's No", comment: "")
        
        btnMemo1.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Note 1", comment: ""), for: .normal)
        btnMemo2.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Note 2", comment: ""), for: .normal)
     
        titleDisplayEdit.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "View / Edit", comment: "")
    }

    fileprivate func updateTopView() {
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCusTop.sd_setImage(with: url, completed: nil)
            imvCustomer.sd_setImage(with: url, completed: nil)
        } else {
            imvCustomer.image = UIImage(named: "img_no_photo")
            imvCusTop.image = UIImage(named: "img_no_photo")
        }

        imvCusTop.layer.cornerRadius = 25
        imvCusTop.clipsToBounds = true
        lblCusName.text = customer.last_name + " " + customer.first_name

        if customer.gender == 0 {
            lblCusGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Undefined", comment: "")
            viewGender.backgroundColor = UIColor.lightGray
        } else if customer.gender == 1 {
            lblCusGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Male", comment: "")
            viewGender.backgroundColor = COLOR_SET.kMALE_COLOR
        } else {
            lblCusGender.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Female", comment: "")
            viewGender.backgroundColor = COLOR_SET.kFEMALE_COLOR
        }

        lblCusNo.text = customer.customer_no
        lblHobby.text = customer.hobby
        lblMobile.text = customer.urgent_no

        if customer.birthday != 0 {
            let birthday = Utils.convertUnixTimestamp(time: customer.birthday)
            lblBirthdate.text = birthday
        } else {
            lblBirthdate.text = ""
        }

        lblBloodtype.text = Utils.checkBloodType(type: customer.bloodtype)

        if customer.last_daycome != 0 {
            let ldayCome = Utils.convertUnixTimestamp(time: customer.last_daycome)
            lblLastCome.text = ldayCome
            lblLastComeTop.text = ldayCome
        } else {
            lblLastCome.text = ""
            lblLastComeTop.text = ""
        }

        if customer.first_daycome != 0 {
            let fdayCome = Utils.convertUnixTimestamp(time: customer.first_daycome)
            lblFirstCome.text = fdayCome
        } else {
            lblFirstCome.text = ""
        }

        if customer.memo1.count > 0 {
            Utils.setButtonColorStyle(button: btnMemo1,type: 0)
        } else {
            btnMemo1.backgroundColor = UIColor.lightGray
        }

        if customer.memo2.count > 0 {
            Utils.setButtonColorStyle(button: btnMemo2,type: 0)
        } else {
            btnMemo2.backgroundColor = UIColor.lightGray
        }

        if customer.onSecret == 1 {
            Utils.setButtonColorStyle(button: btnSecret,type: 0)
        } else {
            btnSecret.backgroundColor = UIColor.lightGray
        }

        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            btnSecret.isHidden = false
        } else {
            btnSecret.isHidden = true
        }
        
        //Cus Status
        lblCusStatus.layer.cornerRadius = 5
        lblCusStatus.layer.backgroundColor = COLOR_SET000.kSELECT_BACKGROUND_COLOR.cgColor
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCustomerFlag.rawValue) {
            lblCusStatus.isHidden = false
        }
        
        switch customer.cus_status {
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
    }
    
    func reupdateView() {
        if let url = URL(string: customer.thumb) {
            do {
                let imgData = try Data(contentsOf: url, options: NSData.ReadingOptions())
                imvCusTop.image = UIImage(data: imgData)
                imvCustomer.image = UIImage(data: imgData)
            } catch {
                imvCusTop.image = UIImage(named: "icon_error_cloud")
                imvCustomer.image = UIImage(named: "icon_error_cloud")
                print(error)
            }
        }
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        showDeleteOption(status: false)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //*****************************************************************
    // MARK: - AccountGenealogyPopupDelegate Delegate
    //*****************************************************************

    override func onUpdateHierarchyData(arrIDs: [Int]) {
        if arrIDs.count > 0 {
            let alert = UIAlertController(title: "顧客の店舗を移動します。よろしいですか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                APIRequest.onSwitchCustomerOwner(newAccount: arrIDs[0],customer_id: self.customer.id) { (success) in
                    if success {
                        GlobalVariables.sharedManager.customerSwitch = true
                        self.showDeleteOption(status: false)
                        _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        Utils.showAlert(message: "顧客の移動に失敗しました。", view: self)
                    }
                }
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

    //*****************************************************************
    // MARK: - Action
    //*****************************************************************

    @IBAction func onAddNewCarte(_ sender: LGButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"AddCartePopupVC") as? AddCartePopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func onEdit(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.customer = customer
            vc.popupType = PopUpType.Edit.rawValue
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSecret(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            guard let newPopup = PasswordInputVC(nibName: "PasswordInputVC", bundle: nil) as PasswordInputVC? else {
                return
            }
            
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 300, height: 150)
            newPopup.customer = customer
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
        
    }
    
    @IBAction func onGallery(_ sender: LGButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PhotoCollectionVC") as? PhotoCollectionVC {
            if let navigator = navigationController {
                viewController.customer = customer
                viewController.picLimit = accounts[0].pic_limit
                showDeleteOption(status: false)
                
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onSelect(_ sender: LGButton) {
        
        //check customer has exist or not
        guard let carte = cartes else {
            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        showDeleteOption(status: true)
        
        tblCarte.reloadData()
        tblCarte.allowsMultipleSelection = true
        
        for i in 0 ..< carte.count {
            let dict : [String : Any?] = ["selected_status" : 0]
            RealmServices.shared.update(cartes[i], with: dict)
        }
    }
    
    func showDeleteOption(status:Bool) {
        btnAddCarte.isHidden = status
        btnSelect.isHidden = status
        btnGallery.isHidden = status
        
        btnComplete.isHidden = !status
        btnDelete.isHidden = !status
        
        GlobalVariables.sharedManager.onMultiSelect = status
    }
    
    @IBAction func onDelete(_ sender: LGButton) {
        
        for carte in self.cartes.filter("selected_status = 1") {
            self.indexDelete.append(carte.id)
        }
        
        if indexDelete.count > 0 {
            let alert = UIAlertController(title: "選択しているカルテを削除しますか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                //add loading view
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                self.indexDelete.removeAll()
                for carte in self.cartes.filter("selected_status = 1") {
                    self.indexDelete.append(carte.id)
                }
                
                APIRequest.deleteCarte(ids: self.indexDelete) { (success) in
                    if success {
                      
                        APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                            if success {
                  
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                self.cartesData.removeAll()
                                
                                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                    self.cartesData.append(carte)
                                }
                                
                                self.tblCarte.reloadData()
                                
                                APIRequest.onViewCustomer(cusID: self.customer.id) { (success,cusData)  in
                                    if success {
                                        self.customer = cusData
                                        self.updateTopView()
                                    } else {
                                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                    }
                                }
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_DELETE_CARTE , view: self)
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
            Utils.showAlert(message: MSG_ALERT.kALERT_SELECT_CARTE_2_DELETE, view: self)
        }
    }
    
    @IBAction func onComplete(_ sender: LGButton) {
        showDeleteOption(status: false)
        
        tblCarte.reloadData()
        tblCarte.allowsMultipleSelection = false
        
        for i in 0 ..< cartes.count {
            let dict : [String : Any?] = ["selected_status" : 0]
            RealmServices.shared.update(cartes[i], with: dict)
        }
    }
    
    @IBAction func onMessageSelect(_ sender: UIButton) {
        showDeleteOption(status: false)
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CarteChatVC") as? CarteChatVC {
            if let navigator = navigationController {
                viewController.accountsData = self.accounts[0]
                viewController.customerData = self.customer
                viewController.cartesData = cartesData
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onContractSelect(_ sender: UIButton) {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kContract.rawValue) {
            guard let newPopup = ContractPopupVC(nibName: "ContractPopupVC", bundle: nil) as ContractPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 500)
            newPopup.customer = customer
            newPopup.account = accounts[0]
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        } else {
            Utils.showAlert(message: "お客様のご契約では使用できません。", view: self)
        }
    }
    
    @IBAction func onExchangeCustomer(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        APIRequest.getAccountHierarchyWithAlliance(accountID: accounts[0].id) { (success,treeData) in
            if success {
                if treeData.count > 0 {
                    guard let newPopup = HierarchyPopup(nibName: "HierarchyPopup", bundle: nil) as HierarchyPopup? else { return }
                    newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                    newPopup.preferredContentSize = CGSize(width: 400, height: 700)
                    newPopup.accountsData = self.accounts[0]
                    newPopup.treeData = treeData
                    newPopup.type = 2
                    newPopup.delegate = self
                    self.present(newPopup, animated: true, completion: nil)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_DONT_HAVE_BRANCH, view: self)
                }
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
        }
    }
    
    @IBAction func onSettlement(_ sender: UIButton) {
        let stringURL = accounts[0].settlement_url
        if let url = URL(string: stringURL) {
            UIApplication.shared.open(url)
        } else {
            Utils.showAlert(message: "リンク先URLがございませんでした。", view: self)
        }
    }
}

//*****************************************************************
// MARK: - ContractPopup Delegate
//*****************************************************************

extension CarteListVC: ContractPopupVCDelegate {
    func onGoToContractConfirm(time: Int, id: Int,brochureData:BrochureData) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Contract", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "InputCustomerVC") as? InputCustomerVC {
            vc.customer = customer
            vc.brochure = brochureData
            if let navigator = navigationController {
                   navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onAddContract(time:Int,id:Int) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Contract", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "InputContractVC") as? InputContractVC {
            vc.customer = customer
            vc.account = accounts[0]
            vc.timeCreated = time
            vc.brochure.id = id
            vc.brochure.account_id = accounts[0].id
            if let navigator = navigationController {
                   navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onPreviewBrochure(id: Int, url: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Contract", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "BrochureConfirmFinalVC") as? BrochureConfirmFinalVC {
            vc.url = url
            vc.brochure.id = id
            if let navigator = navigationController {
                   navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onPreviewContract(id: Int, url: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Contract", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "ContractConfirmFinalVC") as? ContractConfirmFinalVC {
            vc.url = url
            vc.brochure.id = id
            if let navigator = navigationController {
                   navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onAddCustomerSign(brochureData:BrochureData) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Contract", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "CustomerFinalSignVC") as? CustomerFinalSignVC {
            vc.customer = customer
            vc.brochure = brochureData
            if let navigator = navigationController {
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension CarteListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tblTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartesData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteEdit.rawValue) {
            return 250
        } else {
            return 220
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarteCell") as? CarteCell else
        { return UITableViewCell() }
        
        let carteCell = cartesData[indexPath.row]
        cell.categories = categoriesData
        cell.maxFree = accounts[0].acc_free_memo_max
        cell.maxStamp = accounts[0].acc_stamp_memo_max
        cell.cellIndex = indexPath.row
        
        for i in 0 ..< counsellingTempData.count {
            switch i {
            case 0:
                cell.btnCounselling1.setTitle("\(counsellingTempData[i].title)", for: .normal)
                cell.btnCounselling1.isHidden = false
            case 1:
                cell.btnCounselling2.setTitle("\(counsellingTempData[i].title)", for: .normal)
                cell.btnCounselling2.isHidden = false
            case 2:
                cell.btnCounselling3.setTitle("\(counsellingTempData[i].title)", for: .normal)
                cell.btnCounselling3.isHidden = false
            case 3:
                cell.btnCounselling4.setTitle("\(counsellingTempData[i].title)", for: .normal)
                cell.btnCounselling4.isHidden = false
            default:
                break
            }
        }
        
        for i in 0 ..< consentTempData.count {
            switch i {
            case 0:
                cell.btnConsent1.setTitle("\(consentTempData[i].title)", for: .normal)
                cell.btnConsent1.isHidden = false
            case 1:
                cell.btnConsent2.setTitle("\(consentTempData[i].title)", for: .normal)
                cell.btnConsent2.isHidden = false
            case 2:
                cell.btnConsent3.setTitle("\(consentTempData[i].title)", for: .normal)
                cell.btnConsent3.isHidden = false
            case 3:
                cell.btnConsent4.setTitle("\(consentTempData[i].title)", for: .normal)
                cell.btnConsent4.isHidden = false
            default:
                break
            }
        }
        
        for i in 0 ..< handwrittingTempData.count {
            switch i {
            case 0:
                cell.btnHandwriting1.setTitle("\(handwrittingTempData[i].title)", for: .normal)
                cell.btnHandwriting1.isHidden = false
            case 1:
                cell.btnHandwriting2.setTitle("\(handwrittingTempData[i].title)", for: .normal)
                cell.btnHandwriting2.isHidden = false
            case 2:
                cell.btnHandwriting3.setTitle("\(handwrittingTempData[i].title)", for: .normal)
                cell.btnHandwriting3.isHidden = false
            case 3:
                cell.btnHandwriting4.setTitle("\(handwrittingTempData[i].title)", for: .normal)
                cell.btnHandwriting4.isHidden = false
            default:
                break
            }
        }
        
        cell.configure(carte: carteCell)
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tblCarte.allowsMultipleSelection == true {
            if cartes[indexPath.row].selected_status == 0 {
                let dict : [String : Any?] = ["selected_status" : 1]
                RealmServices.shared.update(cartes[indexPath.row], with: dict)
                tblCarte.reloadData()
            } else {
                let dict : [String : Any?] = ["selected_status" : 0]
                RealmServices.shared.update(cartes[indexPath.row], with: dict)
                tblCarte.reloadData()
            }
        }
    }
}

//*****************************************************************
// MARK: - CarteCell Delegate
//*****************************************************************

extension CarteListVC: CarteCellDelegate {
    
    func onEditCarte(cellIndex: Int) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"AddCartePopupVC") as? AddCartePopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            vc.carte = cartesData[cellIndex]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //document
    func didCounsellingPress(cellIndex: Int, index: Int) {
        let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        newPopup.cellIndex = cellIndex
        if tblCarte.numberOfRows(inSection: 0) == 1 {
            newPopup.onShowMoveUp = false
            newPopup.onShowMoveDown = false
        } else {
            if cellIndex == 0 {
                newPopup.onShowMoveUp = false
            } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                newPopup.onShowMoveDown = false
            } else {
                newPopup.onShowMoveUp = true
                newPopup.onShowMoveDown = true
            }
        }
        newPopup.carteData = cartesData[cellIndex]
        newPopup.delegate = self
        newPopup.accountData = accounts[0]
        //check if data has exist or not
        if let docData = cartesData[cellIndex].doc.filter("type == 1 && sub_type == \(index)").first {
            newPopup.documentsData = docData
            newPopup.isTemp = false
        } else {
            if counsellingTempData.count > (index - 1) {
                newPopup.documentsData = counsellingTempData[index - 1]
                newPopup.isTemp = true
            } else {
                Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                return
            }
        }
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func didConsentPress(cellIndex: Int, index: Int) {
        let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        newPopup.cellIndex = cellIndex
        if tblCarte.numberOfRows(inSection: 0) == 1 {
            newPopup.onShowMoveUp = false
            newPopup.onShowMoveDown = false
        } else {
            if cellIndex == 0 {
                newPopup.onShowMoveUp = false
            } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                newPopup.onShowMoveDown = false
            } else {
                newPopup.onShowMoveUp = true
                newPopup.onShowMoveDown = true
            }
        }
        newPopup.carteData = cartesData[cellIndex]
        newPopup.delegate = self
        newPopup.accountData = accounts[0]
        //check if data has exist or not
        if let docData = cartesData[cellIndex].doc.filter("type == 2 && sub_type == \(index)").first {
            newPopup.documentsData = docData
            newPopup.isTemp = false
        } else {
            if consentTempData.count > (index - 1) {
                newPopup.documentsData = consentTempData[index - 1]
                newPopup.isTemp = true
            } else {
                Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                return
            }
        }
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func didHandwrittingPress(cellIndex: Int, index: Int) {
        let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        newPopup.cellIndex = cellIndex
        if tblCarte.numberOfRows(inSection: 0) == 1 {
            newPopup.onShowMoveUp = false
            newPopup.onShowMoveDown = false
        } else {
            if cellIndex == 0 {
                newPopup.onShowMoveUp = false
            } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                newPopup.onShowMoveDown = false
            } else {
                newPopup.onShowMoveUp = true
                newPopup.onShowMoveDown = true
            }
        }
        newPopup.carteData = cartesData[cellIndex]
        newPopup.delegate = self
        newPopup.accountData = accounts[0]
        //check if data has exist or not
        if let docData = cartesData[cellIndex].doc.filter("type == 3 && sub_type == \(index)").first {
            newPopup.documentsData = docData
            newPopup.isTemp = false
        } else {
            if handwrittingTempData.count > (index - 1) {
                newPopup.documentsData = handwrittingTempData[index - 1]
                newPopup.isTemp = true
            } else {
                Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                return
            }
        }
        self.present(newPopup, animated: true, completion: nil)
    }
    
    //stamp memo
    func didStampMemoPress(cellIndex: Int, index: Int) {
        guard let newPopup = CarteStampMemoPopupVC(nibName: "CarteStampMemoPopupVC", bundle: nil) as CarteStampMemoPopupVC? else { return }
        
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 600, height: 600)
        newPopup.delegate = self
        newPopup.cellIndex = cellIndex
        newPopup.position = index
        
        for j in 0 ..< categories[index - 1].keywords.count {
            newPopup.keywordsData.append(categories[index - 1].keywords[j])
        }
        
        for i in 0 ..< cartesData[cellIndex].stamp_memo.count {
            if cartesData[cellIndex].stamp_memo[i].position - 4 == index {
                newPopup.stampMemo = cartesData[cellIndex].stamp_memo[i]
            }
        }
        newPopup.categories = self.categories
        self.present(newPopup, animated: true, completion: nil)
    }
    
    //free memo
    func didFreeMemoPress(cellIndex: Int,index: Int) {
        guard let newPopup = CarteFreeMemoPopupVC(nibName: "CarteFreeMemoPopupVC", bundle: nil) as CarteFreeMemoPopupVC? else { return }
        
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 600, height: 600)
        newPopup.delegate = self
        newPopup.cellIndex = cellIndex
        newPopup.position = index
        for i in 0 ..< cartesData[cellIndex].free_memo.count {
            if cartesData[cellIndex].free_memo[i].position == index {
                newPopup.freeMemo = cartesData[cellIndex].free_memo[i]
                newPopup.isEdited = true
            }
        }
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func didAvatarPress(tag: Int) {
        if cartesData.count == 0 {
            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        showDeleteOption(status: false)
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CarteImageListVC") as? CarteImageListVC {
            if let navigator = navigationController {
                viewController.customer = customer
                
                for i in 0 ..< cartesData.count {
                    if cartesData[i].id == tag {
                        viewController.carte = cartesData[i]
                        viewController.accountPicLimit = accounts[0].pic_limit
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    func didPressButton(type: Int,tag: Int) {
        switch type {
        case 0:
            let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let confirm = UIAlertAction(title: "削除", style: .default) { UIAlertAction in
                let carte = self.cartesData[tag]
                self.cartesData.remove(at: tag)
                RealmServices.shared.delete(carte)
                self.tblCarte.reloadData()
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - AddCartePopupVC Delegate
//*****************************************************************

extension CarteListVC: AddCartePopupVCDelegate {

    func onUpdateCarte(carteID: Int, time: Int, staff_name: String, bed_name: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onEditCarte(carteID: carteID, date: time, staff_name: staff_name, bed_name: bed_name) { (success) in
            if success {
                 APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                     if success {
                
                         let realm = RealmServices.shared.realm
                         self.cartes = realm.objects(CarteData.self)
                         
                         self.cartesData.removeAll()
                         
                         for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                             self.cartesData.append(carte)
                         }
                         
                         self.tblCarte.reloadData()
                         
                         APIRequest.onViewCustomer(cusID: self.customer.id) { (success,cusData)  in
                            if success {
                                 self.customer = cusData
                                 self.updateTopView()
                             } else {
                                 Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                             }
                            SVProgressHUD.dismiss()
                         }
                     } else {
                         Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                         SVProgressHUD.dismiss()
                     }
                 }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func onAddNewCarte(time: Int, staff_name: String, bed_name: String) {
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
            
            APIRequest.addCarte(cusID: customer.id, date: time,staff_name:staff_name,bed_name:bed_name,mediaData: nil) { (success) in
                if success == 1 {
                  
                    APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                        if success {
                   
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            self.cartesData.removeAll()
                            
                            for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                self.cartesData.append(carte)
                            }
                            
                            self.tblCarte.reloadData()
                            
                            APIRequest.onViewCustomer(cusID: self.customer.id) { (success,cusData)  in
                                if success {
                                    self.customer = cusData
                                    self.updateTopView()
                                } else {
                                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                }
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else if success == 2 {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
                   
                    APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                        if success {
                            
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            self.cartesData.removeAll()
                            
                            for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                self.cartesData.append(carte)
                            }
                            
                            self.tblCarte.reloadData()
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
        }
    }
}

//*****************************************************************
// MARK: - Secret Popup Delegate
//*****************************************************************

extension CarteListVC: SecretPopupVCDelegate {
    func didCloseSecret() {
        APIRequest.onViewCustomer(cusID: self.customer.id) { (success,cusData)  in
            if success {
                self.customer = cusData
                let realm = RealmServices.shared.realm
                let customerDB = realm.objects(CustomerData.self).filter("id == \(cusData.id)").first
                try! realm.write {
                    customerDB?.last_name_kana = self.customer.last_name_kana
                    customerDB?.first_name_kana = self.customer.first_name_kana
                    customerDB?.last_name = self.customer.last_name
                    customerDB?.first_name = self.customer.first_name
                    customerDB?.urgent_no = self.customer.urgent_no
                    customerDB?.customer_no = self.customer.customer_no
                    customerDB?.responsible = self.customer.responsible
                    customerDB?.gender = self.customer.gender
                    customerDB?.bloodtype = self.customer.bloodtype
                    customerDB?.first_daycome = self.customer.first_daycome
                    customerDB?.last_daycome = self.customer.last_daycome
                    customerDB?.update_date = self.customer.update_date
                    customerDB?.pic_url = self.customer.pic_url
                    customerDB?.birthday = self.customer.birthday
                    customerDB?.hobby = self.customer.hobby
                    customerDB?.email = self.customer.email
                    customerDB?.postal_code = self.customer.postal_code
                    customerDB?.address1 = self.customer.address1
                    customerDB?.address2 = self.customer.address2
                    customerDB?.address3 = self.customer.address3
                    customerDB?.mail_block = self.customer.mail_block
                    customerDB?.memo1 = self.customer.memo1
                    customerDB?.memo2 = self.customer.memo2
                    customerDB?.created_at = self.customer.created_at
                    customerDB?.updated_at = self.customer.updated_at
                    customerDB?.selected_status = self.customer.selected_status
                    customerDB?.thumb = self.customer.thumb
                    customerDB?.resize = self.customer.resize
                    customerDB?.onSecret = self.customer.onSecret
                    customerDB?.created_at = self.customer.created_at
                    customerDB?.cus_status = self.customer.cus_status
                }
                self.updateTopView()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
}

//*****************************************************************
// MARK: - Password Input Delegate
//*****************************************************************

extension CarteListVC: PasswordInputVCDelegate {
    func onPasswordInput(password: String, cusData: CustomerData) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.getAccessSecretMemo(password: password) { (success, msg) in
            if success {
                guard let newPopup = SecretPopupVC(nibName: "SecretPopupVC", bundle: nil) as SecretPopupVC? else {
                    return
                }
                newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                newPopup.preferredContentSize = CGSize(width: 560, height: 450)
                newPopup.customer = cusData
                newPopup.authenPass = password
                newPopup.delegate = self
                self.present(newPopup, animated: true, completion: nil)
            } else {
                Utils.showAlert(message: msg, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - RegCustomerPopup Delegate
//*****************************************************************

extension CarteListVC: RegCustomerPopupDelegate {
    func didConfirm(type:Int) {
        let realm = RealmServices.shared.realm
        if let customerDB = realm.objects(CustomerData.self).filter("id == \(customer.id)").first {
            self.customer = customerDB
            self.updateTopView()
        }
    }
}

//*****************************************************************
// MARK: - CarteFreeMemoPopupVC Delegate
//*****************************************************************

extension CarteListVC: CarteFreeMemoPopupVCDelegate {
    
    func onDeleteMemo(status:Int,cellIndex:Int) {
        
        if status == 0 {
            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        if status == 2 {
            Utils.showAlert(message: MSG_ALERT.kALERT_MEMO_HAS_NOT_REGISTERED, view: self)
            return
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
            if success {
                
                let realm = RealmServices.shared.realm
                self.cartes = realm.objects(CarteData.self)
                
                self.cartesData.removeAll()
                
                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                    self.cartesData.append(carte)
                }
                
                self.tblCarte.reloadData()
                let indexPath = IndexPath(row: cellIndex, section: 0)
                self.tblCarte.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func onEditMemo(title: String, content: String, position: Int, cellIndex: Int,memoID:Int,update:Int) {
        APIRequest.onCheckCarteFreeMemoData(memoID: memoID, update: update) { (success) in
            if success == 1 {
                //on edit
                APIRequest.onEditCarteFreeMemo(memoID: memoID, title: title, content: content, completion: { (success) in
                    if success {
                        SVProgressHUD.show(withStatus: "読み込み中")
                        SVProgressHUD.setDefaultMaskType(.clear)
                        
                        APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                            if success {
                                
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                self.cartesData.removeAll()
                                
                                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                    self.cartesData.append(carte)
                                }
                                
                                self.tblCarte.reloadData()
                                let indexPath = IndexPath(row: cellIndex, section: 0)
                                self.tblCarte.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                    }
                })
            } else if success == 2 {
                //show alert
                let alert = UIAlertController(title: "サーバから更新されたメモがございますのでリフレッシュしましょうか？", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    SVProgressHUD.show(withStatus: "読み込み中")
                    SVProgressHUD.setDefaultMaskType(.clear)
                    
                    APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                        if success {
                            
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            self.cartesData.removeAll()
                            
                            for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                self.cartesData.append(carte)
                            }
                            
                            self.tblCarte.reloadData()
                            let indexPath = IndexPath(row: cellIndex, section: 0)
                            self.tblCarte.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
        }
    }
    
    func onSaveMemo(title: String, content: String, position: Int, cellIndex: Int) {
        //Add New
        APIRequest.onAddNewFreeMemo(carteID: self.cartesData[cellIndex].id,cusID: self.customer.id,title:title,content:content,position:position) { (success) in
            if success == 1 {
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                    if success {
                        
                        let realm = RealmServices.shared.realm
                        self.cartes = realm.objects(CarteData.self)
                        
                        self.cartesData.removeAll()
                        
                        for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                            self.cartesData.append(carte)
                        }
                        
                        self.tblCarte.reloadData()
                        let indexPath = IndexPath(row: cellIndex, section: 0)
                        self.tblCarte.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            } else if success == 2 {
                
                let alert = UIAlertController(title: "サーバから更新されたメモがございますのでリフレッシュしましょうか？", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    SVProgressHUD.show(withStatus: "読み込み中")
                    SVProgressHUD.setDefaultMaskType(.clear)
                    
                    APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                        if success {
                            
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            self.cartesData.removeAll()
                            
                            for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                self.cartesData.append(carte)
                            }
                            
                            self.tblCarte.reloadData()
                            let indexPath = IndexPath(row: cellIndex, section: 0)
                            self.tblCarte.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
}

//*****************************************************************
// MARK: - CarteStampMemoPopupVC Delegate
//*****************************************************************

extension CarteListVC: CarteStampMemoPopupVCDelegate {
    
    func onCloseStampMemo(cellIndex:Int) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
            if success {
                
                let realm = RealmServices.shared.realm
                self.cartes = realm.objects(CarteData.self)
                
                self.cartesData.removeAll()
                
                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                    self.cartesData.append(carte)
                }
                
                self.tblCarte.reloadData()
                let indexPath = IndexPath(row: cellIndex, section: 0)
                self.tblCarte.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - DocumentPreviewPopup Delegate
//*****************************************************************

extension CarteListVC: DocumentPreviewPopupDelegate {
    func onMoveUpDocument(type: Int, subType: Int, cellIndex: Int) {
        switch type {
        case 1:
            let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.cellIndex = cellIndex
            if tblCarte.numberOfRows(inSection: 0) == 1 {
                newPopup.onShowMoveUp = false
                newPopup.onShowMoveDown = false
            } else {
                if cellIndex == 0 {
                    newPopup.onShowMoveUp = false
                } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                    newPopup.onShowMoveDown = false
                } else {
                    newPopup.onShowMoveUp = true
                    newPopup.onShowMoveDown = true
                }
            }
            newPopup.carteData = cartesData[cellIndex]
            newPopup.delegate = self
            newPopup.accountData = accounts[0]
            //check if data has exist or not
            if let docData = cartesData[cellIndex].doc.filter("type == 1 && sub_type == \(subType)").first {
                newPopup.documentsData = docData
                newPopup.isTemp = false
            } else {
                if counsellingTempData.count > (subType - 1) {
                    newPopup.documentsData = counsellingTempData[subType - 1]
                    newPopup.isTemp = true
                } else {
                    Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                    return
                }
            }
            self.present(newPopup, animated: true, completion: nil)
        case 2:
            let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.cellIndex = cellIndex
            if tblCarte.numberOfRows(inSection: 0) == 1 {
                newPopup.onShowMoveUp = false
                newPopup.onShowMoveDown = false
            } else {
                if cellIndex == 0 {
                    newPopup.onShowMoveUp = false
                } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                    newPopup.onShowMoveDown = false
                } else {
                    newPopup.onShowMoveUp = true
                    newPopup.onShowMoveDown = true
                }
            }
            newPopup.carteData = cartesData[cellIndex]
            newPopup.delegate = self
            newPopup.accountData = accounts[0]
            //check if data has exist or not
            if let docData = cartesData[cellIndex].doc.filter("type == 2 && sub_type == \(subType)").first {
                newPopup.documentsData = docData
                newPopup.isTemp = false
            } else {
                if consentTempData.count > (subType - 1) {
                    newPopup.documentsData = consentTempData[subType - 1]
                    newPopup.isTemp = true
                } else {
                    Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                    return
                }
            }
            self.present(newPopup, animated: true, completion: nil)
        case 3:
            let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.cellIndex = cellIndex
            if tblCarte.numberOfRows(inSection: 0) == 1 {
                newPopup.onShowMoveUp = false
                newPopup.onShowMoveDown = false
            } else {
                if cellIndex == 0 {
                    newPopup.onShowMoveUp = false
                } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                    newPopup.onShowMoveDown = false
                } else {
                    newPopup.onShowMoveUp = true
                    newPopup.onShowMoveDown = true
                }
            }
            newPopup.carteData = cartesData[cellIndex]
            newPopup.delegate = self
            newPopup.accountData = accounts[0]
            //check if data has exist or not
            if let docData = cartesData[cellIndex].doc.filter("type == 3 && sub_type == \(subType)").first {
                newPopup.documentsData = docData
                newPopup.isTemp = false
            } else {
                if handwrittingTempData.count > (subType - 1) {
                    newPopup.documentsData = handwrittingTempData[subType - 1]
                    newPopup.isTemp = true
                } else {
                    Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                    return
                }
            }
            self.present(newPopup, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func onMoveDownDocument(type: Int, subType: Int, cellIndex: Int) {
        switch type {
        case 1:
            let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.cellIndex = cellIndex
            if tblCarte.numberOfRows(inSection: 0) == 1 {
                newPopup.onShowMoveUp = false
                newPopup.onShowMoveDown = false
            } else {
                if cellIndex == 0 {
                    newPopup.onShowMoveUp = false
                } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                    newPopup.onShowMoveDown = false
                } else {
                    newPopup.onShowMoveUp = true
                    newPopup.onShowMoveDown = true
                }
            }
            newPopup.carteData = cartesData[cellIndex]
            newPopup.delegate = self
            newPopup.accountData = accounts[0]
            //check if data has exist or not
            if let docData = cartesData[cellIndex].doc.filter("type == 1 && sub_type == \(subType)").first {
                newPopup.documentsData = docData
                newPopup.isTemp = false
            } else {
                if counsellingTempData.count > (subType - 1) {
                    newPopup.documentsData = counsellingTempData[subType - 1]
                    newPopup.isTemp = true
                } else {
                    Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                    return
                }
            }
            self.present(newPopup, animated: true, completion: nil)
        case 2:
            let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.cellIndex = cellIndex
            if tblCarte.numberOfRows(inSection: 0) == 1 {
                newPopup.onShowMoveUp = false
                newPopup.onShowMoveDown = false
            } else {
                if cellIndex == 0 {
                    newPopup.onShowMoveUp = false
                } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                    newPopup.onShowMoveDown = false
                } else {
                    newPopup.onShowMoveUp = true
                    newPopup.onShowMoveDown = true
                }
            }
            newPopup.carteData = cartesData[cellIndex]
            newPopup.delegate = self
            newPopup.accountData = accounts[0]
            //check if data has exist or not
            if let docData = cartesData[cellIndex].doc.filter("type == 2 && sub_type == \(subType)").first {
                newPopup.documentsData = docData
                newPopup.isTemp = false
            } else {
                if consentTempData.count > (subType - 1) {
                    newPopup.documentsData = consentTempData[subType - 1]
                    newPopup.isTemp = true
                } else {
                    Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                    return
                }
            }
            self.present(newPopup, animated: true, completion: nil)
        case 3:
            let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.cellIndex = cellIndex
            if tblCarte.numberOfRows(inSection: 0) == 1 {
                newPopup.onShowMoveUp = false
                newPopup.onShowMoveDown = false
            } else {
                if cellIndex == 0 {
                    newPopup.onShowMoveUp = false
                } else if tblCarte.numberOfRows(inSection: 0) == cellIndex + 1 {
                    newPopup.onShowMoveDown = false
                } else {
                    newPopup.onShowMoveUp = true
                    newPopup.onShowMoveDown = true
                }
            }
            newPopup.carteData = cartesData[cellIndex]
            newPopup.delegate = self
            newPopup.accountData = accounts[0]
            //check if data has exist or not
            if let docData = cartesData[cellIndex].doc.filter("type == 3 && sub_type == \(subType)").first {
                newPopup.documentsData = docData
                newPopup.isTemp = false
            } else {
                if handwrittingTempData.count > (subType - 1) {
                    newPopup.documentsData = handwrittingTempData[subType - 1]
                    newPopup.isTemp = true
                } else {
                    Utils.showAlert(message: "ドキュメントがないので新しいディータをアップロードしてください", view: self)
                    return
                }
            }
            self.present(newPopup, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func onEditDocument(document: DocumentData, carteID: Int) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentVC") as? DocumentVC else { return }
        vc.customer = customer
        vc.document = document
        vc.carteID = carteID
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
