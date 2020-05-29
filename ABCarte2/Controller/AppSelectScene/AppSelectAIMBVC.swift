//
//  AppSelectAIMBVC.swift
//  ABCarte2
//
//  Created by Long on 2019/05/13.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import UXMPDFKit

class AppSelectAIMBVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var imvBackground: UIImageView!
    @IBOutlet weak var btnKarteAccess: UIButton!
    @IBOutlet weak var btnCatalogue1: UIButton!
    @IBOutlet weak var btnCatalogue2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        loadData()
    }
    
    fileprivate func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        Utils.saveImage(urlString: Constants.AIMB.MENU_SELECT_BACKGROUND_URL, fileName: Constants.AIMB.MENU_SELECT_BACKGROUND_NAME) { (success) in
            if success {
                Utils.showSavedImage(url: Constants.AIMB.MENU_SELECT_BACKGROUND_URL, fileName: Constants.AIMB.MENU_SELECT_BACKGROUND_NAME) { (url) in
                    self.imvBackground.image = UIImage(contentsOfFile: url)
                }
            }
        }

        Utils.saveImage(urlString: Constants.AIMB.KARTE_ACCESS_URL, fileName: Constants.AIMB.KARTE_ACCESS_NAME) { (success) in
            if success {
                Utils.showSavedImage(url: Constants.AIMB.KARTE_ACCESS_URL, fileName: Constants.AIMB.KARTE_ACCESS_NAME) { (url) in
                    self.btnKarteAccess.setImage(UIImage(contentsOfFile: url), for: .normal)
                }
            }
        }
        Utils.saveImage(urlString: Constants.AIMB.CATALOGUE1_ACCESS_URL, fileName: Constants.AIMB.CATALOGUE1_ACCESS_NAME) { (success) in
            if success {
                Utils.showSavedImage(url: Constants.AIMB.CATALOGUE1_ACCESS_URL, fileName: Constants.AIMB.CATALOGUE1_ACCESS_NAME) { (url) in
                    self.btnCatalogue1.setImage(UIImage(contentsOfFile: url), for: .normal)
                }
            }
        }
        Utils.saveImage(urlString: Constants.AIMB.CATALOGUE2_ACCESS_URL, fileName: Constants.AIMB.CATALOGUE2_ACCESS_NAME) { (success) in
            if success {
                Utils.showSavedImage(url: Constants.AIMB.CATALOGUE2_ACCESS_URL, fileName: Constants.AIMB.CATALOGUE2_ACCESS_NAME) { (url) in
                    self.btnCatalogue2.setImage(UIImage(contentsOfFile: url), for: .normal)
                }
            }
        }
        
        Utils.savePdf(urlString: Constants.AIMB.DOC1_URL, fileName: Constants.AIMB.DOC1_NAME) { (success) in
            if success {
                Utils.savePdf(urlString: Constants.AIMB.DOC2_URL, fileName: Constants.AIMB.DOC2_NAME) { (success) in
                    SVProgressHUD.dismiss()
                }
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onCarteSelect(_ sender: UIButton) {
        if let story: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? {
            if let mainPageView =  story.instantiateViewController(withIdentifier: Constants.VC_ID.MAIN) as? MainVC {
                let navController = UINavigationController(rootViewController: mainPageView)
                navController.navigationBar.tintColor = UIColor.white
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onPortfolioSelect(_ sender: UIButton) {
        switch sender.tag {
        case 1:
//            open(scheme: "poste://?readType=0&contentNum=28167&pageNo=1&contentUrl=http://abcarte.jp/testP/Basic/&readFrom=0")
            
            Utils.showSavedPdf(url: Constants.AIMB.DOC1_URL, fileName: Constants.AIMB.DOC1_NAME) { (path) in
                if path != "" {
                    self.loadDocument(urlPath: path)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
            }
        case 2:
//            open(scheme: "poste://?readType=0&contentNum=31297&pageNo=1&contentUrl=http://abcarte.jp/testP/Rename_test/&readFrom=0")
            
            Utils.showSavedPdf(url: Constants.AIMB.DOC2_URL, fileName: Constants.AIMB.DOC2_NAME) { (path) in
                if path != "" {
                    self.loadDocument(urlPath: path)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
            }
        default:
            break
        }
    }
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
        UIApplication.shared.open(url, options: [:], completionHandler: {
          (success) in
            if success {
                print("Open \(scheme): \(success)")
            } else {
                let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id1340030905"
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            }
        })
      }
    }
}
