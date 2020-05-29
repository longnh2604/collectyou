//
//  JobCategoryData.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/05/11.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class JobCategoryData: Object,IsCategory {
    dynamic var id: Int = 0
    dynamic var fc_account_id: Int = 0
    dynamic var status: Int = 0
    dynamic var display_num: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
