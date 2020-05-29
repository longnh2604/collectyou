//
//  SentPhoto.swift
//  ABCarte2
//
//  Created by Long on 2019/08/20.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class SentPhoto: Object {
    dynamic var date = Date()
    var medias = List<String>()
}
