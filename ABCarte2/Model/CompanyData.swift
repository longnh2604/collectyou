//
//  CompanyData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/01.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class CompanyData: Object,IsCategory {
    dynamic var id: Int = 0
    dynamic var account_id: Int = 0
    dynamic var company_name: String = ""
    dynamic var president_name: String = ""
    dynamic var zip: String = ""
    dynamic var address1: String = ""
    dynamic var address2: String = ""
    dynamic var tel: String = ""
    dynamic var stamp: String = ""
    dynamic var status: Int = 0
    dynamic var display_num: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
