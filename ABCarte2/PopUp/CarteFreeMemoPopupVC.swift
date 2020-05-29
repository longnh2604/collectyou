//
//  CarteFreeMemoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/04/22.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol CarteFreeMemoPopupVCDelegate: class {
    func onDeleteMemo(status: Int,cellIndex: Int)
    func onSaveMemo(title: String,content: String,position: Int,cellIndex: Int)
    func onEditMemo(title: String,content: String,position: Int,cellIndex: Int, memoID: Int,update: Int)
}

class CarteFreeMemoPopupVC: UIViewController {

    //Variable
    var freeMemo = FreeMemoData()
    weak var delegate:CarteFreeMemoPopupVCDelegate?
    var cellIndex: Int?
    var position: Int?
    var isEdited: Bool = false
    //IBOutlet
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    @IBOutlet weak var btnDelete: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        tfTitle.text = freeMemo.title
        tvContent.text = freeMemo.content
    }

    @IBAction func onSave(_ sender: UIButton) {
        
        if tfTitle.text!.isEmpty {
            Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_TITLE, view: self)
            return
        }
        
        if tvContent.text!.isEmpty {
            Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_CONTENT, view: self)
            return
        }
        
        let check = Utils.checkLimitCharacter(number: self.tvContent.text.count,type: 4)
        if check.status == true {
            dismiss(animated: true) {
                
                if self.isEdited {
                    self.delegate?.onEditMemo(title: self.tfTitle.text!, content: self.tvContent.text, position: self.position!,cellIndex: self.cellIndex!,memoID: self.freeMemo.id,update: self.freeMemo.updated_at)
                } else {
                    self.delegate?.onSaveMemo(title: self.tfTitle.text!, content: self.tvContent.text, position: self.position!,cellIndex: self.cellIndex!)
                }
            }
        } else {
            Utils.showAlert(message: check.msg, view: self)
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        let alert = UIAlertController(title: "カルテメモ", message: MSG_ALERT.kALERT_CONFIRM_DELETE_MEMO_SELECTED, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler:{ (UIAlertAction) in
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            APIRequest.deleteCarteFreeMemo(memoID: self.freeMemo.id) { (success) in
                SVProgressHUD.dismiss()
                
                if success == 1 {
                    self.dismiss(animated: true, completion: {
                        self.delegate?.onDeleteMemo(status: 1,cellIndex: self.cellIndex!)
                    })
                } else if success == 2 {
                    self.dismiss(animated: true, completion: {
                        self.delegate?.onDeleteMemo(status: 2,cellIndex: self.cellIndex!)
                    })
                } else {
                    self.dismiss(animated: true, completion: {
                        self.delegate?.onDeleteMemo(status: 0,cellIndex: self.cellIndex!)
                    })
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "いいえ", style: .default, handler:{ (UIAlertAction) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
