//
//  DocumentVC.swift
//  ABCarte2
//
//  Created by Long on 2019/03/29.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class DocumentVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblPageNo: RoundLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var btnFloatMenu: JJFloatingActionButton!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    //Variable
    var customer = CustomerData()
    var document = DocumentData()
    
    var carteID: Int?
    lazy var allowSave: Bool = false
    var docImage = [UIImage]()
    lazy var currPage: Int = 1
    lazy var penMode = 0
    lazy var isModified: Bool = false
    lazy var isEdited: Bool = false
    lazy var lockZoom: Bool = false
    let imvDraw = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupCanvas()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        docImage.removeAll()
        sketchView.clear()
        sketchView.removeFromSuperview()
        btnFloatMenu.removeFromSuperview()
    }
    
    fileprivate func setupLayout() {
        //setup navigation button
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let lbarButton = UIBarButtonItem(customView: btnLeftMenu)
        
        var titleRBar = ""
        if document.is_template == 1 {
            titleRBar = "登録"
            isEdited = true
        } else {
            titleRBar = "編集"
            isEdited = false
        }
        
        self.navigationItem.leftBarButtonItem = lbarButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: titleRBar, style: .plain, target: self, action: #selector(onRegister))
        
        addFloatingButton()
    }
    
    private func checkPenColor() {
        if let status = UserPreferences.appDrawColor {
            switch status {
            case AppDrawColor.black.rawValue:
                sketchView.lineColor = UIColor.black
            case AppDrawColor.red.rawValue:
                sketchView.lineColor = UIColor.red
            case AppDrawColor.blue.rawValue:
                sketchView.lineColor = UIColor.blue
            case AppDrawColor.green.rawValue:
                sketchView.lineColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
            case AppDrawColor.purple.rawValue:
                sketchView.lineColor = UIColor.purple
            default:
                sketchView.lineColor = UIColor.black
            }
        }
    }
    
    private func checkPenType() {
        if let status = UserPreferences.appDrawType {
            switch status {
            case AppDrawType.pencil.rawValue:
                self.sketchView.penMode = 1
                self.penMode = 1
            case AppDrawType.finger.rawValue:
                self.sketchView.penMode = 0
                self.penMode = 0
            default:
                self.sketchView.penMode = 0
                self.penMode = 0
            }
        }
    }
    
    fileprivate func addPenFloat() {
        var image = UIImage.init()
        if penMode == 1 {
            image = UIImage(named: "icon_pencil")!
        } else {
            image = UIImage(named: "icon_finger")!
        }
        btnFloatMenu.addItem(title: "書く", image: image) { item in
            if self.isEdited {
                self.sketchView.drawTool = .pen
                self.sketchView.lineWidth = 1
            } else {
                Utils.showAlert(message: "編集した場合は編集ボタンをタップしてください", view: self)
            }
        }
    }
    
    fileprivate func addFloatingButton() {
        checkPenType()
        //float menu
        btnFloatMenu.configureDefaultItem { item in
            item.titlePosition = .leading
            item.titleSpacing = 16
            
            item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            item.titleLabel.textColor = .white
            item.buttonColor = .white
            
            item.layer.shadowColor = UIColor.black.cgColor
            item.layer.shadowOffset = CGSize(width: 0, height: 1)
            item.layer.shadowOpacity = Float(0.4)
            item.layer.shadowRadius = CGFloat(2)
        }
        
        btnFloatMenu.addItem(title: "描画モード", image: UIImage(named: "icon_setting")) { item in
            let alert = UIAlertController(title: "描画モードを選択してください", message: nil, preferredStyle: .actionSheet)
            let pencil = UIAlertAction(title: "ペンシル", style: .default) { UIAlertAction in
                self.sketchView.penMode = 1
                self.penMode = 1
                UserPreferences.appDrawType = AppDrawType.pencil.rawValue
                self.btnFloatMenu.items.remove(at: 4)
                self.addPenFloat()
            }
            let finger = UIAlertAction(title: "指", style: .default) { UIAlertAction in
                self.sketchView.penMode = 0
                self.penMode = 0
                UserPreferences.appDrawType = AppDrawType.finger.rawValue
                self.btnFloatMenu.items.remove(at: 4)
                self.addPenFloat()
            }
            
            alert.addAction(pencil)
            alert.addAction(finger)
            
            alert.popoverPresentationController?.sourceView = self.btnFloatMenu
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            alert.popoverPresentationController?.sourceRect = self.btnFloatMenu.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        btnFloatMenu.addItem(title: "プリンター", image: UIImage(named: "icon_printer")) { item in
            self.saveImageOnPresentScreen()
            //check if user has edited all page or not
            if self.allowSave {
                Utils.printUrl(url: Utils.generatePDF(images: self.docImage))
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CHECK_ALL_DOCUMENT_PAGE, view: self)
                return
            }
        }
        
        btnFloatMenu.addItem(title: "消ゴム", image: UIImage(named: "icon_eraser")) { item in
            if self.isEdited {
                self.sketchView.drawTool = .eraser
                self.sketchView.lineWidth = 15
            } else {
                Utils.showAlert(message: "編集した場合は編集ボタンをタップしてください", view: self)
            }
        }
        
        btnFloatMenu.addItem(title: "ペンカラー", image: UIImage(named: "icon_pen_color_select.png")) { item in
            let alert = UIAlertController(title: "ペンカラーを選択してください", message: nil, preferredStyle: .actionSheet)
            let black = UIAlertAction(title: "黒", style: .default) { UIAlertAction in
                self.sketchView.lineColor = UIColor.black
                UserPreferences.appDrawColor = AppDrawColor.black.rawValue
            }
            let red = UIAlertAction(title: "赤", style: .default) { UIAlertAction in
                self.sketchView.lineColor = UIColor.red
                UserPreferences.appDrawColor = AppDrawColor.red.rawValue
            }
            let blue = UIAlertAction(title: "青", style: .default) { UIAlertAction in
                self.sketchView.lineColor = UIColor.blue
                UserPreferences.appDrawColor = AppDrawColor.blue.rawValue
            }
            let green = UIAlertAction(title: "緑", style: .default) { UIAlertAction in
                self.sketchView.lineColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
                UserPreferences.appDrawColor = AppDrawColor.green.rawValue
            }
            let purple = UIAlertAction(title: "紫", style: .default) { UIAlertAction in
                self.sketchView.lineColor = UIColor.purple
                UserPreferences.appDrawColor = AppDrawColor.purple.rawValue
            }
            
            alert.addAction(black)
            alert.addAction(red)
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kColorfulPenDoc.rawValue) {
                alert.addAction(blue)
                alert.addAction(green)
                alert.addAction(purple)
            }
            alert.popoverPresentationController?.sourceView = self.btnFloatMenu
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            alert.popoverPresentationController?.sourceRect = self.btnFloatMenu.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        var image = UIImage.init()
        if penMode == 1 {
            image = UIImage(named: "icon_pencil")!
        } else {
            image = UIImage(named: "icon_finger")!
        }
        btnFloatMenu.addItem(title: "書く", image: image) { item in
            if self.isEdited {
                self.sketchView.drawTool = .pen
                self.sketchView.lineWidth = 1
            } else {
                Utils.showAlert(message: "編集した場合は編集ボタンをタップしてください", view: self)
            }
        }
    }
    
    fileprivate func setupCanvas() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.4
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        var stringPath = ""
        let urlEdit = URL(string: document.document_pages[0].url_edit)
        if urlEdit != nil {
            stringPath = document.document_pages[0].url_edit
        } else {
            stringPath = document.document_pages[0].url_original
        }
        guard let url = URL(string: stringPath) as URL? else { fatalError("URL not found") }
   
        imvDraw.sd_setImage(with: url, completed: {(image, err, cacheType, url) in
            guard let img = image else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                SVProgressHUD.dismiss()
                return
            }
            
            switch img.size.width {
            case 1536:
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                    self.sketchView.loadImage(image:  Utils.onGenerateDocumentNumber(number: self.document.document_no, image: img)!,topTrans: false,x:0,y:0)
                } else {
                    self.sketchView.loadImage(image: img, topTrans: false, x: 0, y: 0)
                }
            default:
                let resizeImage = Utils.imageWithImage(sourceImage: Utils.onGenerateDocumentNumber(number: self.document.document_no, image: img)!, scaledToWidth: 1536)
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                    self.sketchView.loadImage(image:  Utils.onGenerateDocumentNumber(number: self.document.document_no, image: resizeImage)!,topTrans: false,x:0,y:0)
                } else {
                    self.sketchView.loadImage(image: resizeImage, topTrans: false, x: 0, y: 0)
                }
            }
            self.viewDrawing.frame = self.sketchView.frame
            self.scrollView.contentSize = self.sketchView.frame.size
            self.scrollView.zoomScale = self.view.frame.width/self.sketchView.frame.width
            
            self.sketchView.sketchViewDelegate = self
            self.sketchView.lineWidth = 1.0
            self.sketchView.lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            self.scrollView.isScrollEnabled = false
            self.checkUndoRedoStatus()
            self.checkNextPrevButtonStatus()
            
            for _ in 1...self.document.document_pages.count {
                let data = UIImage()
                self.docImage.append(data)
            }
            
            if self.isEdited {
                self.sketchView.isUserInteractionEnabled = true
            } else {
                self.sketchView.isUserInteractionEnabled = false
            }
            self.checkPenColor()
            SVProgressHUD.dismiss()
        })
    }
    
    @objc func back(sender: UIBarButtonItem) {
        checkDocumentEditOrNot { (success) in
            if success {
                //do nothing
            } else {
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func onRegister(sender: UIBarButtonItem) {
        
        if isEdited == false {
            isEdited = true
            self.navigationItem.rightBarButtonItem?.title = "登録"
            onEditMode(hidden: false)
            
            sketchView?.isUserInteractionEnabled = true
        } else {
            //check if user has edited all page or not
            if allowSave {
                SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                saveImageOnPresentScreen()
                
                //add document image into data
                var data : [Data] = []
                for i in 0 ..< self.docImage.count {
                    data.append(self.docImage[i].jpegData(compressionQuality: 0.7)!)
                }
                
                guard let carteID = carteID else { return }
                //check document is template or not
                if document.is_template == 1 {
                    
                    APIRequest.onAddDocumentIntoCarte(documentID: document.id, carteID: carteID, doc: data,type:document.type,subType: document.sub_type) { (success) in
                        
                        SVProgressHUD.showProgress(0.9, status: "サーバーにアップロード中:90%")
                        
                        if success == 1 {
                            if self.isModified == true {
                                self.isModified = false
                            }
                            GlobalVariables.sharedManager.selectedImageIds.removeAll()
                            _ = self.navigationController?.popViewController(animated: true)
                        } else if success == 2 {
                            Utils.showAlert(message: MSG_ALERT.kALERT_DOCUMENT_EXISTS_ALREADY, view: self)
                            GlobalVariables.sharedManager.selectedImageIds.removeAll()
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    
                    APIRequest.onEditDocumentInCarte(documentID: document.id, doc: data) { (success) in
                        SVProgressHUD.showProgress(0.9, status: "サーバーにアップロード中:90%")
                        
                        if success {
                            if self.isModified == true {
                                self.isModified = false
                            }
                            GlobalVariables.sharedManager.selectedImageIds.removeAll()
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CHECK_ALL_DOCUMENT_PAGE, view: self)
                return
            }
        }
    }
    
    fileprivate func onEditMode(hidden:Bool) {
        btnUndo.isHidden = hidden
        btnRedo.isHidden = hidden
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
    
    fileprivate func checkDocumentEditOrNot(completion:@escaping(Bool) -> ()) {
        if isModified == true {
            let alert = UIAlertController(title: "ドキュメント", message: MSG_ALERT.kALERT_SAVE_DOCUMENT_NOTIFICATION, preferredStyle:UIAlertController.Style.alert)
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
    
    fileprivate func checkNextPrevButtonStatus() {
        
        if currPage == 1 && document.document_pages.count == 1 {
            btnNext.isHidden = true
            btnPrev.isHidden = true
            allowSave = true
        } else if currPage == 1 {
            btnNext.isHidden = false
            btnPrev.isHidden = true
        } else if currPage == document.document_pages.count {
            btnNext.isHidden = true
            btnPrev.isHidden = false
            allowSave = true
        } else {
            btnNext.isHidden = false
            btnPrev.isHidden = false
        }
        lblPageNo.text = "ページ : \(currPage)/\(document.document_pages.count)"
    }
    
    fileprivate func saveImageOnPresentScreen() {
        //save image last
        self.docImage[currPage - 1] = sketchView.image!.resizeImage(targetSize: CGSize(width: 1536, height: 2048))
    }
    
    fileprivate func onChangePage() {
        //reset frame
        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        sketchView.clear()
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //check document is template or not
        if document.is_template == 1 {
            
            guard let url = URL(string: self.document.document_pages[currPage - 1].url_original) else { return }
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    var img = UIImage()
                    if self.docImage[self.currPage - 1].size.width != 0 {
                        img = self.docImage[self.currPage - 1]
                    } else {
                        if let data = data {
                            img = UIImage(data: data)!
                        }
                    }
                    
                    switch img.size.width {
                    case 1536:
                        self.sketchView.loadImage(image: img,topTrans: false,x:0,y:0)
                    default:
                        let resizeImage = Utils.imageWithImage(sourceImage: img, scaledToWidth: 1536)
                        self.sketchView.loadImage(image: resizeImage,topTrans: false,x:0,y:0)
                        break
                    }
                    self.scrollView.contentSize = self.sketchView.frame.size
                    
                    self.checkUndoRedoStatus()
                    self.sketchView.drawTool = .pen
                    self.sketchView.lineWidth = 1.0
                    
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            var stringPath = ""
            
            let urlEdit = URL(string: document.document_pages[currPage - 1].url_edit)
            if urlEdit != nil {
                stringPath = document.document_pages[currPage - 1].url_edit
            } else {
                stringPath = document.document_pages[currPage - 1].url_original
            }
            
            guard let url = URL(string: stringPath) else { return }
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    var img = UIImage()
                    if self.docImage[self.currPage - 1].size.width != 0 {
                        img = self.docImage[self.currPage - 1]
                    } else {
                        if let data = data {
                            img = UIImage(data: data)!
                        }
                    }
                    
                    switch img.size.width {
                    case 1536:
                        self.sketchView.loadImage(image: img,topTrans: false,x:0,y:0)
                    default:
                        let resizeImage = Utils.imageWithImage(sourceImage: img, scaledToWidth: 1536)
                        self.sketchView.loadImage(image: resizeImage,topTrans: false,x:0,y:0)
                        break
                    }
                    self.scrollView.contentSize = self.sketchView.frame.size
                    
                    self.checkUndoRedoStatus()
                    self.sketchView.drawTool = .pen
                    self.sketchView.lineWidth = 1.0
                    
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onUndoRedo(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        switch sender.tag {
        case 0:
            sketchView.undo {
                self.checkUndoRedoStatus()
            }
        case 1:
            sketchView.redo {
                self.checkUndoRedoStatus()
            }
        default:
            break
        }
        SVProgressHUD.dismiss()
    }
    
    @IBAction func onPrevious(_ sender: UIButton) {
        
        //save image last
        saveImageOnPresentScreen()
        
        if currPage > 1 {
            currPage -= 1
            checkNextPrevButtonStatus()
            onChangePage()
        }
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
        //save image last
        saveImageOnPresentScreen()
        
        if currPage < document.document_pages.count {
            currPage += 1
            checkNextPrevButtonStatus()
            onChangePage()
        }
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension DocumentVC: UIScrollViewDelegate {
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

extension DocumentVC: SketchViewDelegate {
    
    func drawView(_ view: SketchView, undo: NSMutableArray, didEndDrawUsingTool tool: AnyObject) {
        if isModified == false {
            isModified = true
        }
        checkUndoRedoStatus()
    }
}
