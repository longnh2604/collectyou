//
//  VideoData.swift
//  ABCarte2
//
//  Created by Long on 2019/05/09.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class VideoData: Object {
    dynamic var id: Int = 0
    dynamic var application_id: Int = 0
    dynamic var desc: String = ""
    dynamic var is_premium: Int = 0
    dynamic var last_updated: Int = 0
    dynamic var status: Int = 0
    dynamic var tags: String = ""
    dynamic var title: String = ""
    dynamic var uploaded_at: Int = 0
    dynamic var url: String = ""
    dynamic var video_duration: Int = 0
    dynamic var thumbnail : String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
