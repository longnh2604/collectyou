//
//  UserInfoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/19.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class UserInfoPopupVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Variable
    var accountsData = AccountData()
    var usedGB = PieChartDataEntry(value: 0)
    var remainedGB = PieChartDataEntry(value: 0)
    var numberOfDataEntries = [PieChartDataEntry]()
    var usedGBStep = UIStepper.init()
    var remainedGBStep = UIStepper.init()
    var imagePicker = UIImagePickerController()
    
    //IBOutlet
    @IBOutlet weak var tfAccName: UITextField!
    @IBOutlet weak var tfAccID: UITextField!
    @IBOutlet weak var tfFreeMemo: UITextField!
    @IBOutlet weak var tfStampMemo: UITextField!
    @IBOutlet weak var chartStorageLimit: PieChartView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUserID: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblFree: UILabel!
    @IBOutlet weak var lblStamp: UILabel!
    @IBOutlet weak var btnClose: RoundButton!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var heightAvatar: NSLayoutConstraint!
    @IBOutlet weak var heightChange: NSLayoutConstraint!
    @IBOutlet weak var lblTitleAvatar: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }

    fileprivate func setupLayout() {
        tfAccName.text = accountsData.acc_name
        tfAccID.text = accountsData.account_id

        tfFreeMemo.text = String(accountsData.acc_free_memo_max)
        tfStampMemo.text = String(accountsData.acc_stamp_memo_max)

        chartStorageLimit.layer.cornerRadius = 10
        chartStorageLimit.clipsToBounds = true
        
        localizeLanguage()
        
        if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
            lblTitleAvatar.isHidden = true
            btnChange.isHidden = true
            imvAvatar.isHidden = true
            heightChange.constant = 0
            heightAvatar.constant = 0
        }
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        APIRequest.countStorage { (success) in
            if success {
                self.updateChartData()

                if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessenger.rawValue) {
                    if let avatar = Profile.currentProfile?.avatar {
                        self.imvAvatar?.sd_setImage(with: URL(string: avatar)) { (image, error, cache, url) in
                            if let error = error {
                                SVProgressHUD.showError(withStatus: error.localizedDescription)
                            }
                        }
                    }
                }
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    fileprivate func localizeLanguage() {
        lblTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "User Info", comment: "")
        lblUserID.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "User ID", comment: "")
        lblUsername.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Username", comment: "")
        lblFree.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Free Memo", comment: "")
        lblStamp.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Stamp Memo", comment: "")
        btnClose.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel",comment: ""), for: .normal)
    }
    
    fileprivate func updateChartData()  {
        
        // 2. generate chart data entries
        var track = [String]()
        var money = [Double]()
        
        guard let limit = GlobalVariables.sharedManager.limitSize,let curr = GlobalVariables.sharedManager.currentSize else { return }
        let limitGB = Double(limit) / 1_024 / 1_024 / 1_024
        var currGB = Double(curr) / 1_024 / 1_024 / 1_024
        var remainGB = limitGB - currGB
        
        //check if it's over limit
        if remainGB <= 0 {
            currGB = limitGB
            remainGB = -remainGB
            money = [limitGB + remainGB,remainGB]
            track = [LocalizationSystem.sharedInstance.localizedStringForKey(key: "Used", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "Over", comment: "")]
        } else {
            money = [currGB,remainGB]
            track = [LocalizationSystem.sharedInstance.localizedStringForKey(key: "Used", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "Remained", comment: "")]
        }
        
        var entries = [PieChartDataEntry]()
        for (index, value) in money.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value.rounded(toPlaces: 3)
            entry.label = track[index]
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "")
        // this is custom extension method. Download the code for more details.
        var colors: [UIColor] = []

        let usedColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
        let remainedColor = UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)
     
        colors.append(usedColor)
        colors.append(remainedColor)
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        chartStorageLimit.data = data
        chartStorageLimit.noDataText = LocalizationSystem.sharedInstance.localizedStringForKey(key: "No Data", comment: "")
        // user interaction
        chartStorageLimit.isUserInteractionEnabled = false
        
        let d = Description()
        chartStorageLimit.rotationEnabled = false
        chartStorageLimit.chartDescription = d
        chartStorageLimit.centerText = "\(limitGB.rounded(toPlaces: 3)) GB"
        chartStorageLimit.holeRadiusPercent = 0.5
        chartStorageLimit.transparentCircleColor = UIColor.clear
        chartStorageLimit.backgroundColor = COLOR_SET.kBACKGROUND_LIGHT_GRAY
        
    }
    
    fileprivate func onRequestLogin(completion:@escaping(Bool) -> ()) {
        
        ConnectyCubeRequest.onLogin(user: accountsData.account_id, pass: "abcd1234") { (status, user) in
            if status == 1 {
                //login success
                Profile.currentProfile = user
                completion(true)
            } else {
                completion(false)
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
                        Utils.showAlert(message: "店舗アカウントの作成が完了しました。", view: self)
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
    
    fileprivate func onShowAddAvatar() {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
          
          let takeNew = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Take a Photo", comment: ""), style: .default) { UIAlertAction in
              if UIImagePickerController.isSourceTypeAvailable(.camera) {
                  
                  self.imagePicker.delegate = self
                  self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                  self.imagePicker.cameraCaptureMode = .photo
                  self.imagePicker.allowsEditing = false
                  self.present(self.imagePicker,animated: true,completion: nil)
              } else {
                  Utils.showAlert(message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Camera not found", comment: ""), view: self)
              }
          }
          let selectPhoto = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Choose Photo from Device", comment: ""), style: .default) { UIAlertAction in
              if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                  
                  self.imagePicker.delegate = self
                  self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                  self.imagePicker.allowsEditing = false
                  
                  self.present(self.imagePicker, animated: true, completion: {
                      self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
                  })
              }
          }
          alert.addAction(takeNew)
          alert.addAction(selectPhoto)
        
          alert.popoverPresentationController?.sourceView = self.btnChange
          alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
          alert.popoverPresentationController?.sourceRect = self.btnChange.bounds
          DispatchQueue.main.async {
              self.present(alert, animated: true, completion: nil)
          }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onChangeAvatar(_ sender: UIButton) {
        onShowAddAvatar()
    }
    
    @IBAction func onClose(_ sender: Any) {
        
        ConnectyCubeRequest.onLogout(completion: { (success) in
            if success {
                
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_DISCONNECT_CHAT, view: self)
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    //*****************************************************************
    // MARK: - UIImagePicker Delegate
    //*****************************************************************
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        self.dismiss(animated: true, completion: { () -> Void in
            if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                
                if picker.sourceType.rawValue == 1 {
                    self.imvAvatar.image = UIImage(data: imageData)?.updateImageOrientionUpSide()
                } else {
                    self.imvAvatar.image = UIImage(data: imageData)
                }
                
                ConnectyCubeRequest.onUpdateUserAvatar(avatar: Utils.imageWithImage(sourceImage: self.imvAvatar.image!, scaledToWidth: 768), completion: { (success) in
                    if success {
                        //do
                    }
                })
            }
        })
    }
}
