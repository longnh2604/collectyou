//
//  SettlementData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/30.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class SettlementData: Object {
    dynamic var id: Int = 0
    dynamic var brochure_id: Int = 0
    dynamic var display_num: Int = 0
    dynamic var settlement_type: String = ""
    dynamic var institution_name: String = ""
    dynamic var pay_type: String = ""
    dynamic var settlement_date: Int = 0
    dynamic var settlement_price: Int = 0
    dynamic var settlement_count: Int = 0
    dynamic var monthly_set_date: Int = 0
    dynamic var monthly_set_price: Int = 0
    dynamic var adjust_set_date: Int = 0
    dynamic var adjust_set_price: Int = 0
    dynamic var bonus_pay1: Int = 0
    dynamic var bonus_date1: Int = 0
    dynamic var bonus_pay2: Int = 0
    dynamic var bonus_date2: Int = 0
    dynamic var note: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var index: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
