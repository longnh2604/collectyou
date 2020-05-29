//
//  DrawingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import EFColorPicker
import IQKeyboardManagerSwift

class DrawingVC: UIViewController {
    
    //Variable
    var isEdited: Bool = false
    var onTemp: Bool = false
    var isPanelExpanded: Bool = false
    
    var accounts: Results<AccountData>!
    
    var customer = CustomerData()
    var carte = CarteData()
    var media = MediaData()
    
    var imageViewToPan: UIImageView?
    var stickersVCIsVisible = false
    var lastPanPoint: CGPoint?
    var lockZoom: Bool = false
    var imageData: Data?
    let imvDraw = UIImageView()
    
    var isTyping: Bool = false
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var textField: UITextField?
    let maxScale: CGFloat = 100.0
    let minScale: CGFloat = 0.5
    var cumulativeScale:CGFloat = 1.0
    var textLocation: CGPoint?
    var picRes = 1
    var carteIDTemp: Int?
    var onSave: Bool = false
    var onComparison : Bool = false
    var photoData: UIImage?
    var picCurrIndex: Int?
    
    var stampIndex = 1
    
    weak var drawingPanelView: DrawingPanelView!
    
    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var stickerView: UIImageView!
    
    //TopView
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var deleteView: UIView!
    
    //DrawPanel View
    @IBOutlet weak var btnSlideUp: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var hPanelConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadData()
        
