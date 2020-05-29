//
//  CustomerSignVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/30.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol CustomerSignVCDelegate: class {
    func onCompleteSign()
}

class CustomerSignVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var signView: SketchView!
    @IBOutlet weak var btnFloatMenu: JJFloatingActionButton!
    
    //Variable
    weak var delegate:CustomerSignVCDelegate?
    var brochure = BrochureData()
    var contractID: Int?
    var type:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        signView.removeFromSuperview()
    }
    
    private func setupLayout() {
        signView.layer.borderColor = UIColor.gray.cgColor
        signView.layer.borderWidth = 2
        signView.lineWidth = 2.0
        signView.penMode = 2
        signView.loadImage(image: UIImage(named: "img_signPhoto")!, topTrans: false,x:0,y:0)
        signView.clipsToBounds = true
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "再確認画面へ", style: .plain, target: self, action: #selector(onConfirm))
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCustomerSignDrawingAddition.rawValue) {
            btnFloatMenu.isHidden = false
            addFloatingButton()
        }
    }
    
    private func addFloatingButton() {
        //float menu
        btnFloatMenu.configureDefaultItem { item in
            item.titlePosition = .leading
            item.titleSpacing = 16
            
            item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            item.titleLabel.textColor = .white
            item.buttonColor = .white
            
            item.layer.shadowColor = UIColor.black.cgColor
            item.layer.shadowOffset = CGSize(width: 0, height: 1)
            item.layer.shadowOpacity = Float(0.4)
            item.layer.shadowRadius = CGFloat(2)
        }
        
        btnFloatMenu.addItem(title: "消ゴム", image: UIImage(named: "icon_eraser")) { item in
            self.signView.drawTool = .eraser
            self.signView.lineWidth = 15
        }
        
        btnFloatMenu.addItem(title: "書く", image: UIImage(named: "icon_pencil")) { item in
            self.signView.drawTool = .pen
            self.signView.lineWidth = 2.0
        }
    }
    
    @objc func onConfirm(sender: UIBarButtonItem) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let imgData = signView.image?.resizeImage(targetSize: CGSize(width: 768, height: 58)).jpegData(compressionQuality: 1.0)
        
        if type == 1 {
            APIRequest.onAddBrochureSignature(brochureID: brochure.id, signatureData: imgData!) { (success) in
                if success {
                    APIRequest.onGetBrochureWithSign(brochureID: self.brochure.id) { (success, url) in
                        if success {
                            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "BrochureConfirmFinalVC") as? BrochureConfirmFinalVC {
                                viewController.url = url
                                viewController.brochure = self.brochure
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        } else {
                            Utils.showAlert(message: "Can not get brochure sign data", view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Utils.showAlert(message: "Can not upload signature", view: self)
                    SVProgressHUD.dismiss()
                }
            }
        } else if type == 2 {
            APIRequest.onAddContractSignature(brochureID: brochure.id, signatureData: imgData!) { (success) in
                if success {
                    APIRequest.onGetContractWithSign(brochureID: self.brochure.id) { (success, url) in
                        if success {
                            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContractConfirmFinalVC") as? ContractConfirmFinalVC {
                                viewController.url = url
                                viewController.brochure = self.brochure
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        } else {
                            Utils.showAlert(message: "Can not get brochure sign data", view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Utils.showAlert(message: "Can not upload signature", view: self)
                    SVProgressHUD.dismiss()
                }
            }
        }
        
    }
        
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}
