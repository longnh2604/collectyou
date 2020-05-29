//
//  BrochureData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/29.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class BrochureData: Object {
    dynamic var id: Int = 0
    dynamic var account_id: Int = 0
    dynamic var customer_id: Int = 0
    dynamic var user_name: String = ""
    dynamic var broch_serial_num: String = ""
    dynamic var cont_serial_num: String = ""
    dynamic var admission_fee: Int = 0
    dynamic var mship_start_date: Int = 0
    dynamic var mship_end_date: Int = 0
    dynamic var service_start_date: Int = 0
    dynamic var service_end_date: Int = 0
    dynamic var cours_total: Int = 0
    dynamic var goods_total: Int = 0
    dynamic var total: Int = 0
    dynamic var total_tax: Int = 0
    dynamic var agreement_date: Int = 0
    dynamic var signed1: String = ""
    dynamic var signed2: String = ""
    dynamic var company_profile: Int = 0
    dynamic var sub_company: Int = 0
    dynamic var advance_pay: Int = 0
    dynamic var used_item: String = ""
    dynamic var used_item2: String = ""
    dynamic var conserva: String = ""
    dynamic var contract_staff: String = ""
    dynamic var broch_create_date: Int = 0
    dynamic var cont_create_date: Int = 0
    dynamic var note1: String = ""
    dynamic var note2: String = ""
    dynamic var status: Int = 0
    dynamic var brochure_confirm: Int = 0
    dynamic var brochure_url: String = ""
    dynamic var brochure_signed_url: String = ""
    dynamic var contract_url: String = ""
    dynamic var contract_signed_url: String = ""
    dynamic var sum_notreat: Int = 0
    dynamic var sum_coursetime: Int = 0
    dynamic var sum_nogoods: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var select_date: Int = 0
    dynamic var broch_print_date: Int = 0
    dynamic var cont_print_date: Int = 0
    dynamic var brochure_confirm_signed_url: String = ""
    dynamic var contract_confirm_signed_url: String = ""
    dynamic var hand_over_date: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
