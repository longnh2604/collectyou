//
//  CourseOrderData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/10/30.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class CourseOrderData: Object {
    dynamic var id: Int = 0
    dynamic var brochure_id: Int = 0
    dynamic var course_name: String = ""
    dynamic var treatment_time: Int = 0
    dynamic var unit_price: Int = 0
    dynamic var num_of_treat: Int = 0
    dynamic var total_time: Int = 0
    dynamic var sub_total: Int = 0
    dynamic var note: String = ""
    dynamic var status: Int = 0
    dynamic var index: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
