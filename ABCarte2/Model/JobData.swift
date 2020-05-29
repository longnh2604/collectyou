//
//  JobData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/01.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class JobData: Object,IsSubItem {
    dynamic var id: Int = 0
    dynamic var account_id: Int = 0
    dynamic var display_num: Int = 0
    dynamic var job: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
