//
//  FreeMemoData.swift
//  ABCarte2
//
//  Created by Long on 2018/10/10.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class FreeMemoData: Object {
    //Variable
    dynamic var id: Int = 0
    dynamic var memo_id: String = ""
    dynamic var fc_customer_carte_id: Int = 0
    dynamic var fc_customer_carte_carte_id: String = ""
    dynamic var title: String = ""
    dynamic var position: Int = 0
    dynamic var content: String = ""
    dynamic var date: Int = 0
    dynamic var type: Int = 0
    dynamic var fc_customer_id: Int = 0
    dynamic var fc_account_id: Int = 0
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
