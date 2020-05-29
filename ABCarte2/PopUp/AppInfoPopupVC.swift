//
//  AppInfoPopupVC.swift
//  ABCarte2
//
//  Created by long nguyen on 4/21/20.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

class AppInfoPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblCurrentVer: UILabel!
    @IBOutlet weak var tvStatus: UITextView!
    @IBOutlet weak var btnUpdate: RoundButton!
    
    //Variable
    var currentVer = ""
    var urlLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    private func setupLayout() {
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let str = "\(appName) \(version)"
        lblCurrentVer.text = str
        
        tvStatus.dataDetectorTypes = .link
        tvStatus.isEditable = false
        tvStatus.isSelectable = true
        tvStatus.isUserInteractionEnabled = true
        if currentVer != "" {
            tvStatus.text = "アプリが最新ではありません。アプリ ver\(currentVer) を更新するには、以下のボタンをタップしてください"
        } else {
            tvStatus.text = "アプリは最新です。"
            btnUpdate.isHidden = true
        }
    }

    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onUpdate(_ sender: UIButton) {
        if let url = URL(string: urlLink), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
