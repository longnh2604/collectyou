//
//  CourseData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/29.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class CourseData: Object,IsSubItem {
    dynamic var id: Int = 0
    dynamic var category_id: Int = 0
    dynamic var display_num: Int = 0
    dynamic var course_name: String = ""
    dynamic var treatment_time: Int = 0
    dynamic var unit_price: Int = 0
    dynamic var fee_rate: Int = 0
    dynamic var requir_items: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var products = List<ProductData>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
