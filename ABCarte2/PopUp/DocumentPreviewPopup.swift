//
//  DocumentPreviewPopup.swift
//  ABCarte2
//
//  Created by Long on 2018/11/27.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol DocumentPreviewPopupDelegate: class {
    func onEditDocument(document: DocumentData,carteID:Int)
    func onMoveUpDocument(type:Int,subType:Int,cellIndex:Int)
    func onMoveDownDocument(type:Int,subType:Int,cellIndex:Int)
}

class DocumentPreviewPopup: UIViewController {

    //Variable
    weak var delegate:DocumentPreviewPopupDelegate?
    var accountData = AccountData()
    var documentsData = DocumentData()
    var carteData = CarteData()
    var isTemp : Bool?
    var pageNo: Int?
    var totalDoc: Int = 0
    var onShowMoveUp: Bool = true
    var onShowMoveDown: Bool = true
    var cellIndex: Int?
    
    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblPageNo: UILabel!
    @IBOutlet weak var btnClose: RoundButton!
    @IBOutlet weak var btnEdit: RoundButton!
    @IBOutlet weak var lblDateTime: RoundLabel!
    @IBOutlet weak var viewUpDown: UIStackView!
    @IBOutlet weak var btnMoveUp: UIButton!
    @IBOutlet weak var btnMoveDown: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        getDocumentData()
    }
    
    fileprivate func setupLayout() {
        if onShowMoveUp == false {
            btnMoveUp.isEnabled = false
            btnMoveUp.alpha = 0.3
        }
        if onShowMoveDown == false {
            btnMoveDown.isEnabled = false
            btnMoveDown.alpha = 0.3
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kUpDownDocCarte.rawValue) {
            viewUpDown.isHidden = false
        } else {
            viewUpDown.isHidden = true
        }
    }
    
    fileprivate func getDocumentData() {
        APIRequest.onGetDocuments(accID: accountData.id, type: documentsData.type, subtype: documentsData.sub_type) { (success) in
            if success {
                self.loadData()
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
    
    func loadData() {
        pageNo = 1
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        guard let temp = isTemp else { return }
        
        if temp == true {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[0].url_original)) { (image, error, cache, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
            }
        } else {
            //new ver
            if documentsData.document_pages[0].url_edit == "" {
                imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[0].url_original)) { (image, error, cache, url) in
                    if (error != nil) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                        self.imvPhoto.image = Utils.onGenerateDocumentNumber(number: self.documentsData.document_no, image: image!)
                    } else {
                        self.imvPhoto.image = image
                    }
                }
            } else {
                imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[0].url_edit)) { (image, error, cache, url) in
                    if (error != nil) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                        self.imvPhoto.image = Utils.onGenerateDocumentNumber(number: self.documentsData.document_no, image: image!)
                    } else {
                        self.imvPhoto.image = image
                    }
                }
            }
        }
        setupPage()
    }
    
    func setupPage() {
        lblPageNo.text = "ページ：\(pageNo ?? 1)/\(documentsData.document_pages.count)"
        
        if documentsData.document_pages.count > 1 {
            if pageNo == 1 {
                btnPrev.isEnabled = false
                btnNext.isEnabled = true
            } else if pageNo! < documentsData.document_pages.count {
                btnNext.isEnabled = true
                btnPrev.isEnabled = true
            } else {
                btnPrev.isEnabled = true
                btnNext.isEnabled = false
            }
            
        } else {
            btnPrev.isEnabled = false
            btnNext.isEnabled = false
        }
        
        lblDateTime.text = Utils.convertUnixTimestamp(time: carteData.select_date)
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onPrint(_ sender: UIButton) {
        guard let temp = isTemp else { return }
        var imgData = [UIImage]()
        
        if temp == true {
            for i in 0 ..< documentsData.document_pages.count {
                //on generate number
                guard let data = try? Data(contentsOf: URL.init(string: documentsData.document_pages[i].url_original)!) else { return }
                if let image = UIImage(data: data) {
                    imgData.append(image)
                }
            }
        } else {
            for i in 0 ..< documentsData.document_pages.count {
                if documentsData.document_pages[i].url_edit == "" {
                    if i == 0 {
                        guard let data = try? Data(contentsOf: URL.init(string: documentsData.document_pages[i].url_original)!) else { return }
                        if let image = UIImage(data: data) {
                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                                imgData.append(Utils.onGenerateDocumentNumber(number: documentsData.document_no, image: image)!)
                            } else {
                                imgData.append(image)
                            }
                        }
                    } else {
                        guard let data = try? Data(contentsOf: URL.init(string: documentsData.document_pages[i].url_original)!) else { return }
                        if let image = UIImage(data: data) {
                            imgData.append(image)
                        }
                    }
                } else {
                    if i == 0 {
                        guard let data = try? Data(contentsOf: URL.init(string: documentsData.document_pages[i].url_original)!) else { return }
                        if let image = UIImage(data: data) {
                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                                imgData.append(Utils.onGenerateDocumentNumber(number: documentsData.document_no, image: image)!)
                            } else {
                                imgData.append(image)
                            }
                        }
                    } else {
                        guard let data = try? Data(contentsOf: URL.init(string: documentsData.document_pages[i].url_edit)!) else { return }
                        if let image = UIImage(data: data) {
                            imgData.append(image)
                        }
                    }
                }
            }
        }
        Utils.printUrl(url: Utils.generatePDF(images: imgData))
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.onEditDocument(document: self.documentsData, carteID: self.carteData.id)
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPrevious(_ sender: UIButton) {
        
        pageNo = pageNo! - 1
        
        if isTemp == true {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_original)) { (image, error, cache, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
            }
        } else {
            if documentsData.document_pages[0].url_edit == "" {
                imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_original)) { (image, error, cache, url) in
                    if (error != nil) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    if self.pageNo == 1 {
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                            self.imvPhoto.image = Utils.onGenerateDocumentNumber(number: self.documentsData.document_no, image: image!)
                        } else {
                            self.imvPhoto.image = image
                        }
                    }
                }
            } else {
                imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_edit)) { (image, error, cache, url) in
                    if (error != nil) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    if self.pageNo == 1 {
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDocumentNo.rawValue) {
                            self.imvPhoto.image = Utils.onGenerateDocumentNumber(number: self.documentsData.document_no, image: image!)
                        } else {
                            self.imvPhoto.image = image
                        }
                    }
                }
            }
        }
        
        setupPage()
    }
    
    @IBAction func onNext(_ sender: UIButton) {

        pageNo = pageNo! + 1
        
        if isTemp == true {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_original)) { (image, error, cache, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
            }
        } else {
            if documentsData.document_pages[0].url_edit == "" {
                imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_original)) { (image, error, cache, url) in
                    if (error != nil) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            } else {
                imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_edit)) { (image, error, cache, url) in
                    if (error != nil) {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            }
        }
        setupPage()
    }
    
    @IBAction func onMoveUpDoc(_ sender: UIButton) {
        dismiss(animated: true) {
            if let index = self.cellIndex {
                self.delegate?.onMoveUpDocument(type:self.documentsData.type,subType:self.documentsData.sub_type,cellIndex:index-1)
            }
        }
    }
    
    @IBAction func onMoveDownDoc(_ sender: UIButton) {
        dismiss(animated: true) {
            if let index = self.cellIndex {
                self.delegate?.onMoveDownDocument(type:self.documentsData.type,subType:self.documentsData.sub_type,cellIndex:index+1)
            }
        }
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension DocumentPreviewPopup: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let imageViewSize = imvPhoto.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imvPhoto
    }
}
