//
//  CarteImageListVC.swift
//  ABCarte2
//
//  Created by Long on 2018/06/25.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import Photos
import Pickle
import LGButton

class CarteImageListVC: BaseVC,UINavigationControllerDelegate {

    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var medias: Results<MediaData>!
    var mediasData : [MediaData] = []
    
    var carteID: String?
    var needLoad: Bool = true
    var onProgress: Bool = false
    var imageSelected: UIImage?
    var imageConverted: Data?
    var indexDelete : [Int] = []
    
    var account_name: String = ""
    var account_id: String = ""
    var accountPicLimit: Int?

    //IBOutlet
    @IBOutlet weak var btnCamera: LGButton!
    @IBOutlet weak var btnCameraRoll: LGButton!
    @IBOutlet weak var collectionImage: UICollectionView!
    
    @IBOutlet weak var btnComparison: LGButton!
    @IBOutlet weak var btnDrawing: LGButton!
    @IBOutlet weak var btnDelete: LGButton!
    @IBOutlet weak var btnExport: LGButton!
    
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    
    @IBOutlet weak var viewPanelTop: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var constraintWCamera: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
        indexDelete.removeAll()
        mediasData.removeAll()
    }

    func loadData() {
        if needLoad == true {
            //add loading view
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
          
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(MediaData.self))
            }
            
            APIRequest.getCarteMedias(carteID: carte.id) { (success) in
                if success {
                    self.medias = realm.objects(MediaData.self)
                    self.mediasData.removeAll()
                    
                    for i in 0 ..< self.medias.count {
                        self.mediasData.append(self.medias[i])
                    }
                    self.mediasData = self.mediasData.sorted(by: { $0.date > $1.date })
                    
                    self.collectionImage.reloadData()
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                SVProgressHUD.dismiss()
            }
            needLoad = false
        }
    }

    func setupUI() {
        let button = LGButton()
        button.leftImageSrc = UIImage(named: "icon_photo_white.png")
        button.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Image Management", comment: "")
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

        collectionImage.delegate = self
        collectionImage.dataSource = self
        collectionImage.layer.cornerRadius = 10
        collectionImage.clipsToBounds = true
        collectionImage.allowsMultipleSelection = true

        updateTopView()
        
        //Check current with carte date to show Camera Button
        let dayCome = Utils.convertUnixTimestamp(time: carte.select_date)
        lblDayCome.text = dayCome
        
        let currDate = Date()
        let timeInterval = Int(currDate.timeIntervalSince1970)
        let date = Utils.convertUnixTimestamp(time: timeInterval)
        
        if dayCome != date {
            //different date
            btnCamera.isHidden = true
            constraintWCamera.constant = 0
        } else {
            //same with current date
            btnCamera.isHidden = false
            constraintWCamera.constant = 130
        }
        Utils.setViewColorStyle(view: viewPanelTop, type: 1)
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPhotoExport.rawValue) {
            btnExport.isHidden = false
        }
        
        localizeLanguage()
        bottomPanelView.deactiveBottomPanelButtons()
    }
    
    func updateTopView() {
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, completed: nil)
        } else {
            imvCus.image = UIImage(named: "img_no_photo")
        }
        
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true
        
        lblCusName.text = customer.last_name + " " + customer.first_name
    }
    
    fileprivate func localizeLanguage() {
        btnCamera.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Take Photo", comment: "")
        btnCameraRoll.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Camera Roll", comment: "")
        btnComparison.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Comparison", comment: "")
        btnDelete.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Delete", comment: "")
        btnDrawing.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Drawing", comment: "")
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }

    func removeAllMemoData() {
        let dict : [String : Any?] = ["selected_status" : 0]
        
        for i in 0 ..< mediasData.count {
            RealmServices.shared.update(self.mediasData[i], with: dict)
        }
    }

    //*****************************************************************
    // MARK: - Action
    //*****************************************************************

    @IBAction func onExport(_ sender: LGButton) {
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
        
        for i in 0 ..< GlobalVariables.sharedManager.selectedImageIds.count {
            for j in 0 ..< mediasData.count {
                if GlobalVariables.sharedManager.selectedImageIds[i] == mediasData[j].media_id {
                    urlMedia.append(URL.init(string: mediasData[j].url)!)
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
    
    @IBAction func onCamera(_ sender: LGButton) {
        let totalImage = self.mediasData.count
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
            if let acclimit = accountPicLimit {
                if totalImage >= acclimit {
                    Utils.showAlert(message: MSG_ALERT.kALERT_REACH_LIMIT_PHOTO, view: self)
                    return
                }
            }
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 || GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            guard let storyBoard = UIStoryboard(name: "Media", bundle: nil) as UIStoryboard? else { return }
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "ShootingVC") as? ShootingVC {
                if let navigator = navigationController {
                    viewController.customer = customer
                    viewController.carte = carte
                    
                    //check limit
                    if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                        viewController.onLimit = (accountPicLimit ?? 0) - totalImage
                    }
                    
                    if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                        
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                            for i in 0 ..< self.mediasData.count {
                                if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                    viewController.media = mediasData[i]
                                }
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_SHOOTING_TRANMISSION_NOT_ALLOW, view: self)
                            return
                        }
                    }
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else {
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                Utils.showAlert(message: MSG_ALERT.kALERT_SHOOTING_TRANMISSION_NOT_SATISFY, view: self)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_SHOOTING_TRANMISSION_NOT_ALLOW, view: self)
            }
            
        }
    }

    @IBAction func onCameraRoll(_ sender: LGButton) {
        var parameters = Pickle.Parameters()
        var limitPics = 5
        //check limit pics
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
            guard let limit = self.mediasData.count as Int?,let acclimit = accountPicLimit else { return }
            
            if limit >= acclimit {
                Utils.showAlert(message: MSG_ALERT.kALERT_REACH_LIMIT_PHOTO, view: self)
                return
            } else {
                if acclimit >= limitPics {
                    limitPics = limitPics - limit
                } else {
                    limitPics = acclimit - limit
                }
            }
        }
        
        parameters.allowedSelections = .limit(to: limitPics)
        let picker = ImagePickerController(configuration: parameters)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func requestPhotoAccess() {
        //request Photo Access
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    print("Granted access to Photo")
                } else {
                    // Create Alert
                    let alert = UIAlertController(title: "写真設定", message: "写真設定がOFFになっています。ONにしてください。", preferredStyle: .alert)
                    
                    // Add "OK" Button to alert, pressing it will bring you to the settings app
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                    // Show the alert with animation
                    self.present(alert, animated: true)
                }
            })
        } else if photos == .denied {
            PHPhotoLibrary.requestAuthorization({ status in
                
                if status == .authorized {
                    print("Granted access to Photo")
                } else {
                    // Create Alert
                    let alert = UIAlertController(title: "写真設定", message: "写真設定がOFFになっています。ONにしてください。", preferredStyle: .alert)
                    
                    // Add "OK" Button to alert, pressing it will bring you to the settings app
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                    // Show the alert with animation
                    self.present(alert, animated: true)
                }
            })
        }
    }

    @IBAction func onDelete(_ sender: LGButton) {
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 0 {
            let alert = UIAlertController(title: "選択画像を削除", message: MSG_ALERT.kALERT_CONFIRM_DELETE_PHOTO_SELECTED, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                for i in 0 ..< self.mediasData.count {
                    if self.mediasData[i].selected_status == 1 {
                        self.indexDelete.append(self.mediasData[i].id)
                    }
                }
                APIRequest.deleteMedias(ids: self.indexDelete, completion: { (success) in
                    if success {
                        self.needLoad = true
                        self.loadData()
                    } else {
                        Utils.showAlert(message: "削除に失敗しました。", view: self)
                    }
                })
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                SVProgressHUD.dismiss()
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_PLEASE_SELECT_PHOTO, view: self)
        }
        
    }

    @IBAction func onComparison(_ sender: LGButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 2 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "ComparisonVC") as? ComparisonVC {
                if let navigator = navigationController {
                    viewController.customer = customer
                    viewController.carte = carte
                    viewController.picLimit = accountPicLimit
                    viewController.picCurrIndex = mediasData.count
                    for i in 0 ..< mediasData.count {
                        if mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                            viewController.media1 = mediasData[i]
                        }
                        if mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[1] {
                            viewController.media2 = mediasData[i]
                        }
                    }
                    GlobalVariables.sharedManager.selectedImageIds.removeAll()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else if GlobalVariables.sharedManager.selectedImageIds.count > 2 && GlobalVariables.sharedManager.selectedImageIds.count < 13 {
            
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMorphing.rawValue) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "MorphingVC") as? MorphingVC {
                    if let navigator = navigationController {
                        viewController.customer = customer
                        viewController.carte = carte
                        
                        for i in 0 ..< GlobalVariables.sharedManager.selectedImageIds.count {
                            for j in 0 ..< mediasData.count {
                                if GlobalVariables.sharedManager.selectedImageIds[i] == mediasData[j].media_id {
                                    viewController.mediasData.append(mediasData[j])
                                }
                            }
                        }
                        GlobalVariables.sharedManager.selectedImageIds.removeAll()
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CHOOSE_ONLY_2_PHOTOS, view: self)
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_CHOOSE_2_TO_12_PHOTOS, view: self)
        }
    }

    @IBAction func onDrawing(_ sender: LGButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
            #if ATTENDER
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "OldDrawingVC") as? OldDrawingVC {
                if let navigator = self.navigationController {
                    viewController.customer = self.customer
                    viewController.carte = self.carte
                    viewController.picCurrIndex = self.mediasData.count
                    if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                        for i in 0 ..< self.mediasData.count {
                            if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                viewController.media = self.mediasData[i]
                            }
                        }
                    }
                    GlobalVariables.sharedManager.selectedImageIds.removeAll()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            #else
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "DrawingVC") as? DrawingVC {
                if let navigator = self.navigationController {
                    viewController.customer = self.customer
                    viewController.carte = self.carte
                    viewController.picCurrIndex = self.mediasData.count
                    if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                        for i in 0 ..< self.mediasData.count {
                            if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                viewController.media = self.mediasData[i]
                            }
                        }
                    }
                    GlobalVariables.sharedManager.selectedImageIds.removeAll()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            #endif
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_DRAWING_ACCESS_NOT_SATISFY, view: self)
        }
    }
}

