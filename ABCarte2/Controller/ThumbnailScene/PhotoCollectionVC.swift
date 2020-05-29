//
//  PhotoCollectionVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Photos
import LGButton

class PhotoCollectionVC: UIViewController {

    //Variable
    var customer = CustomerData()
    
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    
    var thumbs: Results<ThumbData>!
    var thumbsData : [ThumbData] = []
    
    var indexDelete : [Int] = []
    var needLoad: Bool = true
    var indexP: IndexPath?
    var picLimit: Int?
   
    //IBOutlet
    @IBOutlet weak var collectGallery: UICollectionView!
    @IBOutlet weak var lblNoPhoto: UILabel!
    @IBOutlet weak var btnCamera: LGButton!
    @IBOutlet weak var btnComparison: LGButton!
    @IBOutlet weak var btnDrawing: LGButton!
    @IBOutlet weak var btnExport: LGButton!
    @IBOutlet weak var viewPanelTop: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    fileprivate func setupLayout() {
        let button = LGButton()
        button.leftImageSrc = UIImage(named: "icon_list_photo_white.png")
        button.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "List of Image", comment: "")
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
        
        collectGallery.delegate = self
        collectGallery.dataSource = self
        collectGallery.allowsMultipleSelection = true
        
        guard let fl = collectGallery?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        fl.sectionHeadersPinToVisibleBounds = true
        
        collectGallery?.register(XibHeader.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: XibHeader.identifier)
        
        let nib = UINib(nibName: "photoCollectCell", bundle: nil)
        collectGallery.register(nib, forCellWithReuseIdentifier: "photoCollectCell")
        
        Utils.setViewColorStyle(view: viewPanelTop, type: 1)
        
