//
//  BrochureConfirmFinalVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/31.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class BrochureConfirmFinalVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var webView: UIWebView!
    
    //Variable
    var brochure = BrochureData()
    var url:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        self.navigationItem.hidesBackButton = true
        
        let finishWPrint = UIBarButtonItem(title: "終了", style: .plain, target: self, action: #selector(onClose))
        let print = UIBarButtonItem(title: "印刷", style: .plain, target: self, action: #selector(onPrint))
        navigationItem.rightBarButtonItems = [finishWPrint, print]
        
        if let stringURL = url {
            let request = URLRequest(url:  URL(string: stringURL)!)
            let config = URLSessionConfiguration.default
            let session =  URLSession(configuration: config)
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if error == nil{
                    if let pdfData = data {
                        let pathURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("contract.pdf")
                        do {
                            try pdfData.write(to: pathURL, options: .atomic)
                        } catch {
                            //do nothing
                        }

                        DispatchQueue.main.async {
//                            self.webView.delegate = self
                            self.webView.scalesPageToFit = true
                            self.webView.loadRequest(URLRequest(url: pathURL))
                        }
                    }
                } else {
                    //do nothing
                }
            }); task.resume()
        }
    }
    
    @objc func onClose() {
        let controllers = self.navigationController?.viewControllers
            for vc in controllers! {
            if vc is CarteListVC {
                _ = self.navigationController?.popToViewController(vc as! CarteListVC, animated: true)
            }
        }
    }
    
    @objc func onPrint() {
        if let url = url {
            if brochure.broch_print_date != 0 {
                Utils.printUrl(url: URL(string: url)!)
            } else {
                Utils.printUrlNew(url: URL(string: url)!) { (success) in
                    if success {
                        SVProgressHUD.show()
                        let currDate = Date()
                        APIRequest.onUpdateBrochurePrintDate(brochureID: self.brochure.id, type: 1, date: Int(currDate.timeIntervalSince1970)) { (success) in
                            if success {
                                Utils.showAlert(message: "印刷が終わりました。", view: self)
                            } else {
                                Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        Utils.showAlert(message: "印刷エラーが発生しました。", view: self)
                    }
                }
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

}
