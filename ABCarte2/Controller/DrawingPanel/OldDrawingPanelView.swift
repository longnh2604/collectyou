//
//  DrawingPanelView.swift
//  ABCarte2
//
//  Created by Long on 2019/03/13.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

@objc protocol OldDrawingPanelViewDelegate: class {
    @objc optional func onToolSelect(type:Int,view:UIView)
    @objc optional func onFavColorSelect(color:UIColor)
    @objc optional func onFavColorSetting()
    @objc optional func onPenSizeValueChange(value:CGFloat)
    @objc optional func onOpacityValueChange(value:CGFloat)
    @objc optional func onNotAccess()
}

class OldDrawingPanelView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //IBOutlet
    @IBOutlet weak var collectTool: UICollectionView!
    @IBOutlet weak var viewCurrColor: UIView!
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
    
    //Variable
    weak var delegate: OldDrawingPanelViewDelegate?
    var selectedTool: Int = 0
    
    class func instanceFromNib(_ delegate: OldDrawingPanelViewDelegate?) -> OldDrawingPanelView {
        let panelView : OldDrawingPanelView = UINib(
            nibName: "OldDrawingPanelView",
            bundle: Bundle.main
            ).instantiate(
                withOwner: self,
                options: nil
            ).first as! OldDrawingPanelView
        
        panelView.delegate = delegate
        
        return panelView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "penToolCell", bundle: nil)
        collectTool.register(nib, forCellWithReuseIdentifier: "penToolCell")
        
        collectTool.delegate = self
        collectTool.dataSource = self
        collectTool.allowsMultipleSelection = false
        
        //default color
        viewCurrColor.backgroundColor = UIColor.black
        viewCurrColor.layer.cornerRadius = 10
        viewCurrColor.layer.borderWidth = 3
        viewCurrColor.layer.borderColor = UIColor.black.cgColor
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPenSize.rawValue) {
            sliderPenSize.minimumValue = 0.1
            sliderPenSize.maximumValue = 30
        } else {
            sliderPenSize.minimumValue = 5
            sliderPenSize.maximumValue = 20
        }
        
        sliderPenSize.value = 5
        lblPenSize.text = "\(Int(sliderPenSize.value))pt"
        
        sliderOpacity.minimumValue = 0.01
        sliderOpacity.maximumValue = 1
        sliderOpacity.value = 1
        
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
    
    func onColorChange(color:UIColor) {
        viewCurrColor.backgroundColor = color
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
        case 6:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kEyeDrop.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        case 7:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        case 8:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMosaic.rawValue) {
                delegate?.onNotAccess?()
                return false
            }
        case 9:
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
        switch sender.tag {
        case 1:
            viewCurrColor.backgroundColor = btnFav1.backgroundColor
        case 2:
            viewCurrColor.backgroundColor = btnFav2.backgroundColor
        case 3:
            viewCurrColor.backgroundColor = btnFav3.backgroundColor
        case 4:
            viewCurrColor.backgroundColor = btnFav4.backgroundColor
        case 5:
            viewCurrColor.backgroundColor = btnFav5.backgroundColor
        default:
            break
        }
        delegate?.onFavColorSelect?(color: viewCurrColor.backgroundColor!)
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
    
    //*****************************************************************
    // MARK: - CollectView
    //*****************************************************************
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "penToolCell", for: indexPath) as! penToolCell
        cell.layer.cornerRadius = 5
        cell.configure(type: indexPath.row,style:0)
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
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