//*****************************************************************
// MARK: - ImagePicker Delegate
//*****************************************************************

extension CarteImageListVC: ImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: ImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: ImagePickerController, shouldLaunchCameraWithAuthorization status: AVAuthorizationStatus) -> Bool {
        return true
    }
    
    func imagePickerController(_ picker: ImagePickerController, didFinishPickingImageAssets assets: [PHAsset]) {

        SVProgressHUD.show(withStatus: "読み込み中")
        
        let imageArr = getAssetsData(assets: assets)

        APIRequest.onAddMultiMediasIntoCarte(carteID: carte.id, mediaData: imageArr, progressHandler: { (progress) in
            SVProgressHUD.showProgress(Float(progress), status: "読み込み中 : \(Int(progress)*100)%")
        }) { (success) in
            if success {
                self.needLoad = true
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                picker.dismiss(animated: true, completion: {
                    self.loadData()
                    SVProgressHUD.dismiss()
                })
            } else {
                picker.dismiss(animated: true, completion: {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    SVProgressHUD.dismiss()
                })
            }
        }
    }
    
    func getAssetsData(assets: [PHAsset]) -> [Data] {
        
        var arrayOfImages = [Data]()
        for asset in assets {
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            // this one is key
            requestOptions.isSynchronous = true
            requestOptions.isNetworkAccessAllowed = true
            
            manager.requestImage(for: asset, targetSize: CGSize(width: 1152, height: 1536), contentMode: .aspectFit, options: requestOptions, resultHandler: {(result, info)->Void in
                
                let imageView = UIImageView.init(image: UIImage.init(color: UIColor.white, size: CGSize(width: 1152, height: 1536)))
                imageView.contentMode = .scaleAspectFit
                imageView.image = result!
                
                if let data = Utils.imageWithImage(sourceImage: imageView.asImage(), scaledToWidth: 1152).jpegData(compressionQuality: 0.75) {
                    arrayOfImages.append(data)
                }
            })
        }
    
        return arrayOfImages
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate
//*****************************************************************

extension CarteImageListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarteImageCell", for: indexPath) as? CarteImageCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.configure(media: mediasData[indexPath.row])
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediasData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CarteImageCell else {
            return
        }
        let dict : [String : Any?] = ["selected_status" : 1]
        RealmServices.shared.update(self.mediasData[indexPath.row], with: dict)

        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds.append(imageID!)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? CarteImageCell else {
            return
        }
        let dict : [String : Any?] = ["selected_status" : 0]
        RealmServices.shared.update(self.mediasData[indexPath.row], with: dict)

        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds = GlobalVariables.sharedManager.selectedImageIds.filter({ $0 != imageID })
    }
}

