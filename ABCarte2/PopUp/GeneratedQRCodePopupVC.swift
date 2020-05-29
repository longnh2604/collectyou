//
//  GeneratedQRCodePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/07/16.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class GeneratedQRCodePopupVC: UIViewController {

    //Variable
    var imgQR: UIImage?
    var userID: String?
    var userPassword: String?
    var shopID: String?
    var accountData: AccountData?
    
    //IBOutlet
    @IBOutlet weak var imvQRCode: UIImageView!
    @IBOutlet weak var tfUserID: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfShop: UITextField!
    @IBOutlet weak var imvQRIOS: UIImageView!
    @IBOutlet weak var imvQRANDROID: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    fileprivate func setupLayout() {
        imvQRCode.layer.borderWidth = 3
        imvQRCode.layer.borderColor = UIColor.black.cgColor
        imvQRCode.layer.cornerRadius = 5
        
        imvQRIOS.layer.borderWidth = 1
        imvQRIOS.layer.borderColor = UIColor.black.cgColor
        imvQRIOS.layer.cornerRadius = 3
        
        imvQRANDROID.layer.borderWidth = 1
        imvQRANDROID.layer.borderColor = UIColor.black.cgColor
        imvQRANDROID.layer.cornerRadius = 3
        
        imvQRCode.image = imgQR
        tfUserID.text = userID
        tfPassword.text = userPassword
        tfShop.text = shopID
        
        if (accountData != nil) {
            let iosURL = "\(accountData?.qr_code ?? "")/ios/release"
            let androidURL = "\(accountData?.qr_code ?? "")/android/release"
            
            imvQRIOS.image = Utils.onGenerateQRCode(from: iosURL)
            imvQRANDROID.image = Utils.onGenerateQRCode(from: androidURL)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
