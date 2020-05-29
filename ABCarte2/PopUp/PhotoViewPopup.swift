//
//  PhotoViewPopup.swift
//  ABCarte2
//
//  Created by Long on 2018/10/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import LGButton

@objc protocol PhotoViewPopupDelegate: class {
    @objc optional func onSetCartePhoto(mediaID:String,url:String)
    @objc optional func onAddNewCarteWithPhoto(image:UIImage?)
    @objc optional func onUpdateExistingCarteWithPhoto(image:UIImage?)
}

class PhotoViewPopup: UIViewController {

    //Variable
    weak var delegate:PhotoViewPopupDelegate?
    var imgURL: String?
    var mediaID: String?
    var type: Int?
    
    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var btnSetCartePhoto: LGButton!
    @IBOutlet weak var btnExport: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    deinit {
        print("Release Memory")
    }
    
    func setupUI() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        btnSetCartePhoto.isHidden = true
        btnExport.isHidden = true
        
        SVProgressHUD.show(withStatus: "読み込み中")
        if let url = imgURL {
            imvPhoto.sd_setImage(with: URL(string: url)) { (image, error, cache, url) in
                if (error != nil) {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
                self.updateType()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    fileprivate func updateType() {
        switch type {
        case 1:
            btnSetCartePhoto.isHidden = false
        case 2:
            btnExport.isHidden = false
        default:
            btnSetCartePhoto.isHidden = true
            btnExport.isHidden = true
            break
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSetCartePhoto(_ sender: UIButton) {
        guard let id = mediaID,let url = imgURL else { return }
        self.delegate?.onSetCartePhoto?(mediaID: id,url:url)
    }
    
    @IBAction func onExportPhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)

        let addNew = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "新しいカルテを作成", comment: ""), style: .default) { UIAlertAction in
            self.dismiss(animated: true) {
                self.delegate?.onAddNewCarteWithPhoto?(image: self.imvPhoto.image)
            }
        }
        
        let update = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "存在カルテに保存", comment: ""), style: .default) { UIAlertAction in
            self.dismiss(animated: true) {
                self.delegate?.onUpdateExistingCarteWithPhoto?(image: self.imvPhoto.image)
            }
        }
        
        let addGallery = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "本体に保存", comment: ""), style: .default) { UIAlertAction in
            guard let url = self.imgURL else { return }
            SVProgressHUD.show(withStatus: "読み込み中")
            Utils.saveImageToCameraRoll(url: URL(string: url)!) { (success) in
                if success {
                    Utils.showAlert(message: "画像の保存しました。", view: self)
                    SVProgressHUD.dismiss()
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_PHOTO, view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }
        
        alert.addAction(addNew)
        alert.addAction(update)
        alert.addAction(addGallery)
        
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = sender.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension PhotoViewPopup: UIScrollViewDelegate {
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
