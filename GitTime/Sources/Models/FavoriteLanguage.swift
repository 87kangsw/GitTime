//
//  FavoriteLanguage.swift
//  GitTime
//
//  Created by Kanz on 2020/01/18.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import Realm
import RealmSwift

class FavoriteLanguage: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var color: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension FavoriteLanguage {
    func toLanguage() -> Language {
        return Language(id: self.id,
                        name: self.name,
                        type: self.type,
                        color: self.color)
    }
}