        setupLayout()
    }
    
    fileprivate func loadData() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(AccountData.self))
        }
        
        APIRequest.getAccountInfo { (success) in
            if success {
                let realm = try! Realm()
                self.accounts = realm.objects(AccountData.self)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
        //set pic limit index
        if (picCurrIndex == nil) {
            picCurrIndex = 0
        }
    }
   
    fileprivate func setupLayout() {
        let button =  UIButton(type: .custom)
        if LocalizationSystem.sharedInstance.getLanguage() == "en" {
            button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 40, bottom: 0, right: 170)
        } else if LocalizationSystem.sharedInstance.getLanguage() == "ja" {
            button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 40, bottom: 0, right: 160)
        } else {
            button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 40, bottom: 0, right: 160)
        }
        button.setImage(UIImage(named: "icon_drawing_white.png"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Drawing", comment: ""), for: .normal)
        navigationItem.titleView = button

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        updateTopView()
        updatePanelDrawingView()
        
        setupCanvas()
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.black.cgColor
        deleteView.clipsToBounds = true
    }
    
    fileprivate func setupCanvas() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
  
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.2
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if onComparison == true {
            switch photoData?.size.width {
            case 768:
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 768, height: 1024)
                self.sketchView.loadImage(image: photoData!,topTrans: false)
            case 1152:
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1152, height: 1536)
                self.sketchView.loadImage(image: photoData!,topTrans: false)
                self.picRes = 2
            case 1536:
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                self.sketchView.loadImage(image: photoData!,topTrans: false)
                self.picRes = 3
            default:
                let resizeImage = Utils.imageWithImage(sourceImage: photoData!, scaledToWidth: 1536)
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                self.sketchView.loadImage(image: resizeImage,topTrans: false)
                self.picRes = 3
                break
            }
            
            self.viewDrawing.frame = self.sketchView.frame
            self.stickerView.frame = self.sketchView.frame
            
            self.scrollView.contentSize = self.sketchView.frame.size
            //resize to fit
            self.scrollView.zoomScale = self.view.frame.width/self.sketchView.frame.width
        } else {
            guard let url = URL(string: media.url) as URL? else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                SVProgressHUD.dismiss()
                return
            }
            
            imvDraw.sd_setImage(with: url, completed: {(image, err, cacheType, url) in
                
                guard let img = image else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    SVProgressHUD.dismiss()
                    return
                }
                switch image?.size.width {
                case 768:
                    self.sketchView.frame = CGRect(x: 0, y: 0, width: 768, height: 1024)
                    self.sketchView.loadImage(image: img,topTrans: false)
                case 1152:
                    self.sketchView.frame = CGRect(x: 0, y: 0, width: 1152, height: 1536)
                    self.sketchView.loadImage(image: img,topTrans: false)
                    self.picRes = 2
                case 1536:
                    self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                    self.sketchView.loadImage(image: img,topTrans: false)
                    self.picRes = 3
                default:
                    let resizeImage = Utils.imageWithImage(sourceImage: img, scaledToWidth: 1536)
                    self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                    self.sketchView.loadImage(image: resizeImage,topTrans: false)
                    self.picRes = 3
                    break
                }
                
                self.viewDrawing.frame = self.sketchView.frame
                self.stickerView.frame = self.sketchView.frame
                
                self.scrollView.contentSize = self.sketchView.frame.size
                //resize to fit
                self.scrollView.zoomScale = self.view.frame.width/self.sketchView.frame.width
            })
        }
        
        self.sketchView.sketchViewDelegate = self
        self.sketchView.isUserInteractionEnabled = true
        self.sketchView.lineWidth = 5.0
        self.sketchView.lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.sketchView.penMode = 2
        
        self.scrollView.isScrollEnabled = false
        self.checkUndoRedoStatus()
        
        SVProgressHUD.dismiss()
    }
    
    fileprivate func updateTopView() {
        
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: nil)
        } else {
            imvCus.image = UIImage(named: "nophotoIcon")
        }
        
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true
        
        lblCusName.text = customer.last_name + " " + customer.first_name
        
        if onTemp == false {
            let dayCome = Utils.convertUnixTimestamp(time: carte.select_date)
            lblDayCome.text = dayCome
            //get carteID
            carteIDTemp = carte.id
        } else {
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            let date = Utils.convertUnixTimestamp(time: timeInterval)
            lblDayCome.text = date
        }
    }
    
    fileprivate func updatePanelDrawingView() {
        drawingPanelView = DrawingPanelView.instanceFromNib(self)
        bottomView.addSubview(drawingPanelView)
        drawingPanelView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.bottomView)
            make.trailing.equalTo(self.bottomView)
            make.leading.equalTo(self.bottomView)
            make.bottom.equalTo(self.bottomView)
        }
        drawingPanelView.delegate = self
    }

    @objc fileprivate func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        checkPhotoEditOrNot { (success) in
            if success {
                
            } else {
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
     }
    
    fileprivate func checkPhotoEditOrNot(completion:@escaping(Bool) -> ()) {
        
        if isEdited == true {
            let alert = UIAlertController(title: "画像描画", message: MSG_ALERT.kALERT_SAVE_PHOTO_NOTIFICATION, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler:{ (UIAlertAction) in
                completion(false)
            }))
            alert.addAction(UIAlertAction(title: "いいえ", style: .default, handler:{ (UIAlertAction) in
                completion(true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            completion(false)
        }
    }
    
    fileprivate func checkUndoRedoStatus() {
        guard let undo = sketchView?.canUndo() as Bool?,let redo = sketchView?.canRedo() as Bool? else {
            btnUndo.isEnabled = false
            btnRedo.isEnabled = false
            return
        }
        
        if undo == true {
            btnUndo.isEnabled = true
        } else {
            btnUndo.isEnabled = false
        }
        
        if redo == true {
            btnRedo.isEnabled = true
        } else {
            btnRedo.isEnabled = false
        }
    }
    
    //show palette view
    fileprivate func showPaletteView(sender:UIView) {
        let colorSelectionController = EFColorSelectionViewController()
        let navCtrl = UINavigationController(rootViewController: colorSelectionController)
        navCtrl.navigationBar.backgroundColor = sketchView?.lineColor
        navCtrl.navigationBar.isTranslucent = false
        navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
        navCtrl.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        navCtrl.popoverPresentationController?.sourceView = sender
        navCtrl.popoverPresentationController?.sourceRect = sender.bounds
        navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
        
        colorSelectionController.delegate = self
        colorSelectionController.color = (sketchView?.lineColor)!
        
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("OK", comment: ""),
                style: UIBarButtonItem.Style.done,
                target: self,
                action: #selector(ef_dismissViewController(sender:))
            )
            colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
        }
        self.present(navCtrl, animated: true, completion: nil)
    }
    
    fileprivate func onSaveImageData(image: UIImage) {
        
        DispatchQueue.main.async {
            if self.onSave == true { return }
            
            SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            self.onSave = true
            
            self.imageData = image.jpegData(compressionQuality: 0.75)
            
            if self.onTemp == false {
                APIRequest.onAddMediaIntoCarte(carteID: self.carteIDTemp!, mediaData: self.imageData!, completion: { (success) in
                    if success {
                        Utils.showAlert(message: "画像の保存しました。", view: self)
                        
                        if self.isEdited == true {
                            self.isEdited = false
                        }
                        
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                            if let index = self.picCurrIndex {
                                self.picCurrIndex = index + 1
                            }
                        }
                    } else {
                        Utils.showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    self.onSave = false
                    SVProgressHUD.dismiss()
                })
                return
            } else {
                let currDate = Date()
                let timeInterval = Int(currDate.timeIntervalSince1970)
                
                //Create Carte first
                APIRequest.onAddCarteWithMedias(cusID: self.customer.id, date: timeInterval, mediaData: self.imageData!, completion: { (status,carteData) in
                    if status == 1 {
                        self.onTemp = false
                        self.carteIDTemp = carteData.id
                        
                        Utils.showAlert(message: "画像の保存しました。", view: self)
                        
                        if self.isEdited == true {
                            self.isEdited = false
                        }
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                            if let index = self.picCurrIndex {
                                self.picCurrIndex = index + 1
                            }
                        }
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
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSlideUp(_ sender: UIButton) {
        
        if isPanelExpanded == false {
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: UIView.AnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                            self.hPanelConstraints.constant = 125
                            self.btnSlideUp.setImage(UIImage(named: "icon_slidedown_black.png"), for: .normal)
                            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.isPanelExpanded = true
            })
        } else {
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () -> Void in
                            self.hPanelConstraints.constant = 5
                            self.btnSlideUp.setImage(UIImage(named: "icon_slideup_black.png"), for: .normal)
                            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.isPanelExpanded = false
            })
        }
    }
    
    @IBAction func onUndoRedo(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        switch sender.tag {
        case 0:
            print("Undo")
            sketchView.undo {
                self.checkUndoRedoStatus()
            }
        case 1:
            print("Redo")
            sketchView.redo {
                self.checkUndoRedoStatus()
            }
        default:
            break
        }
        SVProgressHUD.dismiss()
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension DrawingVC: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if lockZoom { return }
        guard let imageViewSize = viewDrawing.frame.size as CGSize? else { return }
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        if verticalPadding >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding + 100, left: horizontalPadding + 100, bottom: verticalPadding + 100, right: horizontalPadding + 100)
        } else {
            scrollView.contentSize = imageViewSize
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if lockZoom { return nil }
        return viewDrawing
    }
}

//*****************************************************************
// MARK: - SketchView Delegate
//*****************************************************************

extension DrawingVC: SketchViewDelegate {
    
    func drawView(_ view: SketchView, undo: NSMutableArray, didEndDrawUsingTool tool: AnyObject) {
        if isEdited == false {
            isEdited = true
        }
        checkUndoRedoStatus()
    }
    
    func updateNewColor(color: UIColor) {
        drawingPanelView.onColorChange(color: color)
    }
}

//*****************************************************************
// MARK: - DrawingPanelView Delegate
//*****************************************************************

extension DrawingVC: DrawingPanelViewDelegate {
    
    func onNotAccess() {
        self.lockZoom = false
        self.sketchView.isUserInteractionEnabled = false
        self.stickerView.isUserInteractionEnabled = false
        Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
    }
    
    func onFavColorSetting() {
        let option1 = UIAlertAction(title: "1", style: .default) { _ in
            self.drawingPanelView.onSaveFavoriteColor(color: self.sketchView.lineColor,index: 1)
            self.setColorToAccFavorite(index: 0)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            APIRequest.updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    Utils.showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    Utils.showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option2 = UIAlertAction(title: "2", style: .default) { _ in
            self.drawingPanelView.onSaveFavoriteColor(color: self.sketchView.lineColor,index: 2)
            self.setColorToAccFavorite(index: 1)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            APIRequest.updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    Utils.showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    Utils.showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option3 = UIAlertAction(title: "3", style: .default) { _ in
            self.drawingPanelView.onSaveFavoriteColor(color: self.sketchView.lineColor,index: 3)
            self.setColorToAccFavorite(index: 2)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            APIRequest.updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    Utils.showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    Utils.showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option4 = UIAlertAction(title: "4", style: .default) { _ in
            self.drawingPanelView.onSaveFavoriteColor(color: self.sketchView.lineColor,index: 4)
            self.setColorToAccFavorite(index: 3)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            APIRequest.updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    Utils.showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    Utils.showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option5 = UIAlertAction(title: "5", style: .default) { _ in
            self.drawingPanelView.onSaveFavoriteColor(color: self.sketchView.lineColor,index: 5)
            self.setColorToAccFavorite(index: 4)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            APIRequest.updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    Utils.showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    Utils.showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { _ in }
        
        let alertController = UIAlertController(title: MSG_ALERT.kALERT_SELECT_FAVORITE_COLOR, message: nil, preferredStyle: .alert)
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(option3)
        alertController.addAction(option4)
        alertController.addAction(option5)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setColorToAccFavorite(index:Int) {
        GlobalVariables.sharedManager.accFavoriteColors[index] = (sketchView.lineColor.hexString)
    }
    
    func onFavColorSelect(color:UIColor) {
        sketchView.lineColor = color
    }
    
    func onPenSizeValueChange(value: CGFloat) {
        sketchView.lineWidth = value
    }
    
    func onOpacityValueChange(value: CGFloat) {
        sketchView.lineAlpha = value
    }
    
    func onToolSelect(type: Int,view: UIView) {
        
        self.lockZoom = false
        self.sketchView.isUserInteractionEnabled = true
        self.stickerView.isUserInteractionEnabled = false
        
        switch type {
        case 0:
            sketchView.drawTool = .pen
        case 1:
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"ShapePopupVC") as? ShapePopupVC {
                vc.modalTransitionStyle   = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        case 2:
            sketchView.drawTool = .eraser
        case 3:
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"StickerPopupVC") as? StickerPopupVC {
                vc.modalTransitionStyle   = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        case 4:
            sketchView.isUserInteractionEnabled = false
            showPaletteView(sender: view)
        case 5:
            //check pic limit
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPicLimit.rawValue) {
                if let index = picCurrIndex {
                    if index >= accounts[0].pic_limit {
                        Utils.showAlert(message: MSG_ALERT.kALERT_REACH_LIMIT_PHOTO, view: self)
                        return
                    }
                }
            }
            
            if stickerView.subviews.count > 0 {
                let imgS = stickerView.asImage()
                let imgD = sketchView?.image
                
                onSaveImageData(image: Utils.mergeTwoUIImage(topImage: imgS, bottomImage: imgD!, width: self.sketchView.frame.width, height: self.sketchView.frame.height))
            } else {
                onSaveImageData(image: sketchView.image!)
            }
        case 6:
            sketchView.drawTool = .eyedrop
        case 7:
            setTextView()
        case 8:
            sketchView.drawTool = .rectanglePixel
        case 9:
            if stickerView.subviews.count > 0 {
                let imgS = stickerView.asImage()
                let imgD = sketchView?.image!
                
                let url = Utils.saveImageToLocal(imageDownloaded: Utils.mergeTwoUIImage(topImage: imgS, bottomImage: imgD!, width: self.sketchView.frame.width, height: self.sketchView.frame.height), name: customer.customer_no)
                Utils.printUrl(url: url)
            } else {
                let url = Utils.saveImageToLocal(imageDownloaded: sketchView.image!, name: customer.customer_no)
                Utils.printUrl(url: url)
            }
        default:
            break
        }
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!
            self.textField?.placeholder = "入力して下さい";
        }
    }
    
    func setTextView() {
        
        //block sketchview interact
        self.lockZoom = true
        self.sketchView.isUserInteractionEnabled = false
        self.stickerView.isUserInteractionEnabled = true
        
        guard let newPopup = TextInputPopupVC(nibName: "TextInputPopupVC", bundle: nil) as TextInputPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 350, height: 260)
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - StickerPopupVC Delegate
//*****************************************************************

extension DrawingVC: StickerPopupVCDelegate, UIGestureRecognizerDelegate {
    
    func didClose() {
        //block sketchview interact
        self.lockZoom = true
        self.sketchView.isUserInteractionEnabled = false
        self.stickerView.isUserInteractionEnabled = true
    }
    
    func didStickerSelect(imv: String) {
        
        dismiss(animated: true) {
            if self.isEdited == false {
                self.isEdited = true
            }
            
            let imageView = UIImageView(image: UIImage(named: imv))
            imageView.contentMode = .scaleAspectFit
            imageView.frame.size = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
            imageView.center = self.stickerView.center
            
            imageView.tag = self.stampIndex
            self.stampIndex += 1
            
            self.stickerView.addSubview(imageView)
            
            //Gestures
            self.addGestures(view: imageView)
            
            //block sketchview interact
            self.lockZoom = true
            self.sketchView.isUserInteractionEnabled = false
            self.stickerView.isUserInteractionEnabled = true
            
            //set edit status
            if self.isEdited == false {
                self.isEdited = true
            }
        }
        
    }
    
    fileprivate func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(self.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(self.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    @objc fileprivate func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                if recognizer.state == .began {
                    for imageView in subImageViews(view: stickerView) {
//                        let location = recognizer.location(in: imageView)
//                        let alpha = imageView.alphaAtPoint(location)
//                        if alpha > 0 {
//                            imageViewToPan = imageView
//                            break
//                        }
                        if view.tag == imageView.tag {
                            imageViewToPan = imageView
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doesn't look pixelated
     */
    @objc fileprivate func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                
                switch recognizer.state {
                case .changed:
                    if (cumulativeScale < maxScale && recognizer.scale > 1.0) || (cumulativeScale > minScale && recognizer.scale < 1.0) {
                        let pinchCenter = CGPoint(x: recognizer.location(in: view).x - view.bounds.midX,
                                                  y: recognizer.location(in: view).y - view.bounds.midY)
                        let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                            .scaledBy(x: recognizer.scale, y: recognizer.scale)
                            .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                        view.transform = transform
                        cumulativeScale *= recognizer.scale
                        recognizer.scale = 1
                    }
                default:
                    return
                }
                
//                let textView = view as! UITextView
//
//                if textView.font!.pointSize * recognizer.scale < 90 {
//                    let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
//                    textView.font = font
//                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
//                                                                 height:CGFloat.greatestFiniteMagnitude))
//                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
//                                                  height: sizeToFit.height)
//                } else {
//                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
//                                                                 height:CGFloat.greatestFiniteMagnitude))
//                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
//                                                  height: sizeToFit.height)
//                }
//                textView.setNeedsDisplay()
                
//                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc fileprivate func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    @objc fileprivate func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                for imageView in subImageViews(view: stickerView) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // to Override Control Center screen edge pan from bottom
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     Scale Effect
     */
    fileprivate func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    fileprivate func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        deleteView.isHidden = false
        
        view.superview?.bringSubviewToFront(view)
        let pointToSuperView = recognizer.location(in: self.view)
        
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: stickerView).x,
                              y: view.center.y + recognizer.translation(in: stickerView).y)
        
        recognizer.setTranslation(CGPoint.zero, in: stickerView)
        
        if let previousPoint = lastPanPoint {
            //View is going into deleteView
            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    view.center = recognizer.location(in: self.stickerView)
                })
            }
                //View is going out of deleteView
            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
                //Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    view.center = recognizer.location(in: self.stickerView)
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            
            deleteView.isHidden = true
            
            let point = recognizer.location(in: self.view)
            
            if deleteView.frame.contains(point) { // Delete the view
                view.removeFromSuperview()
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } else if !stickerView.bounds.contains(view.center) { //Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.stickerView.center
                })
                
            }
        }
    }
    
    fileprivate func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
}

//*****************************************************************
// MARK: - ShapePopupVC Delegate
//*****************************************************************

extension DrawingVC: ShapePopupVCDelegate {
    
    func didShapeClose() {
        sketchView.isUserInteractionEnabled = false
    }
    
    func didShapeSelect(index: Int) {
        switch index {
        case 0:
            self.sketchView.drawTool = .line
        case 1:
            self.sketchView.drawTool = .arrow
        case 2:
            self.sketchView.drawTool = .rectangleStroke
        case 3:
            self.sketchView.drawTool = .rectangleFill
        case 4:
            self.sketchView.drawTool = .ellipseStroke
        case 5:
            self.sketchView.drawTool = .ellipseFill
        case 6:
            self.sketchView.drawTool = .star
        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - EFColorSelectionViewControllerDelegate
//*****************************************************************

extension DrawingVC: EFColorSelectionViewControllerDelegate {
    func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        sketchView.lineColor = color
        drawingPanelView.onColorChange(color: color)
    }
    
    // MARK:- Private
    @objc func ef_dismissViewController(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            [weak self] in
            if let _ = self {
                // TODO: You can do something here when EFColorPicker close.
                print("EFColorPicker closed.")
            }
        }
    }
}

//*****************************************************************
// MARK: - TextView Delegate
//*****************************************************************

extension DrawingVC: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        
        self.lockZoom = true
        self.sketchView.isUserInteractionEnabled = false
        self.stickerView.isUserInteractionEnabled = true
        
        guard let newPopup = TextInputPopupVC(nibName: "TextInputPopupVC", bundle: nil) as TextInputPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 350, height: 260)
        newPopup.previousText = textView.text
        textLocation = textView.frame.origin
        textView.removeFromSuperview()
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        textView.font = self.lastTextViewFont!
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }
}

//*****************************************************************
// MARK: - TextInputPopupVC Delegate
//*****************************************************************

extension DrawingVC: TextInputPopupVCDelegate {
    func onSaveText(text: String) {
        
        var size: CGFloat?
        switch picRes {
        case 1:
            size = 50
        case 2:
            size = 75
        case 3:
            size = 100
        default:
            size = 100
        }
        
        if let font = UIFont(name: "Helvetica", size: size!) {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: fontAttributes)
           
            let textView = UITextView.init()
            textView.text = text
            textView.textAlignment = .center
            textView.textColor = sketchView.lineColor
            textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
            textView.layer.shadowOpacity = 0.2
            textView.layer.shadowRadius = 1.0
            textView.layer.backgroundColor = UIColor.clear.cgColor
            textView.autocorrectionType = .no
            textView.font = font
            textView.isScrollEnabled = false
            
            if let location = textLocation {
                textView.frame = CGRect(x: location.x, y: location.y, width: size.width + 20, height: size.height + 20)
                textLocation = nil
            } else {
                textView.frame = CGRect(x: self.stickerView.center.x - ((size.width + 20)/2), y: self.stickerView.center.y,width: size.width + 20, height: size.height + 20)
            }
            
            textView.delegate = self
            self.stickerView.addSubview(textView)
            self.addGestures(view: textView)
            cumulativeScale = 1.0
            
            //set edit status
            if self.isEdited == false {
                self.isEdited = true
            }
        }
    }
    
    func onCancel(text: String) {
        
        var size: CGFloat?
        switch picRes {
        case 1:
            size = 50
        case 2:
            size = 100
        case 3:
            size = 150
        default:
            size = 150
        }
        
        if let font = UIFont(name: "Helvetica", size: size!) {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: fontAttributes)
            
            let textView = UITextView.init()
            textView.text = text
            textView.textAlignment = .center
            textView.textColor = sketchView.lineColor
            textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
            textView.layer.shadowOpacity = 0.2
            textView.layer.shadowRadius = 1.0
            textView.layer.backgroundColor = UIColor.clear.cgColor
            textView.autocorrectionType = .no
            textView.font = font
            textView.isScrollEnabled = false
            
            if let location = textLocation {
                textView.frame = CGRect(x: location.x, y: location.y, width: size.width + 20, height: size.height + 20)
                textLocation = nil
            }
            
            textView.delegate = self
            self.stickerView.addSubview(textView)
            self.addGestures(view: textView)
            cumulativeScale = 1.0
            //set edit status
            if self.isEdited == false {
                self.isEdited = true
            }
        }
    }
}
