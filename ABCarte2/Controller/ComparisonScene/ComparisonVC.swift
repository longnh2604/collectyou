//
//  ComparisonVC.swift
//  ABCarte2
//
//  Created by Long on 2018/06/26.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import LGButton

class ComparisonVC: UIViewController {

    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var media1 = MediaData()
    var media2 = MediaData()
    
    var cusIndex : Int?
    var carteIndex: Int?
    var compareTool: Int = 0
    var picSelected: Int = 1
    var needLoad: Bool = true
    var carteIDTemp: Int?
    var imageConverted: Data?
    var onTemp: Bool = false
    var onSave: Bool = false
    var picCurrIndex: Int?
    var picLimit: Int?
    
    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var btnLR: LGButton!
    @IBOutlet weak var btnUD: LGButton!
    @IBOutlet weak var btnTRA: LGButton!
    @IBOutlet weak var btnPrinter: RoundButton!
    @IBOutlet weak var btnDrawing: LGButton!
    //compare
    @IBOutlet weak var viewCompare: UIView!
    @IBOutlet weak var scrollLRL: UIScrollView!
    @IBOutlet weak var imvLRL: UIImageView!
    @IBOutlet weak var scrollLRR: UIScrollView!
    @IBOutlet weak var imvLRR: UIImageView!
    //updown
    @IBOutlet weak var viewUpDown: UIView!
    @IBOutlet weak var scrollUDU: UIScrollView!
    @IBOutlet weak var imvUDU: UIImageView!
    @IBOutlet weak var scrollUDD: UIScrollView!
    @IBOutlet weak var imvUDD: UIImageView!
    //tranmission
    @IBOutlet weak var viewTranmission: UIView!
    @IBOutlet weak var scrollTRA1: UIScrollView!
    @IBOutlet weak var imvTRA1: UIImageView!
    @IBOutlet weak var scrollTRA2: UIScrollView!
    @IBOutlet weak var imvTRA2: UIImageView!
    @IBOutlet weak var sliderTranmission: MySlider!
    @IBOutlet weak var onPhoto1: RoundButton!
    @IBOutlet weak var onPhoto2: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set pic limit index
        if (picCurrIndex == nil) {
            picCurrIndex = 0
        }
        
