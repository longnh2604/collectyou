//
//  OtherSettingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import LGButton

class OtherSettingVC: UIViewController {
    //Variable
    var categories: Results<StampCategoryData>!
    var categoriesData: [StampCategoryData] = []
    
    var keywords: Results<StampKeywordData>!
    var keywordsData : [StampKeywordData] = []
    
    var maxStamp: Int?
    var isCreating: Bool = false
    var isModifying: Bool = false
    var stampIndex: Int?
    var keyIndex: Int?
    var textField: UITextField?
    var categoryID: Int?
    lazy var realm = try! Realm()
    
    //IBOutlet
    @IBOutlet weak var btnStampTitle: LGButton!
    @IBOutlet weak var tblMemo: UITableView!
    @IBOutlet weak var btnCreate: LGButton!
    @IBOutlet weak var btnDelete: LGButton!
    @IBOutlet weak var btnEdit: LGButton!
    @IBOutlet weak var tblKeyword: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        loadData()
    }

    func loadData() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        APIRequest.onGetStampCategoryDynamicOrStatic { (success) in
            if success {
                self.categories = self.realm.objects(StampCategoryData.self)
                self.categoriesData.removeAll()
                
                for i in 0 ..< self.categories.count {
                    self.categoriesData.append(self.categories[i])
                }
                
                self.tblMemo.reloadData()
                
                if let index = self.stampIndex {
                    self.tblMemo.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
                    self.stampIndex = index
                    self.categoryID = self.categoriesData[index].id
            
                    self.loadStamp(index: index)
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    private func checkButtonStatus(status:Bool) {
        btnStampTitle.isEnabled = status
        btnCreate.isEnabled = status
        btnEdit.isEnabled = status
        btnDelete.isEnabled = status
        
        if status {
            btnStampTitle.alpha = 1.0
            btnCreate.alpha = 1.0
            btnEdit.alpha = 1.0
            btnDelete.alpha = 1.0
        } else {
            btnStampTitle.alpha = 0.5
            btnCreate.alpha = 0.5
            btnEdit.alpha = 0.5
            btnDelete.alpha = 0.5
        }
    }
    
    func loadStamp(index:Int) {
        //check button status
        let accountID = UserDefaults.standard.integer(forKey: "collectu-accid")
        if categoriesData[index].fc_account_id == accountID {
            checkButtonStatus(status: true)
        } else {
            checkButtonStatus(status: false)
        }
        
        keywordsData.removeAll()
        for i in 0 ..< categoriesData[index].keywords.count {
            keywordsData.append(categoriesData[index].keywords[i])
        }

        tblKeyword.reloadData()
    }

    fileprivate func setupLayout() {
        //set navigation bar title
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Stamp Memo Registration", comment: "")
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControl.State())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControl.Event.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        localizeLanguage()
        
        tblMemo.delegate = self
        tblMemo.dataSource = self
        tblMemo.tableFooterView = UIView()
        
        tblKeyword.delegate = self
        tblKeyword.dataSource = self
        tblKeyword.tableFooterView = UIView()
        tblKeyword.isEditing = true
        tblKeyword.allowsSelectionDuringEditing = true
        
        let nib1 = UINib(nibName: "MessageTemplateCell", bundle: nil)
        tblMemo.register(nib1, forCellReuseIdentifier: "MessageTemplateCell")
        let nib2 = UINib(nibName: "MessageTemplateCell", bundle: nil)
        tblKeyword.register(nib2, forCellReuseIdentifier: "MessageTemplateCell")
    }
    
    fileprivate func localizeLanguage() {
        btnStampTitle.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Title Update", comment: "")
        btnCreate.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Add New", comment: "")
        btnEdit.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Edit", comment: "")
        btnDelete.titleString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Delete", comment: "")
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "入力して下さい";
        }
    }
    
    func configurationEditTitleTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            
            if let index = stampIndex {
                if categoriesData.count > 0 {
                    self.textField?.text = categoriesData[index].title
                } else {
                    self.textField?.placeholder = "入力して下さい"
                }
            } else {
                self.textField?.placeholder = "入力して下さい"
            }
        }
    }
    
    func configurationEditTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            
            if let index = keyIndex {
                if keywordsData.count > 0 {
                    self.textField?.text = keywordsData[index].content
                } else {
                    self.textField?.placeholder = "入力して下さい"
                }
            } else {
                self.textField?.placeholder = "入力して下さい"
            }
        }
    }
    
    func openAddKeywordAlert(id:Int) {
        guard let newPopup = KeywordsPopupVC(nibName: "KeywordsPopupVC", bundle: nil) as KeywordsPopupVC? else { return }
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 400, height: 250)
        newPopup.categoryID = id
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func openEditStampCategoryTitleAlert() {
        let alert = UIAlertController(title: "スタンプタイトル", message: "タイトルを追加してください。", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: configurationEditTitleTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            
            guard let id = self.categoryID else { return }
            
            if (self.textField?.text?.isEmpty)! {
                Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_TITLE, view: self)
            } else {
                if (self.textField?.text?.count)! > 10 {
                    Utils.showAlert(message: MSG_ALERT.kALERT_STAMP_TITLE_RESTRICT, view: self)
                    return
                }
                
                APIRequest.editStampCategoryTitle(categoryID: id, title: (self.textField?.text)!, completion: { (success) in
                    if success {
                        self.loadData()
                        Utils.showAlert(message: MSG_ALERT.kALERT_UPDATE_TITLE_SUCCESS, view: self)
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_TITLE, view: self)
                    }
                })
            }
            
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - Action
    //*****************************************************************
    
    @IBAction func onEditStampCategoryTitle(_ sender: LGButton) {
        
        guard categoryID != nil else {
            Utils.showAlert(message: MSG_ALERT.kALERT_SELECT_TITLE_EDIT, view: self)
            return
        }
        openEditStampCategoryTitleAlert()
    }
    
    @IBAction func onCreateNew(_ sender: LGButton) {
        guard let id = self.categoryID else {
            Utils.showAlert(message: MSG_ALERT.kALERT_SELECT_KEYWORD, view: self)
            return
        }
        openAddKeywordAlert(id: id)
    }
    
    @IBAction func onEdit(_ sender: LGButton) {
        if keyIndex != nil {
            guard let newPopup = KeywordsPopupVC(nibName: "KeywordsPopupVC", bundle: nil) as KeywordsPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 250)
            newPopup.keyword = keywordsData[keyIndex!]
            newPopup.categoryID = categoryID
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_SELECT_KEYWORD_EDIT, view: self)
        }
    }
    
    @IBAction func onDelete(_ sender: LGButton) {
        if keyIndex != nil {
            let alert = UIAlertController(title: "このキーワードを削除しますか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                APIRequest.onDeleteKeywords(keywordID: self.keywordsData[self.keyIndex!].id, completion: { (success) in
                    if success {
                        self.keyIndex = nil
                        self.loadData()
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_DELETE_KEYWORD, view: self)
                    }
                    SVProgressHUD.dismiss()
                })
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            alert.popoverPresentationController?.sourceRect = sender.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            Utils.showAlert(message: MSG_ALERT.kALERT_SELECT_KEYWORD_DELETE, view: self)
        }
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension OtherSettingVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            guard let max = maxStamp else {
                return categoriesData.count
            }
            return max
        } else {
            return keywordsData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTemplateCell") as? MessageTemplateCell else { return UITableViewCell() }
        if tableView.tag == 1 {
            if categoriesData.count > 0 {
                cell.configure(content: categoriesData[indexPath.row].title)
                cell.selectionStyle = .none
            }
        } else {
            if keywordsData.count > 0 {
                cell.configure(content: keywordsData[indexPath.row].content)
                cell.selectionStyle = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            stampIndex = indexPath.row
            categoryID = categoriesData[indexPath.row].id
            keyIndex = nil
            loadStamp(index: indexPath.row)
        } else {
            keyIndex = indexPath.row
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        try! realm.write {
//            let sourceObject = staffs[sourceIndexPath.row]
//            let destinationObject = staffs[destinationIndexPath.row]
//
//            let destinationObjectOrder = destinationObject.display_num
//
//            if sourceIndexPath.row < destinationIndexPath.row {
//                for index in sourceIndexPath.row...destinationIndexPath.row {
//                    let object = staffs[index]
//                    object.display_num -= 1
//                }
//            } else {
//                for index in (destinationIndexPath.row ..< sourceIndexPath.row).reversed() {
//                    let object = staffs[index]
//                    object.display_num += 1
//                }
//            }
//            sourceObject.display_num = destinationObjectOrder
//        }
//        onSwapData()
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        Utils.showAlert(message: "キーワード移動出来ません", view: self)
        return sourceIndexPath
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension OtherSettingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StampCollectCell", for: indexPath) as! StampCollectCell
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.configure(stamp: keywordsData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywordsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        keyIndex = indexPath.row
    }
}

//*****************************************************************
// MARK: - TextView Delegate
//*****************************************************************

extension OtherSettingVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        isModifying = true
        tblMemo.allowsSelection = false
    }
}

//*****************************************************************
// MARK: - KeywordsPopupVC Delegate
//*****************************************************************

extension OtherSettingVC : KeywordsPopupVCDelegate {
    func onComplete() {
        Utils.showAlert(message: MSG_ALERT.kALERT_ADD_KEYWORD_SUCCESS, view: self)
        self.keyIndex = nil
        self.loadData()
    }
}
