//
//  ImagePickerController.swift
//  ABCarte2
//
//  Created by Long on 2019/07/08.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import Photos

class ImagePickerOldController: NSObject {
    
    private lazy var ImagePickerOldController: UIImagePickerController = {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    var completion: ((UIImage?) -> Void)?
    
    func presentImagePiker(with sourceType: UIImagePickerController.SourceType, vc: UIViewController) {
        
        func openSettings(with title: String, message: String) {
            
            let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let open = UIAlertAction(title: "Open Settings".localized, style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
                
            })
            actionSheet.addAction(cancel)
            actionSheet.addAction(open)
            vc.present(actionSheet, animated: true, completion: nil)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            self.ImagePickerOldController.sourceType = sourceType
        }
        
        if self.ImagePickerOldController.sourceType == .photoLibrary {
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    if status == .notDetermined || status == .denied {
                        openSettings(with: "Photos Access Disabled".localized,
                                     message: "You can allow access to Photos in Settings".localized)
                    }
                    else {
                        vc.present(self.ImagePickerOldController, animated: true)
                    }
                }
            })
        }
        else if self.ImagePickerOldController.sourceType == .camera {
            
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                DispatchQueue.main.async {
                    if !granted {
                        openSettings(with: "Camera Access Disabled".localized,
                                     message: "You can allow access to Camera in Settings".localized)
                    }
                    else {
                        vc.present(self.ImagePickerOldController, animated: true)
                    }
                }
            })
        }
    }
    
    func showActionSheet(vc: UIViewController, allowsEditing: Bool = true, completion: @escaping (UIImage?) -> Void) {
        
        self.completion = completion
        self.ImagePickerOldController.allowsEditing = allowsEditing
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera =
            UIAlertAction(title: "Camera".localized, style: .default, handler: { (alert:UIAlertAction!) -> Void in
                self.presentImagePiker(with: .camera, vc: vc)
            })
        let gallery =
            UIAlertAction(title: "Gallery".localized, style: .default, handler: { (alert:UIAlertAction!) -> Void in
                self.presentImagePiker(with: .photoLibrary, vc: vc)
            })
        let cancel =
            UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(gallery)
        actionSheet.addAction(cancel)
        
//        vc.present(actionSheet, animated: true, completion: nil)
        
        actionSheet.popoverPresentationController?.sourceView = vc.view // works for both iPhone & iPad
        
        vc.present(actionSheet, animated: true) {
            print("option menu presented")
        }
    }
}

// MARK: - UIImagePickerController

extension ImagePickerOldController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            completion!(image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion!(nil)
        picker.dismiss(animated: true)
    }
}
