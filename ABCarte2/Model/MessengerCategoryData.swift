//
//  MessengerCategoryData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/26.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class MessengerCategoryData: Object {
    dynamic var id: Int = 0
    dynamic var fc_account_id: Int = 0
    dynamic var category_name: String = ""
    dynamic var status: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var created_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