extension CarteImageListVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

//*****************************************************************
// MARK: - CarteImageCell Delegate
//*****************************************************************

extension CarteImageListVC: CarteImageCellDelegate {
    
    func didZoom(index: Int) {
        let newPopup = PhotoViewPopup(nibName: "PhotoViewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        
        for i in 0 ..< mediasData.count {
            if mediasData[i].id == index {
                newPopup.imgURL = mediasData[i].url
                newPopup.mediaID = mediasData[i].media_id
                newPopup.delegate = self
                newPopup.type = 1
            }
        }
        
        self.present(newPopup, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - PhotoCollectionVC Delegate
//*****************************************************************

extension CarteImageListVC: PhotoViewPopupDelegate {
    
    func onSetCartePhoto(mediaID: String,url: String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let delimiter = "uploads"
        guard let path = url.components(separatedBy: delimiter).last else { return }
        
        APIRequest.onEditCartePhotoRepresentative(carteID: carte.id, mediaURL: "\(delimiter)\(path)") { (success) in
            if success {
                self.dismiss(animated: true, completion: {
                    Utils.showAlert(message: MSG_ALERT.kALERT_REGISTER_CARTE_REPRESENTATIVE_SUCCESS, view: self)
                })
            } else {
                self.dismiss(animated: true, completion: {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                })
            }
            SVProgressHUD.dismiss()
        }
    }
}
