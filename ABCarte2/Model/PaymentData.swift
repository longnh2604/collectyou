//
//  CardData.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/03/03.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class PaymentData: Object,IsSubItem {
    dynamic var id: Int = 0
    dynamic var dbID: Int = 0
    dynamic var category_id: Int = 0
    dynamic var display_num: Int = 0
    dynamic var credit_company: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
