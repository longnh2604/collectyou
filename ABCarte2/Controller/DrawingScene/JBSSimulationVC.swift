//
//  JBSSimulationVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

class JBSSimulationVC: UIViewController {

    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var media = MediaData()
    var imageConverted: Data?
    var penMode = 1
    var imgSelected:UIImage? = nil
    var cellSelected:Int? = nil
    var imageOriginal: UIImage? = nil
    var image = UIImageView()

    let kSelectColor = UIColor.init(red: 12/255, green: 249/255, blue: 158/255, alpha: 1)
    let kUnSelectColor = UIColor.clear
    //color set
    //A
    let kConcealerA = UIColor.init(red: 232/255, green: 206/255, blue: 191/255, alpha: 1)
    let kEyeBrowA = UIColor.init(red: 124/255, green: 106/255, blue: 88/255, alpha: 1)
    //B
    let kConcealerB = UIColor.init(red: 218/255, green: 185/255, blue: 165/255, alpha: 1)
    let kEyeBrowB = UIColor.init(red: 133/255, green: 98/255, blue: 84/255, alpha: 1)
    //C
    let kConcealerC = UIColor.init(red: 230/255, green: 204/255, blue: 193/255, alpha: 1)
    let kEyeBrowC = UIColor.init(red: 144/255, green: 105/255, blue: 95/255, alpha: 1)
    //D
    let kConcealerD = UIColor.init(red: 234/255, green: 204/255, blue: 186/255, alpha: 1)
    let kEyeBrowD = UIColor.init(red: 78/255, green: 65/255, blue: 69/255, alpha: 1)
    
    //IBOutlet
    @IBOutlet weak var viewDrawing: SketchView!
    @IBOutlet weak var viewColor: RoundUIView!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnPen: UIButton!
    @IBOutlet weak var btnAirBrush: UIButton!
    @IBOutlet weak var btnEraser: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewBrushSize: UIView!
    @IBOutlet weak var slideBWidth: MySlider!
    @IBOutlet weak var lblBrushSize: UILabel!
    @IBOutlet weak var btnEyeDrop: RoundButton!
    @IBOutlet weak var btnPenMode: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        setupCanvas()
        
