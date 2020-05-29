//
//  AdditionNoteData.swift
//  ABCarte2
//
//  Created by Oluxe on 2019/11/01.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class AdditionNoteData: Object {
    dynamic var id: Int = 0
    dynamic var account_id: Int = 0
    dynamic var advance_pay: Int = 0
    dynamic var used_item: String = ""
    dynamic var used_item2: String = ""
    dynamic var conserva: String = ""
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
