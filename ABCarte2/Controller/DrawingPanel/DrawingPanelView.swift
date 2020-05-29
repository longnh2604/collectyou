//
//  DrawingPanelView.swift
//  ABCarte2
//
//  Created by Long on 2019/03/13.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import HueKit

@objc protocol DrawingPanelViewDelegate: class {
    @objc optional func onToolSelect(type:Int,view:UIView)
    @objc optional func onFavColorSelect(color:UIColor)
    @objc optional func onFavColorSetting()
    @objc optional func onPenSizeValueChange(value:CGFloat)
    @objc optional func onOpacityValueChange(value:CGFloat)
    @objc optional func onColorChange(color:UIColor)
    @objc optional func onNotAccess()
    @objc optional func onIllegalInput()
}

class DrawingPanelView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //IBOutlet
    @IBOutlet weak var collectTool: UICollectionView!
    @IBOutlet weak var lblTitlePenSize: UILabel!
    @IBOutlet weak var lblPenSize: RoundLabel!
    @IBOutlet weak var sliderPenSize: MySlider!
    @IBOutlet weak var lblTitleOpacity: UILabel!
    @IBOutlet weak var lblOpacity: RoundLabel!
    @IBOutlet weak var sliderOpacity: MySlider!
    @IBOutlet weak var btnFavoriteColor: RoundButton!
    @IBOutlet weak var btnFav1: RoundButton!
    @IBOutlet weak var btnFav2: RoundButton!
    @IBOutlet weak var btnFav3: RoundButton!
    @IBOutlet weak var btnFav4: RoundButton!
    @IBOutlet weak var btnFav5: RoundButton!
    
    @IBOutlet weak var colorSquarePicker: ColorSquarePicker!
    @IBOutlet weak var colorBarPicker: ColorBarPicker!
    @IBOutlet weak var tfRed: UITextField!
    @IBOutlet weak var tfGreen: UITextField!
    @IBOutlet weak var tfBlue: UITextField!
    @IBOutlet weak var lblHex: UILabel!
    //Variable
    weak var delegate: DrawingPanelViewDelegate?
    var selectedTool: Int = 0
    var currColor: UIColor?
    var penSizeValue: Float?
    var penOpacityValue: Float?
    
    class func instanceFromNib(color:UIColor,penSize:CGFloat,penOpacity:CGFloat,penTool:Int,delegate: DrawingPanelViewDelegate?) -> DrawingPanelView {
        let panelView : DrawingPanelView = UINib(
            nibName: "DrawingPanelView",
            bundle: Bundle.main
            ).instantiate(
                withOwner: self,
                options: nil
            ).first as! DrawingPanelView
        
        panelView.currColor = color
        panelView.penSizeValue = Float(penSize)
        panelView.penOpacityValue = Float(penOpacity)
        panelView.selectedTool = penTool
        panelView.delegate = delegate
        panelView.setupLayout()
        
        return panelView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "penToolCell", bundle: nil)
        collectTool.register(nib, forCellWithReuseIdentifier: "penToolCell")
        
        collectTool.delegate = self
        collectTool.dataSource = self
        collectTool.allowsMultipleSelection = false
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPenSize.rawValue) {
            sliderPenSize.minimumValue = 0.1
            sliderPenSize.maximumValue = 30
        } else {
            sliderPenSize.minimumValue = 5
            sliderPenSize.maximumValue = 20
        }
        
        sliderOpacity.minimumValue = 0.01
        sliderOpacity.maximumValue = 1
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kOpacity.rawValue) {
            lblTitleOpacity.isEnabled = true
            lblOpacity.isEnabled = true
            sliderOpacity.isEnabled = true
        } else {
            lblTitleOpacity.isEnabled = false
            lblOpacity.isEnabled = false
            sliderOpacity.isEnabled = false
        }
        
        //set favorite color
        btnFav1.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[0])
        btnFav2.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[1])
        btnFav3.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[2])
        btnFav4.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[3])
        btnFav5.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[4])
    }
    
    func setupLayout() {
        //current color
        if let rgbColor = currColor?.rgbValue {
            tfRed.text = String(format: "%.f", rgbColor.r * 255)
            tfGreen.text = String(format: "%.f", rgbColor.g * 255)
            tfBlue.text = String(format: "%.f", rgbColor.b * 255)
            lblHex.text = currColor?.hexString
            
            let h = currColor?.hsvValue?.h ?? 0.0
            let s = currColor?.hsvValue?.s ?? 0.0
            let v = currColor?.hsvValue?.v ?? 0.0
            colorSquarePicker.hue = h
            colorSquarePicker.value.x = s
            colorSquarePicker.value.y = v
            
            colorBarPicker.hue = h
        }
        
        //pen size
        if let penSize = penSizeValue {
            sliderPenSize.value = penSize
        } else {
            sliderPenSize.value = 5
        }
        let size = String(format:"%.1f", sliderPenSize.value)
        lblPenSize.text = "\(size)pt"
        
        //opacity
        if let penOpacity = penOpacityValue {
            sliderOpacity.value = penOpacity
        } else {
            sliderOpacity.value = 1
        }
        let value = Int(sliderOpacity.value * 100)
        lblOpacity.text = "\(value)%"
    }
    
    func onSaveFavoriteColor(color:UIColor,index:Int) {
        switch index {
        case 1:
            btnFav1.backgroundColor = color
        case 2:
            btnFav2.backgroundColor = color
        case 3:
            btnFav3.backgroundColor = color
        case 4:
            btnFav4.backgroundColor = color
        case 5:
            btnFav5.backgroundColor = color
        default:
            break
        }
    }
    
    func checkCondition(indexP: Int)->Bool {
        switch indexP {
        case 4:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kEyeDrop.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        case 5:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        case 6:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMosaic.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        case 7:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        default:
            break
        }
        return true
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onFavColorSetting(_ sender: UIButton) {
        delegate?.onFavColorSetting?()
    }
    
    @IBAction func onFavColorSelect(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            delegate?.onFavColorSelect?(color: color)
        }
    }
    
    @IBAction func onPenSizeChange(_ sender: UISlider) {
        let size = String(format:"%.1f", sender.value)
        
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            _self.lblPenSize.text = "\(size) pt"
        }
        delegate?.onPenSizeValueChange?(value: CGFloat(sender.value))
    }
    
    @IBAction func onOpacityChange(_ sender: UISlider) {
        let value = Int(sender.value * 100)
        lblOpacity.text = "\(value)%"
        delegate?.onOpacityValueChange?(value: CGFloat(sender.value))
    }
    
    @IBAction func onColorSquarePickerChange(_ sender: ColorSquarePicker) {
        didChangeColor(sender.color)
    }
    
    @IBAction func onColorBarPickerChange(_ sender: ColorBarPicker) {
        colorSquarePicker.hue = sender.hue
        didChangeColor(colorSquarePicker.color)
    }
    
    func didChangeColor(_ color: UIColor) {
        
        guard let rgbValue = color.rgbValue else { return }
        
        tfRed.text = String(format: "%.f", rgbValue.r * 255)
        tfGreen.text = String(format: "%.f", rgbValue.g * 255)
        tfBlue.text = String(format: "%.f", rgbValue.b * 255)
        
        lblHex.text = color.hexString
        delegate?.onColorChange?(color: color)
    }
    
    @IBAction func onRGBColorChange(_ sender: UITextField) {
        guard let noInput = Int(sender.text ?? "0") else {
            delegate?.onIllegalInput?()
            return
        }
        if noInput > 255 || noInput < 0 {
            delegate?.onIllegalInput?()
            return
        }
        let red = (Float(tfRed.text!) ?? 0)/255
        let green = (Float(tfGreen.text!) ?? 0)/255
        let blue = (Float(tfBlue.text!) ?? 0)/255
        
        currColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        if let rgbColor = currColor?.rgbValue {
            tfRed.text = String(format: "%.f", rgbColor.r * 255)
            tfGreen.text = String(format: "%.f", rgbColor.g * 255)
            tfBlue.text = String(format: "%.f", rgbColor.b * 255)
            lblHex.text = currColor?.hexString
            
            let h = currColor?.hsvValue?.h ?? 0.0
            let s = currColor?.hsvValue?.s ?? 0.0
            let v = currColor?.hsvValue?.v ?? 0.0
            colorSquarePicker.hue = h
            colorSquarePicker.value.x = s
            colorSquarePicker.value.y = v
            
            colorBarPicker.hue = h
        }
    }
    
    //*****************************************************************
    // MARK: - CollectView
    //*****************************************************************
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "penToolCell", for: indexPath) as! penToolCell
        cell.layer.cornerRadius = 5
        cell.configure(type: indexPath.row,style:1)
        if selectedTool == indexPath.row {
            cell.isSelected = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! penToolCell
        
        if !checkCondition(indexP: indexPath.row) {
            collectionView.cellForItem(at: IndexPath(item: selectedTool, section: 0))?.isSelected = false
            cell.isSelected = true
            selectedTool = indexPath.row
            delegate?.onNotAccess?()
            return
        }
        
        if selectedTool != indexPath.row {
            //remove previous selected status
            collectionView.cellForItem(at: IndexPath(item: selectedTool, section: 0))?.isSelected = false
            cell.isSelected = true
            selectedTool = indexPath.row
        }
        
        delegate?.onToolSelect?(type: indexPath.row,view:cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
