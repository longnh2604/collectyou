//
//  CustomerMemoPopup.swift
//  ABCarte2
//
//  Created by Long on 2019/10/11.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol CustomerMemoPopupDelegate: class {
    func onCustomerMemoPopupSearch(content:String,type:Int)
}

class CustomerMemoPopup: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvContent: UITextView!
    
    //Variable
    weak var delegate:CustomerMemoPopupDelegate?
    var type:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    fileprivate func setupLayout() {
        if type == 1 {
            lblTitle.text = "お客様シークレットメモ検索"
        } else if type == 2 {
            lblTitle.text = "お客様フリーメモ検索"
        }
    }

    @IBAction func onSearch(_ sender: UIButton) {
        if tvContent.text.isEmpty {
            Utils.showAlert(message: MSG_ALERT.kALERT_INPUT_DATA, view: self)
            return
        }
        
        dismiss(animated: true) {
            if let type = self.type {
                self.delegate?.onCustomerMemoPopupSearch(content: self.tvContent.text,type:type)
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
