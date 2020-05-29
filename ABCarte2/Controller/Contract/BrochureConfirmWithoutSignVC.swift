//
//  BrochureConfirmWithoutSignVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/31.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class BrochureConfirmWithoutSignVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var pdfView: UIWebView!
    
    //Variable
    var brochure = BrochureData()
    var company = CompanyData()
    var subcompany = CompanyData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    fileprivate func setupLayout() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "サイン画面へ", style: .plain, target: self, action: #selector(onConfirm))
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //update brochure data first
        APIRequest.onUpdateBrochureData(brochure: brochure) { (success) in
            if success {
                APIRequest.onAddContractCompany(brochureID: self.brochure.id, comData: self.company) { (success) in
                    if success {
                        APIRequest.onAddSubCompany(brochureID: self.brochure.id, comData: self.subcompany) { (success) in
                            if success {
                                APIRequest.onGetBrochureWithoutSign(brochureID: self.brochure.id, completion: { (success, url) in
                                    if success {
                                        self.pdfView.loadRequest(URLRequest(url: URL(string: url)!))
                                    } else {
                                        Utils.showAlert(message: "Can not get Brochure Data", view: self)
                                    }
                                    SVProgressHUD.dismiss()
                                })
                            } else {
                                Utils.showAlert(message: "Failed to Update Sub Contract COmpany", view: self)
                                SVProgressHUD.dismiss()
                            }
                        }
                        
                    } else {
                        Utils.showAlert(message: "Failed to Update Contract COmpany", view: self)
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                Utils.showAlert(message: "Failed to Update Brochure", view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func onConfirm(sender: UIBarButtonItem) {
 
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CustomerSignVC") as? CustomerSignVC {
            viewController.brochure = brochure
            viewController.type = 1
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

}
