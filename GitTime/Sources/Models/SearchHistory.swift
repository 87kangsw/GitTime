//
//  SearchHistory.swift
//  GitTime
//
//  Created by Kanz on 04/10/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Realm
import RealmSwift

class SearchHistory: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    override class func primaryKey() -> String? {
        return "text"
    }
}
