//
//  CustomerFinalSignVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/01/08.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

enum DDdoc {
    case brochure
    case contract
}

class CustomerFinalSignVC: UIViewController {

    //Variable
    var customer = CustomerData()
    var brochure = BrochureData()
    var lockZoom: Bool = false
    var docType: DDdoc?
    var docImage = [UIImage]()
    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var btnChangeDocument: UIButton!
    @IBOutlet weak var btnFloatMenu: JJFloatingActionButton!
    
    override func viewDidDisappear(_ animated: Bool) {
        docImage = []
        sketchView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCanvas()
        setupLayout()
    }
    
    private func setupCanvas() {
        //initial data first
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        //add temporary doc
        var docBrochure = UIImage()
        var docContract = UIImage()
        
        //check file has existed on server or not
        //brochure
        if brochure.brochure_confirm_signed_url != "" {
            let url = URL(string: brochure.brochure_confirm_signed_url)
            let data = try? Data(contentsOf: url!)
            docBrochure = UIImage(data: data!)!
        } else {
            docBrochure = UIImage(named: "doc_brochure_final_signed")!
            //add serial number
            docBrochure = Utils.onGenerateContractSerialNumber(number: brochure.broch_serial_num, image: docBrochure)!
        }
        
        //contract
        if brochure.contract_confirm_signed_url != "" {
            let url = URL(string: brochure.contract_confirm_signed_url)
            let data = try? Data(contentsOf: url!)
            docContract = UIImage(data: data!)!
        } else {
            docContract = UIImage(named: "doc_contract_final_signed")!
            //add serial number
            docContract = Utils.onGenerateContractSerialNumber(number: brochure.cont_serial_num, image: docContract)!
        }
        
        docImage.append(docBrochure)
        docImage.append(docContract)
        
        //load doc data
        let doc = checkPresentDoc()
        
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.2
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        switch doc.size.width {
            case 1536:
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                self.sketchView.loadImage(image: doc, topTrans: false, x: 0, y: 0)
            default:
                self.sketchView.frame = CGRect(x: 0, y: 0, width: 1536, height: 2048)
                self.sketchView.loadImage(image: doc, topTrans: false, x: 0, y: 0)
        }
        
        self.viewDrawing.frame = self.sketchView.frame
        
        self.scrollView.contentSize = self.sketchView.frame.size
        //resize to fit
        self.scrollView.zoomScale = self.view.frame.width/self.sketchView.frame.width
            
        self.sketchView.sketchViewDelegate = self
        self.sketchView.isUserInteractionEnabled = true
        self.sketchView.lineWidth = 2.0
        self.sketchView.penMode = 2
        
        self.scrollView.isScrollEnabled = false
        
        SVProgressHUD.dismiss()
    }
    
    private func checkPresentDoc() -> UIImage {
        if brochure.contract_confirm_signed_url == "" && brochure.brochure_confirm_signed_url != "" && brochure.contract_signed_url != "" {
            docType = .contract
            return docImage[1]
        } else {
            docType = .brochure
            return docImage[0]
        }
    }

    private func setupLayout() {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登録", style: .plain, target: self, action: #selector(onRegister))
        
        localizeLanguage()
        
        //check contract has existed or not
        if brochure.contract_signed_url != "" && brochure.brochure_confirm_signed_url != "" {
            btnChangeDocument.isHidden = false
        }
        
        checkCondition()
        
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
            self.sketchView.drawTool = .eraser
            self.sketchView.lineWidth = 15
        }

        btnFloatMenu.addItem(title: "書く", image: UIImage(named: "icon_pencil")) { item in
            self.sketchView.drawTool = .pen
            self.sketchView.lineWidth = 2.0
        }
    }
    
    private func checkCondition() {
        switch docType {
        case .brochure:
            //check signed url has existed or not
            if brochure.brochure_confirm_signed_url != "" {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                sketchView.isUserInteractionEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                sketchView.isUserInteractionEnabled = true
            }
            btnChangeDocument.setTitle("契約切替", for: .normal)
        case .contract:
            //check signed url has existed or not
            if brochure.contract_confirm_signed_url != "" {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                sketchView.isUserInteractionEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                sketchView.isUserInteractionEnabled = true
            }
            btnChangeDocument.setTitle("概要書面切替", for: .normal)
        default:
            break
        }
    }
    
    @objc func onRegister() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let imgData = sketchView.image?.resizeImage(targetSize: CGSize(width: 1536, height: 2048)).jpegData(compressionQuality: 1.0)
        
        switch docType {
        case .brochure:
            APIRequest.onAddBrochureConfirmSignature(brochureID: brochure.id, signatureData: imgData!, completion: { (success,url) in
                if success {
                    let dict : [String : Any?] = ["brochure_confirm_signed_url" : url]
                    RealmServices.shared.update(self.brochure, with: dict)
                    self.onClose()
                    Utils.showAlert(message: "概要書の登録が完了しました。", view: self)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                self.checkCondition()
                SVProgressHUD.dismiss()
            })
        case .contract:
            APIRequest.onAddContractConfirmSignature(brochureID: brochure.id, signatureData: imgData!, completion: { (success,url) in
                if success {
                    let dict : [String : Any?] = ["contract_confirm_signed_url" : url]
                    RealmServices.shared.update(self.brochure, with: dict)
                    self.onClose()
                    Utils.showAlert(message: "契約の登録が完了しました。", view: self)
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                self.checkCondition()
                SVProgressHUD.dismiss()
            })
        default:
            break
        }
    }
    
    private func onClose() {
        let controllers = self.navigationController?.viewControllers
            for vc in controllers! {
            if vc is CarteListVC {
                _ = self.navigationController?.popToViewController(vc as! CarteListVC, animated: true)
            }
        }
    }
    
    private func localizeLanguage() {
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "受領サイン", comment: "")
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func reloadCanvas() {
        //reset draw view
        sketchView.clear()
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        switch docType {
        case .brochure:
            sketchView.loadImage(image: docImage[0], topTrans: false, x: 0, y: 0)
        case .contract:
            sketchView.loadImage(image: docImage[1], topTrans: false, x: 0, y: 0)
        default:
            break
        }
        self.scrollView.contentSize = self.sketchView.frame.size
        
        SVProgressHUD.dismiss()
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onChangeDocument(_ sender: UIButton) {
        switch docType {
        case .brochure:
            docImage[0] = sketchView.image!
            docType = .contract
        case .contract:
            docImage[1] = sketchView.image!
            docType = .brochure
        default:
            break
        }
        reloadCanvas()
        checkCondition()
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension CustomerFinalSignVC: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if lockZoom { return }
        guard let imageViewSize = viewDrawing.frame.size as CGSize? else { return }
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        if verticalPadding >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding + 100, left: horizontalPadding + 100, bottom: verticalPadding + 100, right: horizontalPadding + 100)
        } else {
            scrollView.contentSize = imageViewSize
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if lockZoom { return nil }
        return viewDrawing
    }
}

//*****************************************************************
// MARK: - SketchView Delegate
//*****************************************************************

extension CustomerFinalSignVC: SketchViewDelegate {
    
    func drawView(_ view: SketchView, undo: NSMutableArray, didEndDrawUsingTool tool: AnyObject) {
    }
    
    func updateNewColor(color: UIColor) {
    }
}