        setupLayout()
    }
   
    fileprivate func setupLayout() {
        //set navigation bar title
        let button = LGButton()
        button.leftImageSrc = UIImage(named: "icon_comparison_white.png")
        button.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Comparison", comment: "")
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
        
        updateTopView()
        
        setViewandButton(type: compareTool)
        
        if onTemp == false {
            imvLRL.sd_setImage(with: URL(string: media1.url)) { (image, error, type, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                } else {
                    self.imvUDU.image = image
                    self.imvTRA1.image = image
                }
            }
            
            imvLRR.sd_setImage(with: URL(string: media2.url)) { (image, error, type, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                } else {
                    self.imvUDD.image = image
                    self.imvTRA2.image = image
                }
            }
        } else {
         
            imvLRL.sd_setImage(with: URL(string: media1.url)) { (image, error, type, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                } else {
                    self.imvUDU.image = image
                    self.imvTRA1.image = image
                }
            }
            
            imvLRR.sd_setImage(with: URL(string: media2.url)) { (image, error, type, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                } else {
                    self.imvUDD.image = image
                    self.imvTRA2.image = image
                }
            }
        }
        
        scrollLRL.delegate = self
        scrollLRL.minimumZoomScale = 0.5
        scrollLRL.maximumZoomScale = 10.0
        scrollLRL.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollLRR.delegate = self
        scrollLRR.minimumZoomScale = 0.5
        scrollLRR.maximumZoomScale = 10.0
        scrollLRR.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollLRL.zoomScale = 2.0
        scrollLRR.zoomScale = 2.0
        scrollLRL.contentInset.left = 50
        scrollLRL.contentInset.right = 50
        scrollLRR.contentInset.left = 50
        scrollLRR.contentInset.right = 50
        
        scrollUDU.delegate = self
        scrollUDU.minimumZoomScale = 0.5
        scrollUDU.maximumZoomScale = 10.0
        scrollUDU.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollUDU.zoomScale = 1.2
        
        scrollUDD.delegate = self
        scrollUDD.minimumZoomScale = 0.5
        scrollUDD.maximumZoomScale = 10.0
        scrollUDD.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollUDD.zoomScale = 1.2
        
        scrollTRA1.delegate = self
        scrollTRA1.minimumZoomScale = 0.5
        scrollTRA1.maximumZoomScale = 10.0
        scrollTRA1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollTRA1.zoomScale = 1.2
        
        scrollTRA2.delegate = self
        scrollTRA2.minimumZoomScale = 0.5
        scrollTRA2.maximumZoomScale = 10.0
        scrollTRA2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollTRA2.zoomScale = 1.2
        
        sliderTranmission.minimumValue = 0
        sliderTranmission.maximumValue = 1
        sliderTranmission.value = 0.5
        
        imvTRA1.alpha = CGFloat(sliderTranmission.value)
        imvTRA2.alpha = CGFloat(sliderTranmission.value)
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kComparePrinter.rawValue) {
            btnPrinter.isHidden = false
        } else {
            btnPrinter.isHidden = true
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCompareTranmission.rawValue) {
            btnTRA.isHidden = false
        } else {
            btnTRA.isHidden = true
        }
        
        localizeLanguage()
    }
    
    fileprivate func localizeLanguage() {
        btnLR.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Left Right", comment: "")
        btnUD.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Up Down", comment: "")
        btnTRA.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Tranmission", comment: "")
        btnDrawing.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Drawing", comment: "")
    }
    
    fileprivate func updateTopView() {

        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, completed: nil)
        } else {
            imvCus.image = UIImage(named: "img_no_photo")
        }
        
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true
        
        lblCusName.text = customer.last_name + " " + customer.first_name
        
        if onTemp == false {
            let dayCome = Utils.convertUnixTimestamp(time: carte.select_date)
            lblDayCome.text = dayCome
            carteIDTemp = carte.id
        } else {
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            let date = Utils.convertUnixTimestamp(time: timeInterval)
            lblDayCome.text = date
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setViewandButton(type:Int) {
        switch type {
        case 0:
            btnLR.backgroundColor = COLOR_SET.kCOMPARE_TOOL_SELECT
            btnUD.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
            btnTRA.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
            viewCompare.isHidden = false
            viewTranmission.isHidden = true
            viewUpDown.isHidden = true
            sliderTranmission.isHidden = true
            onPhoto1.isHidden = true
            onPhoto2.isHidden = true
            break
        case 1:
            btnLR.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
            btnUD.backgroundColor = COLOR_SET.kCOMPARE_TOOL_SELECT
            btnTRA.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
            viewCompare.isHidden = true
            viewUpDown.isHidden = false
            viewTranmission.isHidden = true
            sliderTranmission.isHidden = true
            onPhoto1.isHidden = true
            onPhoto2.isHidden = true
            break
        case 2:
            btnLR.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
            btnUD.backgroundColor = COLOR_SET.kCOMPARE_TOOL_UNSELECT
            btnTRA.backgroundColor = COLOR_SET.kCOMPARE_TOOL_SELECT
            viewCompare.isHidden = true
            viewUpDown.isHidden = true
            viewTranmission.isHidden = false
            sliderTranmission.isHidden = false
            onPhoto1.isHidden = false
            onPhoto2.isHidden = false
            break
        default:
            break
        }
    }
    
    fileprivate func onSaveImage(image: UIImage) {
        
        DispatchQueue.main.async {
        
            if self.onSave == true { return }
            
            SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            self.onSave = true
            
            self.imageConverted = image.jpegData(compressionQuality: 0.7)
            
            if self.onTemp == false {
                APIRequest.onAddMediaIntoCarte(carteID: self.carteIDTemp!, mediaData: self.imageConverted!, completion: { (success) in
                    if success {
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                            if let index = self.picCurrIndex {
                                self.picCurrIndex = index + 1
                            }
                        }
                        Utils.showAlert(message: "画像の保存しました。", view: self)
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                    self.onSave = false
                    SVProgressHUD.dismiss()
                })
            } else {
                let currDate = Date()
                let timeInterval = Int(currDate.timeIntervalSince1970)
                
                //Create Carte first
                APIRequest.onAddCarteWithMedias(cusID: self.customer.id, date: timeInterval, mediaData: self.imageConverted!, completion: { (status,carteData) in
                    if status == 1 {
                        self.onTemp = false
                        self.carteIDTemp = carteData.id
                        
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                            if let index = self.picCurrIndex {
                                self.picCurrIndex = index + 1
                            }
                        }
                        Utils.showAlert(message: "画像の保存しました。", view: self)
                    } else if status == 2 {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
                        _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        Utils.showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    self.onSave = false
                    SVProgressHUD.dismiss()
                })
            }
        }   
    }
    
    func calculateRectOfImageInImageView(imageView: UIImageView) -> CGRect {
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size

        guard let imageSize = imgSize else {
            return CGRect.zero
        }

        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)

        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2

        // Add imageView offset
        imageRect.origin.x += imageView.frame.origin.x
        imageRect.origin.y += imageView.frame.origin.y

        return imageRect
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onToolSelect(_ sender: LGButton) {
        switch sender.tag {
        case 1:
            compareTool = 0
            setViewandButton(type: 0)
            break
        case 2:
            compareTool = 1
            setViewandButton(type: 1)
            break
        case 3:
            compareTool = 2
            setViewandButton(type: 2)
            break
        default:
            break
        }
    }
    
    @IBAction func onTranmissionChange(_ sender: UISlider) {
        imvTRA2.alpha = CGFloat(sender.value)
        imvTRA1.alpha = CGFloat(1.0 - sender.value)
    }
    
    @IBAction func onPhotoSelect(_ sender: UIButton) {
        if sender.tag == 1 {
            picSelected = 1
            scrollTRA1.isUserInteractionEnabled = true
            scrollTRA2.isUserInteractionEnabled = false
        } else {
            picSelected = 2
            scrollTRA1.isUserInteractionEnabled = false
            scrollTRA2.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func onPrint(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
            var url = URL.init(string: "")
            if compareTool == 0 {
                url = Utils.saveImageToLocal(imageDownloaded: viewCompare.asImage(), name: customer.first_name)
            } else  if compareTool == 1 {
                url = Utils.saveImageToLocal(imageDownloaded: viewUpDown.asImage(), name: customer.first_name)
            } else  if compareTool == 2 {
                url = Utils.saveImageToLocal(imageDownloaded: viewTranmission.asImage(), name: customer.first_name)
            }
            Utils.printUrl(url: url!)
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
    @IBAction func onDrawing(_ sender: LGButton) {
        
        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            #if ATTENDER
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "OldDrawingVC") as? OldDrawingVC {
                if let navigator = self.navigationController {
                    
                    viewController.customer = self.customer
                    viewController.carte = self.carte
                    viewController.onTemp = self.onTemp
                    viewController.onComparison = true
                    viewController.picCurrIndex = self.picCurrIndex
                    
                    let imageView = UIImageView.init(image: UIImage.init(color: UIColor.lightGray, size: CGSize(width: 1536, height: 2048)))
                    imageView.contentMode = .scaleAspectFit
                    
                    if self.compareTool == 0 {
                        imageView.image = self.viewCompare.asImage()
                    } else  if self.compareTool == 1 {
                        imageView.image = self.viewUpDown.asImage()
                    } else  if self.compareTool == 2 {
                        imageView.image = self.viewTranmission.asImage()
                    }
                    viewController.photoData = imageView.asImage()
                    
                    SVProgressHUD.dismiss()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            #else
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "DrawingVC") as? DrawingVC {
                if let navigator = self.navigationController {
                    viewController.customer = self.customer
                    viewController.carte = self.carte
                    viewController.onTemp = self.onTemp
                    viewController.onComparison = true
                    viewController.picCurrIndex = self.picCurrIndex
                    
                    let imageView = UIImageView.init(image: UIImage.init(color: UIColor.lightGray, size: CGSize(width: 1536, height: 2048)))
                    imageView.contentMode = .scaleAspectFit
                    
                    if self.compareTool == 0 {
                        imageView.image = self.viewCompare.asImage()
                    } else  if self.compareTool == 1 {
                        imageView.image = self.viewUpDown.asImage()
                    } else  if self.compareTool == 2 {
                        imageView.image = self.viewTranmission.asImage()
                    }
                    viewController.photoData = imageView.asImage()
                    
                    SVProgressHUD.dismiss()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            #endif
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        //check pic limit
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
            if let index = picCurrIndex,let limit = picLimit {
                if index >= limit {
                    Utils.showAlert(message: MSG_ALERT.kALERT_REACH_LIMIT_PHOTO, view: self)
                    return
                }
            }
        }

       let image = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 1536, height: 2048))
       image.contentMode = .scaleAspectFit
       if compareTool == 0 {
            image.image = viewCompare.asImage()
       } else  if compareTool == 1 {
            image.image = viewUpDown.asImage()
       } else  if compareTool == 2 {
            image.image = viewTranmission.asImage()
       }
       onSaveImage(image: Utils.saveImageEdit(viewMake: image))
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension ComparisonVC: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        var imageView = UIImageView()
        
        switch scrollView.tag {
        case 1:
            imageView = imvLRL
        case 2:
            imageView = imvLRR
        case 3:
            imageView = imvUDU
        case 4:
            imageView = imvUDD
        case 5:
            imageView = imvTRA1
        case 6:
            imageView = imvTRA2
        default:
            break
        }
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        if verticalPadding >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding + 200, left: horizontalPadding + 200, bottom: verticalPadding + 200, right: horizontalPadding + 200)
        } else {
            scrollView.contentSize = imageViewSize
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        var imv = UIImageView()
        switch scrollView.tag {
        case 1:
            imv = imvLRL
            break
        case 2:
            imv = imvLRR
            break
        case 3:
            imv = imvUDU
            break
        case 4:
            imv = imvUDD
            break
        case 5:
            imv = imvTRA1
            break
        case 6:
            imv = imvTRA2
            break
        default:
            break
        }
        return imv
    }
}
