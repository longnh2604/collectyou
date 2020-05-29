//
//  TextInputPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/20.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol TextInputPopupVCDelegate: class {
    func onSaveText(text:String)
    func onCancel(text:String)
}

class TextInputPopupVC: UIViewController,UITextViewDelegate {

    //IBOutlet
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    
    //Variable
    weak var delegate:TextInputPopupVCDelegate?
    var previousText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    func setupLayout() {
        tvContent.becomeFirstResponder()
        tvContent.textContainer.maximumNumberOfLines = 5
        tvContent.delegate = self
        
        if let text = previousText {
            tvContent.text = text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxAllowedCharactersPerLine = 10
        let lines = (textView.text as NSString).replacingCharacters(in: range, with: text).components(separatedBy: .newlines)
        for line in lines {
            if line.count > maxAllowedCharactersPerLine {
                return false
            }
        }
        return true
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.onSaveText(text:self.tvContent.text)
            self.previousText = nil
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true) {
            guard let text = self.previousText else { return }
            self.delegate?.onCancel(text: text)
            self.previousText = nil
        }
    }
}