        let logo = UIImage(named: "JBS_UIkit-icon.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
      
        btnComplete.layer.cornerRadius = 10
        btnSave.layer.cornerRadius = 10
        btnComplete.clipsToBounds = true
        btnSave.clipsToBounds = true
        
        updateDrawButtonStatus()
        btnPenMode.setTitle("指", for: .normal)
        btnPenMode.backgroundColor = COLOR_SET.kPENSELECT
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewDrawing.removeFromSuperview()
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setupCanvas() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let url = URL(string: media.url)
        image.sd_setImage(with: url) { (image, error, cachetype, url) in
            if (error != nil) {
                //Failure code here
                Utils.showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
            } else {
                //Success code here
                self.viewDrawing.frame = CGRect(x: (self.view.frame.width - 768)/2, y: 0, width: 768, height: 1024)
                self.viewDrawing.loadImage(image: (image?.resizeImage(targetSize: CGSize(width: 768, height: 1024)))!, topTrans: false,x:(self.view.frame.width - 768)/2,y:0)
                self.viewDrawing.lineWidth = 1.0
                self.viewDrawing.drawTool = .pen
                self.viewDrawing.lineColor = self.kEyeBrowA
                self.viewDrawing.sketchViewDelegate = self
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func updateDrawButtonStatus() {
        switch penMode {
        case 1:
            changeBrushColor()
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_ON.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 2:
            changeAirBrushColor()
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_ON.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 3:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_ON.png"), for: .normal)
        case 4:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_ON.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 6:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 7:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        default:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        }
        changeBrushSizeView()
    }
    
    func changeBrushColor() {
        viewColor.backgroundColor = viewDrawing.lineColor
    }
    
    func changeAirBrushColor() {
        viewDrawing.lineColor = kConcealerA
        viewColor.backgroundColor = viewDrawing.lineColor
    }
    
    func changeBrushSizeView() {
        viewBrushSize.isHidden = false
        
        switch penMode {
        case 1:
            slideBWidth.minimumValue = 0.1
            slideBWidth.maximumValue = 2
            slideBWidth.value = 1.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "1.0"
        case 2:
            slideBWidth.minimumValue = 0.1
            slideBWidth.maximumValue = 5
            slideBWidth.value = 2.5
            slideBWidth.isContinuous = true
            lblBrushSize.text = "2.5"
        case 4:
            slideBWidth.minimumValue = 0.1
            slideBWidth.maximumValue = 30
            slideBWidth.value = 15.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "15.0"
        case 3,7:
            viewBrushSize.isHidden = true
        default:
            slideBWidth.minimumValue = 0
            slideBWidth.maximumValue = 2
            slideBWidth.value = 1.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "1.0"
        }
        viewDrawing.lineWidth = CGFloat(slideBWidth.value)
    }
    
    func onSaveImage(image: UIImage) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.imageConverted = image.jpegData(compressionQuality: 0.75)
        
        APIRequest.onAddMediaIntoCarte(carteID: self.carte.id, mediaData: self.imageConverted!) { (success) in
            if success {
            } else {
                Utils.showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func checkUndoRedoStatus() {
        guard let undo = viewDrawing.canUndo() as Bool?,let redo = viewDrawing.canRedo() as Bool? else {
            btnUndo.isEnabled = false
            btnRedo.isEnabled = false
            return
        }
        
        if undo == true {
            btnUndo.isEnabled = true
        } else {
            btnUndo.isEnabled = false
        }
        
        if redo == true {
            btnRedo.isEnabled = true
        } else {
            btnRedo.isEnabled = false
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "保存しました", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "エラー", message: "写真のアクセス許可を確認してください。", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onBrushWidthChange(_ sender: MySlider) {
        let string = String(format:"%.1f", sender.value)
        lblBrushSize.text = "\(string)"

        let floatNo = (string as NSString).floatValue
        viewDrawing.lineWidth = CGFloat(floatNo)
    }
    
    @IBAction func onToolSelect(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            viewDrawing.drawTool = .pen
            penMode = 1
            updateDrawButtonStatus()
        case 2:
            viewDrawing.drawTool = .eraser
            penMode = 4
            updateDrawButtonStatus()
        case 3:
            viewDrawing.drawTool = .pen
            penMode = 2
            updateDrawButtonStatus()
        case 4:
            viewDrawing.undo {
                self.checkUndoRedoStatus()
            }
        case 5:
            viewDrawing.redo {
                self.checkUndoRedoStatus()
            }
        case 6:
            viewDrawing.drawTool = .eyedrop
            penMode = 3
            updateDrawButtonStatus()
        default:
            return
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(viewDrawing.asImage(), self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func onDrawingModeChange(_ sender: UIButton) {
       let alert = UIAlertController(title: "描画モードを選択してください", message: nil, preferredStyle: .actionSheet)
       let pencil = UIAlertAction(title: "ペンシル", style: .default) { UIAlertAction in
           self.viewDrawing.penMode = 1
           self.penMode = 1
           self.btnPenMode.setTitle("ペンシル", for: .normal)
           self.btnPenMode.backgroundColor = COLOR_SET.kPENSELECT
           self.updateDrawButtonStatus()
       }
       let finger = UIAlertAction(title: "指", style: .default) { UIAlertAction in
           self.viewDrawing.penMode = 0
           self.penMode = 1
           self.btnPenMode.setTitle("指", for: .normal)
           self.btnPenMode.backgroundColor = COLOR_SET.kPENSELECT
           self.updateDrawButtonStatus()
       }

       alert.addAction(pencil)
       alert.addAction(finger)

       alert.popoverPresentationController?.sourceView = self.btnPenMode
       alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
       alert.popoverPresentationController?.sourceRect = self.btnPenMode.bounds
       DispatchQueue.main.async {
           self.present(alert, animated: true, completion: nil)
       }
    }
}

//*****************************************************************
// MARK: - SketchView Delegate
//*****************************************************************

extension JBSSimulationVC: SketchViewDelegate {
    
    func drawView(_ view: SketchView, undo: NSMutableArray, didEndDrawUsingTool tool: AnyObject) {
        checkUndoRedoStatus()
    }
    
    func updateNewColor(color: UIColor) {
        viewDrawing.lineColor = color
        viewColor.backgroundColor = color
    }
}
