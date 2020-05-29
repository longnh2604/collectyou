//
//  ProductData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/30.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class ProductData: Object,IsSubItem {
    dynamic var id: Int = 0
    dynamic var category_id: Int = 0
    dynamic var display_num: Int = 0
    dynamic var item_name: String = ""
    dynamic var item_category: String = ""
    dynamic var unit_price: Int = 0
    dynamic var fee_rate: Int = 0
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
