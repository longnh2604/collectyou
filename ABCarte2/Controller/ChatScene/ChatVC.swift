//
//  ChatVC.swift
//  ABCarte2
//
//  Created by Long on 2019/07/05.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import SlackTextViewController
import ConnectyCube
import Pickle
import Photos

@objc protocol ChatVCDelegate: class {
    @objc optional func onAddNewCarte(time: Int, staff_name: String, bed_name: String, mediaData: Data)
    @objc optional func onUpdateCarte(mediaData: Data)
}

class ChatVC: SLKTextViewController,UINavigationControllerDelegate {
    
    //Variable
    var sortedData: SortedDataProvider<ChatMessage>!
    var messageToEdit: ChatMessage?
    let imagePickerViewController = ImagePickerOldController()
    var hostID:UInt?
    var customer = CustomerData()
    var chatMsg : [ChatMessage] = []
    var imgAvatar: String?
    var imageData: Data?
    weak var delegate:ChatVCDelegate?
    
    var dialog: ChatDialog! {
        didSet {
            //Sorted view
            sortedData = SortedDataProvider(collection: dialog.id!, name: dialog.id!, sorting: { (m1, m2) -> ComparisonResult in
                var comparison = m2.dateSent!.compare(m1.dateSent!)
                if comparison == .orderedSame {
                    comparison = m2.id!.compare(m2.id!)
                }
                return comparison
            })
            sortedData.addPresenter(tableView!)
            Cache.messages.register(sortedDataProvider: sortedData!)
            ChatApp.messages.updates(with: dialog.id!)
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureInputBar()
        self.view.clipsToBounds = true
    }
    
    //MARK: - Configure table view
    
    func configureTableView() {
        // Hide extra empty cells
        tableView!.tableFooterView = UIView()
        // Remove separator
        tableView!.separatorStyle = .none
        tableView!.rowHeight = UITableView.automaticDimension
        tableView!.estimatedRowHeight = 200
        self.scrollView?.contentInsetAdjustmentBehavior = .automatic
        
        registerCells()
    }
    
    func configureInputBar() {
        //Configure left/right buttons
        rightButton.setImage(#imageLiteral(resourceName: "send_ic"), for: .normal)
        rightButton.setTitle(nil, for: .normal)
        leftButton.setImage(#imageLiteral(resourceName: "icon_open"), for: .normal)
        leftButton.tintColor = UIColor.black
        leftButton.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
        leftButton.layer.cornerRadius = 20
        //Configure char counter
        textInputbar.counterPosition = .bottom
        textInputbar.counterStyle = .split
        textInputbar.maxCharCount = 200
        textInputbar.textView.keyboardType = .default
        //Common
        textInputbar.autoHideRightButton = false
        textInputbar.textView.placeholder = "メッセージを入力してください".localized
        textInputbar.textView.font = UIFont.systemFont(ofSize: 18)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sorted = sortedData {
            return sorted.numberOfObjects()
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message: ChatMessage = sortedData.object(indexPath)!
        guard let id = hostID else { return UITableViewCell() }
        let cell = configureCell(withMessage: message, indexPath: indexPath,id: id,avatar: imgAvatar!) as! BaseCell
        cell.pressDelegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = sortedData.numberOfObjects()
        if count >= 100, count - 1 == indexPath.row {
            let message: ChatMessage! = sortedData.object(indexPath)
            ChatApp.messages.loadMore(before: message, dialogID: self.dialog.id!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message: ChatMessage! = sortedData.object(indexPath)
        if message.type() == .jpg || message.type() == .jpeg || message.type() == .png {
            let newPopup = PhotoViewPopup(nibName: "PhotoViewPopup", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 700, height: 900)
            newPopup.imgURL = message.attachments!.first!.url!
            newPopup.type = 2
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        }
    }
    
    //MARK: Press left button
    
    override func didPressLeftButton(_ sender: Any?) {
        let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Please select the content", comment: ""), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .cancel, handler: nil)
        let appPhoto = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Send Karte's Photos", comment: ""), style: .default) { UIAlertAction in
            let newPopup = CustomerGalleryPopupVC(nibName: "CustomerGalleryPopupVC", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 600, height: 800)
            newPopup.customer = self.customer
            newPopup.delegate = self
            newPopup.type = 3
            self.present(newPopup, animated: true, completion: nil)
        }
        let cameraRoll = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "カメラの写真送信", comment: ""), style: .default) { UIAlertAction in
            super.didPressLeftButton(sender)
            
            var parameters = Pickle.Parameters()
            let limitPics = 1
            
            parameters.allowedSelections = .limit(to: limitPics)
            let picker = ImagePickerController(configuration: parameters)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)

        }
        let sentPhoto = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "送受信写真一覧へ移動", comment: ""), style: .default) { UIAlertAction in
            self.onPhotoSharedSelect()
        }
        
        alert.addAction(cancel)
        alert.addAction(appPhoto)
        alert.addAction(cameraRoll)
        alert.addAction(sentPhoto)
        alert.popoverPresentationController?.sourceView = self.leftButton
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.leftButton.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onPhotoSharedSelect() {
        chatMsg.removeAll()
        
        for i in 0 ..< sortedData.numberOfObjects() {
            let message: ChatMessage! = sortedData.object(IndexPath(row: i, section: 0))
            if message.type() == .jpg || message.type() == .png || message.type() == .jpeg {
                chatMsg.append(message)
            }
        }
        
        let newPopup = SentPhotoListPopupVC(nibName: "SentPhotoListPopupVC", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 600, height: 800)
        newPopup.chatMsg = chatMsg
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    //MARK: Press rigth button
    override func didPressRightButton(_ sender: Any?) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        ChatApp.messages.sendMessage(with: text, to: self.dialog) {}
        if tableView!.numberOfRows(inSection: 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView!.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        super.didPressRightButton(sender)
    }
}

//MARK: - Remove/Edit message

extension ChatVC : PressDelegate {
    func didLinkPress(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    func didPhonePress(no: String) {
        if let url = URL(string: "tel://\(no)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func didLongPress(_ cell: BaseCell) {
        guard let indexPath = self.tableView!.indexPath(for: cell) else { return }
        
        let message = sortedData.object(indexPath)!
//        guard message.senderID == Profile.currentProfile!.id else { return }
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        //Edit message
        let edit = UIAlertAction(title: "編集".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.messageToEdit = message
            self.editText(self.messageToEdit!.text!)
        })
        //Delete message
        let delete = UIAlertAction(title: "削除".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            ChatApp.messages.deleteMessage(from: self.dialog, message: message)
        })
        //Copy message
        let copy = UIAlertAction(title: "コピー".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            UIPasteboard.general.string = message.text
        })
        //Cancel
        let cancel = UIAlertAction(title: "取消".localized, style: .cancel)
        
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMessageEdit.rawValue) && message.senderID == Profile.currentProfile?.id {
            menu.addAction(edit)
            menu.addAction(delete)
        }
        
        menu.addAction(copy)
        menu.addAction(cancel)
        
        self.present(menu, animated: true, completion: nil)
    }
    
