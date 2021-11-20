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
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
	
	override class func primaryKey() -> String? {
		return "name"
	}
}

extension FavoriteLanguage {
	func toLanguage() -> GithubLanguage {
		return GithubLanguage(name: self.name,
							  color: self.color)
	}
}
