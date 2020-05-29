//
//  ProductCategoryData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/30.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class ProductCategoryData: Object,IsCategory {
    dynamic var id: Int = 0
    dynamic var account_id: Int = 0
    dynamic var display_num: Int = 0
    dynamic var category_name: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
