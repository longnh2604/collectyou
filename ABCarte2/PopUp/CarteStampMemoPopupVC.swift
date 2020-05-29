//
//  CarteStampMemoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/04/23.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol CarteStampMemoPopupVCDelegate: class {
    func onCloseStampMemo(cellIndex:Int)
}

class CarteStampMemoPopupVC: UIViewController {

    //Variable
    var stampMemo = StampMemoData()
    weak var delegate:CarteStampMemoPopupVCDelegate?
    var cellIndex: Int?
    var position: Int?
    var isEdited: Bool = false
    
    var categories: Results<StampCategoryData>!
    var keywords: Results<StampKeywordData>!
    var keywordsData : [StampKeywordData] = []
    
    var idContent: [Int] = []
    
    //IBOutlet
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var tblKeywords: UITableView!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    @IBOutlet weak var btnDelete: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    fileprivate func setupLayout() {
        tfTitle.text = categories![position! - 1].title
        
        tblKeywords.delegate = self
        tblKeywords.dataSource = self
        let nib = UINib(nibName: "StampCell", bundle: nil)
        tblKeywords.register(nib, forCellReuseIdentifier: "StampCell")
        
        getKeywords()
    }
    
    fileprivate func getKeywords() {
        convertIdContentToKeywords()
        
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(realm.objects(StampKeywordData.self))
//        }
//
//        APIRequest.onGetKeyFromCategory(categoryID: categories![position! - 1].id,page: nil, completion: { (success) in
//            if success {
//
//                let realm = RealmServices.shared.realm
//                self.keywords = realm.objects(StampKeywordData.self)
//
//                self.keywordsData.removeAll()
//
//                for i in 0 ..< self.keywords.count {
//                    self.keywordsData.append(self.keywords[i])
//                }
//
//                self.convertIdContentToKeywords()
//                self.tblKeywords.reloadData()
//            } else {
//                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK, view: self)
//            }
//        })
    }
    
    fileprivate func convertIdContentToKeywords() {
        
        let idContentStr = stampMemo.content.components(separatedBy: ",")
        idContent = idContentStr.compactMap { Int($0) }

        tvContent.text.removeAll()
        
        for i in 0 ..< idContent.count {
            for j in 0 ..< keywordsData.count {
                if keywordsData[j].id == idContent[i] {
                    if tvContent.text.isEmpty {
                        tvContent.text.append("・\(keywordsData[j].content)")
                    } else {
                        tvContent.text.append("\n・\(keywordsData[j].content)")
                    }
                }
            }
        }
    }

    @IBAction func onSave(_ sender: UIButton) {
        var str = ""
        for i in 0 ..< self.idContent.count {
            if str == "" {
                str.append("\(self.idContent[i])")
            } else {
                str.append(",\(self.idContent[i])")
            }
        }
        
        APIRequest.onCheckCarteStampMemoData(memoID: stampMemo.id, update: stampMemo.updated_at) { (status) in
            if status == 1 {
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                APIRequest.editCarteStampMemo(stampID: self.stampMemo.id, content: str) { (success,stampData) in
                    if success {
                        self.dismiss(animated: true) {
                            self.delegate?.onCloseStampMemo(cellIndex: self.cellIndex!)
                        }
                    } else {
                        Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            } else if status == 2 {
                let alert = UIAlertController(title: "サーバから更新されたメモがございますのでリフレッシュしましょうか？", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    SVProgressHUD.show(withStatus: "読み込み中")
                    SVProgressHUD.setDefaultMaskType(.clear)
                    APIRequest.onViewStampMemo(memoID: self.stampMemo.id, completion: { (success,stampData) in
                        if success {
                            self.stampMemo = stampData
                            self.convertIdContentToKeywords()
                            self.tblKeywords.reloadData()
                            
                            if self.isEdited == true {
                                self.isEdited = false
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    })
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        if isEdited == true {
            let alert = UIAlertController(title: "カルテメモ", message: MSG_ALERT.kALERT_SAVE_MEMO_NOTIFICATION, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler:{ (UIAlertAction) in
                self.dismiss(animated: true) {
                    self.delegate?.onCloseStampMemo(cellIndex: self.cellIndex!)
                }
            }))
            alert.addAction(UIAlertAction(title: "いいえ", style: .default, handler:{ (UIAlertAction) in
                //do nothing
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true) {
                self.delegate?.onCloseStampMemo(cellIndex: self.cellIndex!)
            }
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        let alert = UIAlertController(title: "カルテメモ", message: MSG_ALERT.kALERT_CONFIRM_DELETE_MEMO_SELECTED, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler:{ (UIAlertAction) in
        
            APIRequest.onCheckCarteStampMemoData(memoID: self.stampMemo.id, update: self.stampMemo.updated_at) { (status) in
                if status == 1 {
                    SVProgressHUD.show(withStatus: "読み込み中")
                    SVProgressHUD.setDefaultMaskType(.clear)
                    
                    APIRequest.editCarteStampMemo(stampID: self.stampMemo.id, content: "") { (success,stampData) in
                        if success {
                            self.dismiss(animated: true) {
                                self.delegate?.onCloseStampMemo(cellIndex: self.cellIndex!)
                            }
                        } else {
                            Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else if status == 2 {
                    self.showNewDataFromServerPopup()
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "いいえ", style: .default, handler:{ (UIAlertAction) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNewDataFromServerPopup() {
        let alert = UIAlertController(title: "サーバから更新されたメモがございますのでリフレッシュしましょうか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            APIRequest.onViewStampMemo(memoID: self.stampMemo.id, completion: { (success,stampData) in
                if success {
                    self.stampMemo = stampData
                    self.convertIdContentToKeywords()
                    self.tblKeywords.reloadData()
                    
                    if self.isEdited == true {
                        self.isEdited = false
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
                SVProgressHUD.dismiss()
            })
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CarteStampMemoPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywordsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StampCell") as? StampCell else
        { return UITableViewCell() }
        
        cell.selectionStyle = .none
        
        if idContent.contains(keywordsData[indexPath.row].id) {
            cell.selectedCell = true
        } else {
            cell.selectedCell = false
        }
        cell.configure(title: keywordsData[indexPath.row].content)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? StampCell else { return }
        
        if idContent.contains(self.keywordsData[indexPath.row].id) {
            idContent = idContent.filter({ $0 != keywordsData[indexPath.row].id })
            cell.selectedCell = false
        } else {
            idContent.append(self.keywordsData[indexPath.row].id)
            cell.selectedCell = true
        }
        cell.update()
        showNewContentByIndex()
        
        if isEdited == false {
            isEdited = true
        }
    }
    
    func showNewContentByIndex() {
        tvContent.text.removeAll()

        for i in 0 ..< idContent.count {
            for j in 0 ..< keywordsData.count {
                if keywordsData[j].id == idContent[i] {
                    if tvContent.text.isEmpty {
                        tvContent.text.append("・\(keywordsData[j].content)")
                    } else {
                        tvContent.text.append("\n・\(keywordsData[j].content)")
                    }
                }
            }
        }
    }
}
