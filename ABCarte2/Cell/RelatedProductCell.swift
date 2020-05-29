//
//  RelatedProductCell.swift
//  ABCarte2
//
//  Created by Long on 2019/10/08.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol RelatedProductCellDelegate: class {
    func onRelatedTapped(index:Int)
    func onBeginInputRelatedProduct()
    func onQuantityValueChange(value:Int,index:Int)
}

class RelatedProductCell: UITableViewCell, UITextFieldDelegate {

    //Variable
    weak var delegate: RelatedProductCellDelegate?
    let maxLength = 5
    
    //IBOutlet
    @IBOutlet weak var tfOrder: UITextField!
    @IBOutlet weak var btnProduct: RoundButton!
    @IBOutlet weak var tfProductCategory: UITextField!
    @IBOutlet weak var tfProductUPrice: UITextField!
    @IBOutlet weak var tfNoProduct: UITextField!
    @IBOutlet weak var tfProductSubTotal: UITextField!
    @IBOutlet weak var tfProductTax: UITextField!
    @IBOutlet weak var tfProductTotal: UITextField!
    
    deinit {
        print("Memory release")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        btnProduct.setTitle("商品選択", for: .normal)
        tfProductCategory.text = ""
        tfProductUPrice.text = "¥0"
        tfProductSubTotal.text = "0"
        tfNoProduct.text = ""
        tfNoProduct.placeholder = "手入力"
        tfProductTax.text = "0"
        tfProductTotal.text = "0"
    }
    
    func configure(index:Int) {
        btnProduct.tag = index
        let no = index + 1
        
        if tfOrder.text!.isEmpty {
            tfOrder.text = "\(no)"
        }
        
        if tfProductUPrice.text!.isEmpty {
            tfProductUPrice.text = "¥0"
        } else {
            tfProductUPrice.text = tfProductUPrice.text?.trimmingCharacters(in: ["¥"]).replacingOccurrences(of: ",", with: "").addFormatAmount()
        }
        
        if tfProductSubTotal.text!.isEmpty {
            tfProductSubTotal.text = "0"
        }
        
        if tfProductTax.text!.isEmpty {
            tfProductTax.text = "0"
        }
        
        if tfProductTotal.text!.isEmpty {
            tfProductTotal.text = "0"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil && newString.length <= maxLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "0"
        }
    }
    
    @IBAction func onBeginInputRelatedProduct(_ sender: UITextField) {
        delegate?.onBeginInputRelatedProduct()
    }
    
    @IBAction func onRelatedProductSelect(_ sender: UIButton) {
        delegate?.onRelatedTapped(index:sender.tag)
    }
    
    @IBAction func onQuantityChange(_ sender: UITextField) {
        if var text = sender.text {
            if text == "" {
                text = "0"
            }
            delegate?.onQuantityValueChange(value: Int(text)!, index: btnProduct.tag)
        }
    }
}