        localizeLanguage()
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPhotoExport.rawValue) {
            btnExport.isHidden = false
        }
    }
    
    fileprivate func localizeLanguage() {
        btnCamera.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Take Photo", comment: "")
        btnComparison.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Comparison", comment: "")
        btnDrawing.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Drawing", comment: "")
    }
    
    fileprivate func removeAllData() {
        self.indexDelete.removeAll()
        thumbsData.removeAll()
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        needLoad = true
    }
    
    @objc fileprivate func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        removeAllData()
        _ = navigationController?.popViewController(animated: true)
    }

    fileprivate func loadData() {
        
        if needLoad == true {
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(ThumbData.self))
                realm.delete(realm.objects(CarteData.self))
            }
            
            //remove before get new
            cartesData.removeAll()
            thumbsData.removeAll()
            
            APIRequest.getCustomerCartesWithMedias(cusID: self.customer.id) { (success) in
                if success {
                    
                    self.cartes = realm.objects(CarteData.self)
                    var no = 0
                    
                    for i in 0 ..< self.cartes.count {
                        self.cartesData.append(self.cartes[i])
                        no += self.cartes[i].medias.count
                    }
                    
                    self.collectGallery.reloadData()
                    
                    self.lblNoPhoto.text = "全 :\(no)枚"
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.lblNoPhoto.text = "全 :0枚"
                }
                SVProgressHUD.dismiss()
            }
            self.needLoad = false
        }
    }
    
    fileprivate func checkButtonStatus() {
        if GlobalVariables.sharedManager.selectedImageIds.count > 1 {
            btnCamera.isEnabled = false
        } else {
            btnCamera.isEnabled = true
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onCamera(_ sender: LGButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 || GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            //get current date
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            
            var carte = CarteData()
            var statusData = false
            
            //check all carte of customer
            for i in 0 ..< cartesData.count {
                let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                let isSame = date.isInSameDay(date: currDate)
                if isSame {
                    statusData = true
                    carte = cartesData[i]
                }
            }
            
            if statusData == true {
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "ShootingVC") as? ShootingVC {
                    if let navigator = self.navigationController {
                        viewController.customer = self.customer
                        viewController.carte = carte
                        
                        //check limit
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                            let onLimit = (self.picLimit ?? 0) - carte.medias.count
                            if onLimit > 0 {
                                viewController.onLimit = onLimit
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_REACH_LIMIT_PHOTO, view: self)
                                SVProgressHUD.dismiss()
                                return
                            }
                        }
                        
                        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                            
                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                                
                                for i in 0 ..< self.cartesData.count {
                                    
                                    for j in 0 ..< self.cartesData[i].medias.count {
                                        if self.cartesData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                            viewController.media = self.cartesData[i].medias[j]
                                        }
                                    }
                                }
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_SHOOTING_TRANMISSION_NOT_ALLOW, view: self)
                                SVProgressHUD.dismiss()
                                return
                            }
                        }
                        self.removeAllData()
                        navigator.pushViewController(viewController, animated: true)
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                APIRequest.addCarte(cusID: customer.id, date: timeInterval,staff_name:"",bed_name:"",mediaData: nil) { (success) in
                    if success == 1 {
                       
                        APIRequest.getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                            if success {
                         
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                self.cartesData.removeAll()
                                
                                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                    self.cartesData.append(carte)
                                }
                                
                                for i in 0 ..< self.cartesData.count {
                                    if self.cartesData[i].select_date == timeInterval {
                                        carte = self.cartesData[i]
                                    }
                                }
                                
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                                if let viewController = storyBoard.instantiateViewController(withIdentifier: "ShootingVC") as? ShootingVC {
                                    if let navigator = self.navigationController {
                                        viewController.customer = self.customer
                                        viewController.carte = carte
                                        
                                        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                                            
                                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                                                
                                                for i in 0 ..< self.cartesData.count {
                                                    
                                                    for j in 0 ..< self.cartesData[i].medias.count {
                                                        if self.cartesData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                                            viewController.media = self.cartesData[i].medias[j]
                                                        }
                                                    }
                                                }
                                            } else {
                                                Utils.showAlert(message: MSG_ALERT.kALERT_SHOOTING_TRANMISSION_NOT_ALLOW, view: self)
                                                SVProgressHUD.dismiss()
                                                return
                                            }
                                        }
                                        self.removeAllData()
                                        
                                        //check limit
                                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                                            viewController.onLimit = self.picLimit
                                        }
                                            
                                        navigator.pushViewController(viewController, animated: true)
                                        SVProgressHUD.dismiss()
                                    }
                                }
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                                SVProgressHUD.dismiss()
                            }
                        }
                    } else if success == 2 {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
                        SVProgressHUD.dismiss()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    @IBAction func onCompare(_ sender: LGButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            Utils.showAlert(message: MSG_ALERT.kALERT_PLEASE_SELECT_PHOTO, view: self)
            return
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 13 || GlobalVariables.sharedManager.selectedImageIds.count == 1 {
            Utils.showAlert(message: MSG_ALERT.kALERT_CHOOSE_2_TO_12_PHOTOS, view: self)
            return
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count == 2 {
         
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "ComparisonVC") as? ComparisonVC {
                if let navigator = navigationController {
                    
                    let currDate = Date()
                    var carte = CarteData()
                    var statusData = false
                    
                    //check all carte of customer
                    for i in 0 ..< cartesData.count {
                        let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                        let isSame = date.isInSameDay(date: currDate)
                        if isSame {
                            carte = cartesData[i]
                            statusData = true
                        }
                    }
                    
                    if statusData == true {
                        viewController.onTemp = false
                    } else {
                        viewController.onTemp = true
                    }
                    
                    viewController.customer = customer
                    viewController.carte = carte
                    viewController.picLimit = picLimit
                    
                    for i in 0 ..< self.cartesData.count {
                        
                        for j in 0 ..< self.cartesData[i].medias.count {
                            
                            if GlobalVariables.sharedManager.selectedImageIds[0] == cartesData[i].medias[j].media_id {
                                viewController.media1 = self.cartesData[i].medias[j]
                            } else if GlobalVariables.sharedManager.selectedImageIds[1] == cartesData[i].medias[j].media_id {
                                viewController.media2 = self.cartesData[i].medias[j]
                                viewController.picCurrIndex = self.cartesData[i].medias.count
                            }
                        }
                    }
                    
                    navigator.pushViewController(viewController, animated: true)
                    removeAllData()
                    SVProgressHUD.dismiss()
                }
            }
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 2 && GlobalVariables.sharedManager.selectedImageIds.count < 13 {
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMorphing.rawValue) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "MorphingVC") as? MorphingVC {
                    if let navigator = navigationController {
                        
                        let currDate = Date()
                        var carte = CarteData()
                        var statusData = false
                        
                        //check all carte of customer
                        for i in 0 ..< cartesData.count {
                            let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                            let isSame = date.isInSameDay(date: currDate)
                            if isSame {
                                carte = cartesData[i]
                                statusData = true
                            }
                        }
                        
                        if statusData == true {
                            viewController.onTemp = false
                        } else {
                            viewController.onTemp = true
                        }
                        
                        viewController.customer = customer
                        viewController.cartesData = cartesData
                        viewController.carte = carte
                        
                        for k in 0 ..< GlobalVariables.sharedManager.selectedImageIds.count {
                            for i in 0 ..< self.cartesData.count {
                                
                                for j in 0 ..< self.cartesData[i].medias.count {
                                    
                                    if GlobalVariables.sharedManager.selectedImageIds[k] == cartesData[i].medias[j].media_id {
                                        viewController.mediasData.append(cartesData[i].medias[j])
                                    }
                                }
                            }
                        }
                        
                        navigator.pushViewController(viewController, animated: true)
                        removeAllData()
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_SERMENT_CANT_ACCESS, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func onDrawing(_ sender: LGButton) {
    
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            let currDate = Date()
            var carte = CarteData()
            var statusData = false

            //check all carte of customer
            for i in 0 ..< cartesData.count {
                let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                let isSame = date.isInSameDay(date: currDate)
                if isSame {
                    carte = cartesData[i]
                    statusData = true
                }
            }
            
            #if ATTENDER
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "OldDrawingVC") as? OldDrawingVC {
                if let navigator = self.navigationController {
                    
                    if statusData == true {
                           viewController.onTemp = false
                       } else {
                           viewController.onTemp = true
                       }
                       
                       viewController.customer = customer
                       viewController.carte = carte
                    
                       for i in 0 ..< self.cartesData.count {
                           
                           for j in 0 ..< self.cartesData[i].medias.count {
                               if self.cartesData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                   viewController.media = self.cartesData[i].medias[j]
                                   viewController.picCurrIndex = self.cartesData[i].medias.count
                               }
                           }
                       }
                       navigator.pushViewController(viewController, animated: true)
                       removeAllData()
                       SVProgressHUD.dismiss()
                }
            }
            #else
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "DrawingVC") as? DrawingVC {
                if let navigator = self.navigationController {
                
                    if statusData == true {
                        viewController.onTemp = false
                    } else {
                        viewController.onTemp = true
                    }
                    
                    viewController.customer = customer
                    viewController.carte = carte
                 
                    for i in 0 ..< self.cartesData.count {
                        
                        for j in 0 ..< self.cartesData[i].medias.count {
                            if self.cartesData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                viewController.media = self.cartesData[i].medias[j]
                                viewController.picCurrIndex = self.cartesData[i].medias.count
                            }
                        }
                    }
                    navigator.pushViewController(viewController, animated: true)
                    removeAllData()
                    SVProgressHUD.dismiss()
                }
            }
            #endif
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_DRAWING_ACCESS_NOT_SATISFY, view: self)
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onExportPhoto(_ sender: LGButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            Utils.showAlert(message: MSG_ALERT.kALERT_PLEASE_SELECT_PHOTO, view: self)
            return
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 5 {
            Utils.showAlert(message: "Could not select more than 5 Photos", view: self)
            return
        }
        
        var urlMedia = [URL]()
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        for k in 0 ..< GlobalVariables.sharedManager.selectedImageIds.count {
            for i in 0 ..< self.cartesData.count {
                for j in 0 ..< self.cartesData[i].medias.count {
                    if GlobalVariables.sharedManager.selectedImageIds[k] == cartesData[i].medias[j].media_id {
                        urlMedia.append(URL.init(string: self.cartesData[i].medias[j].url)!)
                    }
                }
            }
        }
        
        //do a loop increment
        let sequence = stride(from: 0, to: urlMedia.count, by: 1)
        for no in sequence {
            Utils.saveImageToCameraRoll(url: urlMedia[no]) { (success) in
                if success {
                    if no == urlMedia.count - 1 {
                        Utils.showAlert(message: "画像の保存しました。", view: self)
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_PHOTO, view: self)
                    SVProgressHUD.dismiss()
                    return
                }
            }
        }
        
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension PhotoCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "photoCollectCell", for: indexPath) as! photoCollectCell
    
        cell.type = 1
        cell.configure(media: cartesData[indexPath.section].medias[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cartesData[section].medias.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cartesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectCell
        
        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds.append(imageID!)
        
        checkButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectCell
        
        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds = GlobalVariables.sharedManager.selectedImageIds.filter({ $0 != imageID })
        
        checkButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
                fatalError("Could not find proper header")
            }
            
            let dayCome = Utils.convertUnixTimestamp(time: cartesData[indexPath.section].select_date)
            header.sectionLabel.text = "カルテ・\(dayCome)"
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if cartesData[section].medias.count > 0 {
            return CGSize(width: self.view.bounds.width, height: 40)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}

//*****************************************************************
// MARK: - photoCollectCell Delegate
//*****************************************************************

extension PhotoCollectionVC: photoCollectCellDelegate {
    func didZoom(index: Int) {
        let newPopup = PhotoViewPopup(nibName: "PhotoViewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        
        for i in 0 ..< self.cartesData.count {
            for j in 0 ..< self.cartesData[i].medias.count {
                if self.cartesData[i].medias[j].id == index {
                    newPopup.imgURL = cartesData[i].medias[j].url
                    newPopup.mediaID = cartesData[i].medias[j].media_id
                }
            }
        }
        self.present(newPopup, animated: true, completion: nil)
    }
}
