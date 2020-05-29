//
//  AccTreeData.swift
//  ABCarte2
//
//  Created by long nguyen on 5/6/19.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class AccTreeData: Object {
    dynamic var id: Int = 0
    dynamic var acc_name: String = ""
    dynamic var account_id: String = ""
    var children = List<AccTreeData>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
