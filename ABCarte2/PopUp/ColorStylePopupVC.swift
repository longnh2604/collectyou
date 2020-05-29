//
//  ColorStylePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/01/16.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol ColorStylePopupVCDelegate: class {
    func onColorStyleChange()
}

class ColorStylePopupVC: UIViewController {

    //Variable
    var arrDefaultColorStyle = ["Roman Pink","HiSul","Garden Party"]
    var arrDefaultPhotoStyle = ["img_color_style_2","img_color_style_3","img_color_style_7"]
    var arrColorStyle = ["Roman Pink","HiSul","Garden Party","Collect You","J.Brow","Lavender","Pink Gold","Mysterious Night"]
    var arrPhotoStyle = ["img_color_style_2","img_color_style_3","img_color_style_7","img_color_style_0","img_color_style_1","img_color_style_4","img_color_style_5","img_color_style_6"]
    var indexSelect :Int = 0

    weak var delegate:ColorStylePopupVCDelegate?
    
    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblColorStyle: UITableView!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        let nib = UINib(nibName: "ColorStyleCell", bundle: nil)
        tblColorStyle.register(nib, forCellReuseIdentifier: "ColorStyleCell")
        
        tblColorStyle.delegate = self
        tblColorStyle.dataSource = self
        tblColorStyle.layer.borderWidth = 2
        tblColorStyle.layer.borderColor = UIColor.black.cgColor
        tblColorStyle.layer.cornerRadius = 5
        tblColorStyle.allowsMultipleSelection = false
        
        if let set = UserPreferences.appColorSet {
            indexSelect = set
            tblColorStyle.selectRow(at: IndexPath(row: indexSelect, section: 0), animated: false, scrollPosition: .none)
        } else {
            tblColorStyle.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
        
        Utils.setButtonColorStyle(button: btnSave, type: 1)
        
        localizeLanguage()
    }
    
    fileprivate func localizeLanguage() {
        lblTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Application Theme", comment: "")
        btnSave.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Register",comment: ""), for: .normal)
        btnCancel.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel",comment: ""), for: .normal)
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
        UserPreferences.appColorSet = indexSelect
        dismiss(animated: true) {
            self.delegate?.onColorStyleChange()
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - UITableView
//*****************************************************************

extension ColorStylePopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #if COLLECTU
        return arrDefaultColorStyle.count
        #else
        return arrColorStyle.count
        #endif
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorStyleCell") as? ColorStyleCell else { return UITableViewCell() }
        #if COLLECTU
        cell.configure(title: arrDefaultColorStyle[indexPath.row], photo: arrDefaultPhotoStyle[indexPath.row])
        #else
        cell.configure(title: arrColorStyle[indexPath.row], photo: arrPhotoStyle[indexPath.row])
        #endif
        if indexPath.row == indexSelect {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelect = indexPath.row
    }
    
}
