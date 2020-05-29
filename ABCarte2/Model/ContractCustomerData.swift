//
//  ContractCustomerData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/02.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class ContractCustomerData: Object {
    dynamic var id: Int = 0
    dynamic var brochure_id: Int = 0
    dynamic var contract_date: Int = 0
    dynamic var last_name: String = ""
    dynamic var first_name: String = ""
    dynamic var last_name_kana: String = ""
    dynamic var first_name_kana: String = ""
    dynamic var birthday: Int = 0
    dynamic var customer_no: String = ""
    dynamic var zip: String = ""
    dynamic var country: String = ""
    dynamic var address1: String = ""
    dynamic var address2: String = ""
    dynamic var contract_url: String = ""
    dynamic var contract_signed_url: String = ""
    dynamic var tel: String = ""
    dynamic var emergency_tel: String = ""
    dynamic var job: String = ""
    dynamic var company_name: String = ""
    dynamic var company_zip: String = ""
    dynamic var company_city: String = ""
    dynamic var company_address1: String = ""
    dynamic var company_address2: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var contract_representative: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
