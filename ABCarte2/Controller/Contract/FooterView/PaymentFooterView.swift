//
//  PaymentFooterView.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/17.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class PaymentFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var tfTotal: RoundLabel!
    static var PaymentFooterViewIdentifier = "PaymentFooterView"
    
    override func awakeFromNib() {
         super.awakeFromNib()
         
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
