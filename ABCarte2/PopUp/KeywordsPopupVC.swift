//
//  KeywordsPopupVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/04/02.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit

protocol KeywordsPopupVCDelegate: class {
    func onComplete()
}

class KeywordsPopupVC: UIViewController {

    //Variable
    var categoryID: Int?
    var keyword = StampKeywordData()
    weak var delegate:KeywordsPopupVCDelegate?
    
    //IBOutlet
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var lblTextCount: UILabel!
    @IBOutlet weak var onSave: UIButton!
    @IBOutlet weak var onCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadData()
    }
    
    private func setupLayout() {
        tvContent.layer.cornerRadius = 5
        tvContent.layer.borderWidth = 2
        tvContent.layer.borderColor = UIColor.black.cgColor
        tvContent.delegate = self
        tvContent.smartInsertDeleteType = UITextSmartInsertDeleteType.no
    }
    
    private func loadData() {
        if keyword.content != "" {
            tvContent.text = keyword.content
            lblTextCount.text = "\(tvContent.text.count)/50"
        }
    }

    @IBAction func onSave(_ sender: UIButton) {
        guard let categoryID = categoryID else { return }
        if keyword.content != "" {
            APIRequest.onEditKeyword(keywordID: keyword.id, content: tvContent.text, completion: { (success) in
                if success {
                    self.dismiss(animated: true) {
                        self.delegate?.onComplete()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_KEYWORD, view: self)
                }
            })
        } else {
            APIRequest.onAddKeywords(categoryID: categoryID, content: tvContent.text, completion: { (success) in
                if success {
                    self.dismiss(animated: true) {
                        self.delegate?.onComplete()
                    }
                } else {
                    Utils.showAlert(message: MSG_ALERT.kALERT_CANT_SAVE_KEYWORD, view: self)
                }
            })
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension KeywordsPopupVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        lblTextCount.text = "\(textView.text.count)/50"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let rangeOfTextToReplace = Range(range, in: textView.text) else {
            return false
        }
        let substringToReplace = textView.text[rangeOfTextToReplace]
        let count = textView.text.count - substringToReplace.count + text.count
        return count <= 50
    }
}
