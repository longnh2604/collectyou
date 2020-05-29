//
//  SentPhotoListPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/08/20.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import ConnectyCube

@objc protocol SentPhotoListPopupVCDelegate: class {
    @objc optional func onSelectImage(image:UIImage)
    @objc optional func onAddNewCartePhoto(url:String)
    @objc optional func onUpdateExistingCartePhoto(url:String)
}

class SentPhotoListPopupVC: UIViewController {

    //Variable
    weak var delegate:SentPhotoListPopupVCDelegate?
    var chatMsg: [ChatMessage] = []
    var sentPhotoData : [SentPhoto] = []
    var imgURL: String?
    
    //IBOutlet
    @IBOutlet weak var collectionGallery: UICollectionView!
    @IBOutlet weak var btnSend: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sentPhotoData.removeAll()
        chatMsg.removeAll()
    }

    fileprivate func setupLayout() {
        guard let fl = collectionGallery?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        fl.sectionHeadersPinToVisibleBounds = true
        
        collectionGallery.register(UINib(nibName: "SectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        let nib = UINib(nibName: "photoCollectCell", bundle: nil)
        collectionGallery.register(nib, forCellWithReuseIdentifier: "photoCollectCell")
        
        collectionGallery.delegate = self
        collectionGallery.dataSource = self
        collectionGallery.reloadData()
    }
    
    fileprivate func loadData() {
        var currDate = Date()
        var no = 0
        for i in 0 ..< chatMsg.count {
            if i == 0 {
                let photo = SentPhoto()
                photo.date = (chatMsg[i].dateSent)!
                currDate = (chatMsg[i].dateSent)!
                photo.medias.append((chatMsg[i].attachments?.first!.url)!)
                sentPhotoData.append(photo)
            } else {
                if (chatMsg[i].dateSent?.isInSameDay(date: currDate))! {
                    sentPhotoData[no].medias.append((chatMsg[i].attachments?.first!.url)!)
                } else {
                    no += 1
                    let photo = SentPhoto()
                    photo.date = (chatMsg[i].dateSent)!
                    currDate = (chatMsg[i].dateSent)!
                    photo.medias.append((chatMsg[i].attachments?.first!.url)!)
                    sentPhotoData.append(photo)
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSendPhoto(_ sender: UIButton) {
        guard let url = imgURL else { return }
        
        let uiimage = UIImageView()
        uiimage.sd_setImage(with: URL(string: url)) { (image, error, cache, url) in
            self.delegate?.onSelectImage?(image: image!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)

        let addNew = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "新しいカルテを作成", comment: ""), style: .default) { UIAlertAction in
            self.dismiss(animated: true) {
                if let imgURL = self.imgURL {
                    self.delegate?.onAddNewCartePhoto?(url: imgURL)
                }
            }
        }
        
        let update = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "存在カルテに保存", comment: ""), style: .default) { UIAlertAction in
            self.dismiss(animated: true) {
                if let imgURL = self.imgURL {
                    self.delegate?.onUpdateExistingCartePhoto?(url: imgURL)
                }
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
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension SentPhotoListPopupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "photoCollectCell", for: indexPath) as! photoCollectCell
        cell.configureSentPhoto(photoURL: sentPhotoData[indexPath.section].medias[indexPath.row],time:sentPhotoData[indexPath.section].date)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sentPhotoData[section].medias.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sentPhotoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imgURL = sentPhotoData[indexPath.section].medias[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
                fatalError("Could not find proper header")
            }
            
            let format = DateFormatter()
            format.dateFormat = "yyyy年MM月dd日"
            let formattedDate = format.string(from: sentPhotoData[indexPath.section].date)
            header.sectionLabel.text = "\(formattedDate)"
            return header
        }
        return UICollectionReusableView()
    }
}

extension SentPhotoListPopupVC: UICollectionViewDelegateFlowLayout {
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 20)
    }
}
