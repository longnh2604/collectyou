//
//  DeviceInfoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/19.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol DeviceInfoPopupVCDelegate: class {
    func onEraseDevice()
}

class DeviceInfoPopupVC: UIViewController {
    
    //Variable
    weak var delegate:DeviceInfoPopupVCDelegate?
    let network: NetworkManager = NetworkManager.sharedInstance
    
    //IBOutlet
    @IBOutlet weak var tfiPadModel: UITextField!
    @IBOutlet weak var tfiOSVer: UITextField!
    @IBOutlet weak var tfDeviceID: UITextField!
    @IBOutlet weak var imvInternetStatus: UIImageView!
    @IBOutlet weak var switchDeviceTransfer: UISwitch!
    @IBOutlet weak var lblWifiName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lbliOS: UILabel!
    @IBOutlet weak var lblDeviceID: UILabel!
    @IBOutlet weak var lblConnection: UILabel!
    @IBOutlet weak var lblErase: UILabel!
    @IBOutlet weak var btnClose: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    fileprivate func setupLayout() {
        let systemVersion = UIDevice.current.systemVersion
        let deviceType = UIDevice().type
        
        tfiPadModel.text = deviceType.rawValue
        
        tfiOSVer.text = systemVersion
      
        if let id = Utils.getUUID() {
            tfDeviceID.text = id
        }
        
        do {
            try network.reachability.startNotifier()
        } catch {
            print("error connection")
        }
        network.delegate = self
        checkNetworking()
        
        lblWifiName.text = Utils.getWiFiSsid()
        
        switchDeviceTransfer.isOn = false
        
        localizeLanguage()
    }
    
    fileprivate func localizeLanguage() {
        lblTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Device Info", comment: "")
        lblModel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Model", comment: "")
        lbliOS.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "iOS Version", comment: "")
        lblDeviceID.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Device ID", comment: "")
        lblConnection.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Internet Status", comment: "")
        lblErase.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Erase Device", comment: "")
        btnClose.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel",comment: ""), for: .normal)
    }
    
    fileprivate func checkNetworking() {
        NetworkManager.isUnreachable { _ in
            self.imvInternetStatus.image = UIImage(named: "icon_wifi_off_color")
        }
        NetworkManager.isReachable { _ in
            self.imvInternetStatus.image = UIImage(named: "icon_wifi_on_color")
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: Any) {
        network.reachability.stopNotifier()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDeviceTransferSelect(_ sender: UISwitch) {
        
        if sender.isOn {
            let alert = UIAlertController(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Do you want to erase the data from this Device", comment: ""), message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "To erase the data, tap [OK] and enter the password. Please log into App with your new iPad after you completely logout.", comment: ""), preferredStyle: .alert)
            let cancel = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""), style: .default) { UIAlertAction in
                sender.isOn = false
            }
            let ok = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                //request api
                self.dismiss(animated: false, completion: {
                    self.delegate?.onEraseDevice()
                })
            }

            alert.addAction(ok)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//*****************************************************************
// MARK: - NetworkManagerDelegate
//*****************************************************************

extension DeviceInfoPopupVC: NetworkManagerDelegate {
    func onNetworkStatusChange() {
        checkNetworking()
    }
}
