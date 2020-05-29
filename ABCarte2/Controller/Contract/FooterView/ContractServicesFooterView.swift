//
//  ContractServicesFooterView.swift
//  ABCarte2
//
//  Created by Long on 2019/10/07.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class ContractServicesFooterView: UITableViewHeaderFooterView {

    //IBOutlet
    @IBOutlet weak var tfNoTreat: UILabel!
    @IBOutlet weak var tfTotalTime: RoundLabel!
    @IBOutlet weak var tfSubTotal: UILabel!

    static var ContractServicesFooterViewIdentifier = "ContractServicesFooterView"
    
    override func awakeFromNib(){
         super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
