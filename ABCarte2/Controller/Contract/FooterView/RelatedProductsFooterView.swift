//
//  RelatedProductsFooterView.swift
//  ABCarte2
//
//  Created by Long on 2019/10/08.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class RelatedProductsFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var tfNoProduct: RoundLabel!
    @IBOutlet weak var tfSubTotal: RoundLabel!
    @IBOutlet weak var tfTax: RoundLabel!
    @IBOutlet weak var tfTotal: RoundLabel!
    
    static var RelatedProductsFooterViewIdentifier = "RelatedProductsFooterView"
    
    override func awakeFromNib(){
         super.awakeFromNib()
         
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
