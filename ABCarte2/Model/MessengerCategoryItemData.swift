//
//  MessengerCategoryItemData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/26.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class MessengerCategoryItemData: Object {
    dynamic var id: Int = 0
    dynamic var fc_messenger_category_id: Int = 0
    dynamic var title: String = ""
    dynamic var content: String = ""
    dynamic var status: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var created_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
