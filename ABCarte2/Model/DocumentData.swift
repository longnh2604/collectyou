//
//  DocumentData.swift
//  ABCarte2
//
//  Created by Long on 2018/11/21.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class DocumentData: Object {
    dynamic var id: Int = 0
    dynamic var type: Int = 0
    dynamic var sub_type: Int = 0
    dynamic var title: String = ""
    dynamic var fc_account_id: Int = 0
    dynamic var fc_customer_carte_id: Int = 0
    dynamic var status: Int = 0
    dynamic var created_at: Int = 0
    dynamic var updated_at: Int = 0
    dynamic var is_template: Int = 0
    dynamic var document_no: String = ""
    
    var document_pages = List<DocumentPageData>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
