//
//  AppSelectVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/21.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import UXMPDFKit

class AppSelectVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnKarte: UIButton!
    @IBOutlet weak var btnSimulator: UIButton!
    @IBOutlet weak var btnOperation: UIButton!
    @IBOutlet weak var btnPractice: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    fileprivate func setupLayout() {
        btnKarte.layer.cornerRadius = 10
        btnKarte.clipsToBounds = true
        btnOperation.layer.cornerRadius = 10
        btnOperation.clipsToBounds = true
        btnPractice.layer.cornerRadius = 10
        btnPractice.clipsToBounds = true
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        //check pdf exist or not
        Utils.savePdf(urlString: Constants.JBS.DOC_URL, fileName: Constants.JBS.DOC_NAME) { (success) in
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func loadDocument(urlPath:String) {
        let document = try! PDFDocument.from(filePath: urlPath)
        let pdf = PDFViewController(document: document!)
        pdf.annotationController.annotationTypes = [
            PDFHighlighterAnnotation.self,
            PDFPenAnnotation.self,
            PDFTextAnnotation.self
        ]
        pdf.allowsSharing = false
        pdf.allowsAnnotations = false
        self.navigationController?.pushViewController(pdf, animated: true)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onButtonSelect(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if let story: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? {
                if let mainPageView =  story.instantiateViewController(withIdentifier: Constants.VC_ID.MAIN) as? MainVC {
                    let navController = UINavigationController(rootViewController: mainPageView)
                    navController.navigationBar.tintColor = UIColor.white
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                }
            }
        case 1:
            Utils.showAlert(message: MSG_ALERT.kALERT_FUNCTION_UNDER_CONSTRUCTION, view: self)
        case 2:
            Utils.showSavedPdf(url: Constants.JBS.DOC_URL, fileName: Constants.JBS.DOC_NAME) { (path) in
                if path != "" {
                    self.loadDocument(urlPath: path)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
            }
        case 3:
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kJBS.rawValue) {
                guard let story: UIStoryboard = UIStoryboard(name: "JBS", bundle: nil) as UIStoryboard?,
                      let vc =  story.instantiateViewController(withIdentifier: "StartingVC") as? StartingVC else { return }
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
        default:
            break
        }
    }
}
