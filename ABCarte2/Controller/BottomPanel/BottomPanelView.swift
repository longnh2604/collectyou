//
//  BottomPanelView.swift
//  ABCarte2
//
//  Created by Long on 2019/01/16.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

@objc protocol BottomPanelViewDelegate: class {
    @objc optional func tapSetting()
    @objc optional func tapInfo()
    @objc optional func tapRefresh()
    @objc optional func tapStamp()
    @objc optional func tapHierarchy()
    @objc optional func tapMsgTemp()
}

class BottomPanelView: UIView {

    //IBOutlet
    @IBOutlet weak var viewSetting: UIView!
    @IBOutlet weak var viewRefresh: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewStamp: UIView!
    @IBOutlet weak var viewHierarchy: UIView!
    @IBOutlet weak var viewMsgTemp: UIView!
    
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnStamp: UIButton!
    @IBOutlet weak var btnHierarchy: UIButton!
    @IBOutlet weak var btnMsgTemp: UIButton!
    
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var lblSync: UILabel!
    @IBOutlet weak var lblStampReg: UILabel!
    @IBOutlet weak var lblShop: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblMsgTemp: UILabel!
    
    //Variable
    weak var delegate: BottomPanelViewDelegate?
    
    class func instanceFromNib(_ delegate: BottomPanelViewDelegate?) -> BottomPanelView {
        let panelView : BottomPanelView = UINib(
            nibName: "BottomPanelView",
            bundle: Bundle.main
            ).instantiate(
                withOwner: self,
                options: nil
            ).first as! BottomPanelView
        
        panelView.delegate = delegate
        return panelView
    }
    
    func updateLocalize() {
        lblSetting.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Setting", comment: "")
        lblSync.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Sync", comment: "")
        lblStampReg.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Stamp Reg", comment: "")
        lblShop.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Shop", comment: "")
        lblInfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Info", comment: "")
    }
    
    func deactiveBottomPanelButtons() {
        viewSetting.isHidden = true
        viewRefresh.isHidden = true
        viewStamp.isHidden = true
        viewMsgTemp.isHidden = true
        viewHierarchy.isHidden = true
    }
    
    func updateLayout() {
        if let set = UserPreferences.appColorSet {
            switch set {
            case AppColorSet.standard.rawValue:
                self.backgroundColor = COLOR_SET000.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.jbsattender.rawValue:
                self.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.romanpink.rawValue:
                self.backgroundColor = COLOR_SET002.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.hisul.rawValue:
                self.backgroundColor = COLOR_SET003.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.lavender.rawValue:
                self.backgroundColor = COLOR_SET004.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.pinkgold.rawValue:
                self.backgroundColor = COLOR_SET005.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.mysteriousnight.rawValue:
                self.backgroundColor = COLOR_SET006.kCOMMAND_BUTTON_BACKGROUND_COLOR
            case AppColorSet.gardenparty.rawValue:
                self.backgroundColor = COLOR_SET007.kCOMMAND_BUTTON_BACKGROUND_COLOR
            default:
                break
            }
        }
    }
 
    @IBAction func tapSettingButton(_ sender: UIButton) {
        delegate?.tapSetting?()
    }
    
    @IBAction func tapInfoButton(_ sender: UIButton) {
        delegate?.tapInfo?()
    }
    
    @IBAction func onRefresh(_ sender: UIButton) {
        delegate?.tapRefresh?()
    }
    
    @IBAction func tapStampButton(_ sender: UIButton) {
        delegate?.tapStamp?()
    }
    
    @IBAction func tapHierarchyButton(_ sender: UIButton) {
        delegate?.tapHierarchy?()
    }
    
    @IBAction func tapMsgTemplateButton(_ sender: UIButton) {
        delegate?.tapMsgTemp?()
    }
}
