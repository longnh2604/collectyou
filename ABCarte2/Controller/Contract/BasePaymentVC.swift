//
//  BasePaymentVC.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/18.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class BasePaymentVC: UIViewController, UITextFieldDelegate {

    //Variable
    var settlementData = SettlementData()
    var index : Int?
    lazy var realm = try! Realm()
    let maxLength = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