    override func didCommitTextEditing(_ sender: Any) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        ChatApp.messages.editMessage(in: dialog, message:messageToEdit!, newText: text)
        messageToEdit = nil
        super.didCommitTextEditing(sender)
    }
    
    override func didCancelTextEditing(_ sender: Any) {
        messageToEdit = nil
        super.didCancelTextEditing(sender)
    }
}

//*****************************************************************
// MARK: - ImagePicker Delegate
//*****************************************************************

extension ChatVC: ImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: ImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: ImagePickerController, shouldLaunchCameraWithAuthorization status: AVAuthorizationStatus) -> Bool {
        return true
    }
    
    func imagePickerController(_ picker: ImagePickerController, didFinishPickingImageAssets assets: [PHAsset]) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let img = getAssetsData(assets: assets)
        
        SVProgressHUD.showProgress(0)
        let text = "\(Profile.currentProfile?.fullName ?? "") からの画像".localized
        ChatApp.messages.sendMessage(with: img, text: text, to: self.dialog, progress: { progress in
            SVProgressHUD.showProgress(progress)
        }){
            SVProgressHUD.dismiss()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func getAssetsData(assets: [PHAsset]) -> UIImage {

        var arrayOfImages = [UIImage]()
        for asset in assets {
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            // this one is key
            requestOptions.isSynchronous = true
            requestOptions.isNetworkAccessAllowed = true

            manager.requestImage(for: asset, targetSize: CGSize(width: 1152, height: 1536), contentMode: .aspectFit, options: requestOptions, resultHandler: {(result, info)->Void in

                let imageView = UIImageView.init(image: UIImage.init(color: UIColor.clear, size: CGSize(width: 1152, height: 1536)))
                imageView.contentMode = .scaleAspectFit
                imageView.image = result!
                arrayOfImages.append(imageView.image!)
            })
        }

        return arrayOfImages[0]
    }
}

//*****************************************************************
// MARK: - CustomerGalleryPopupVC Delegate
//*****************************************************************

extension ChatVC: CustomerGalleryPopupVCDelegate {
    
    func onSelectImage(image: UIImage) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        SVProgressHUD.showProgress(0)
        let text = "\(Profile.currentProfile?.fullName ?? "") からの画像".localized
        ChatApp.messages.sendMessage(with: image, text: text, to: self.dialog, progress: { progress in
            SVProgressHUD.showProgress(progress)
        }){
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - SentPhotoListPopupVC Delegate
//*****************************************************************

extension ChatVC: SentPhotoListPopupVCDelegate {
    
    func onChooseImage(image: UIImage) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        SVProgressHUD.showProgress(0)
        let text = "\(Profile.currentProfile?.fullName ?? "") からの画像".localized
        ChatApp.messages.sendMessage(with: image, text: text, to: self.dialog, progress: { progress in
            SVProgressHUD.showProgress(progress)
        }){
            SVProgressHUD.dismiss()
        }
    }
    
    func onAddNewCartePhoto(url: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"AddCartePopupVC") as? AddCartePopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            let urlP = URL(string:url)
            if let data = try? Data(contentsOf: urlP!)
            {
                imageData = data
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func onUpdateExistingCartePhoto(url: String) {
        let urlP = URL(string:url)
        if let data = try? Data(contentsOf: urlP!)
        {
            delegate?.onUpdateCarte?(mediaData:data)
        }
    }
}

//*****************************************************************
// MARK: - PhotoViewPopupDelegate
//*****************************************************************

extension ChatVC: PhotoViewPopupDelegate {
    func onAddNewCarteWithPhoto(image: UIImage?) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"AddCartePopupVC") as? AddCartePopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            imageData = image!.jpegData(compressionQuality: 1)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func onUpdateExistingCarteWithPhoto(image: UIImage?) {
        delegate?.onUpdateCarte?(mediaData: image!.jpegData(compressionQuality: 1)!)
    }
}

//*****************************************************************
// MARK: - AddCartePopupVC Delegate
//*****************************************************************

extension ChatVC: AddCartePopupVCDelegate {
    func onAddNewCarte(time: Int, staff_name: String, bed_name: String) {
        if let imageData = imageData {
            delegate?.onAddNewCarte?(time: time, staff_name: staff_name, bed_name: bed_name,mediaData: imageData)
        }
    }
}
