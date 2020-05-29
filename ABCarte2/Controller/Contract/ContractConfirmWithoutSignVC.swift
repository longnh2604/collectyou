//
//  ContractConfirmWithoutSignVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/03.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class ContractConfirmWithoutSignVC: UIViewController {

    @IBOutlet weak var pdfView: UIWebView!
    
    //Variable
    var brochure = BrochureData()
    var url:String?
    var contractID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "サイン画面へ", style: .plain, target: self, action: #selector(onConfirm))
        
        pdfView.loadRequest(URLRequest(url: URL(string: url!)!))
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    
    @objc func onConfirm(sender: UIBarButtonItem) {
    
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "CustomerSignVC") as? CustomerSignVC {
                viewController.brochure = brochure
                viewController.contractID = contractID
                viewController.type = 2
               if let navigator = navigationController {
                   navigator.pushViewController(viewController, animated: true)
               }
           }
       }
       
       @objc func back(sender: UIBarButtonItem) {
           _ = navigationController?.popViewController(animated: true)
       }

}
