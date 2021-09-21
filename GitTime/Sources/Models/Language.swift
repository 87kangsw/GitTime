//
//  Language.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct GithubLanguage: Codable, Equatable {
	let name: String
	let color: String
	
	init(name: String, color: String) {
		self.name = name
		self.color = color
	}
	
	static var allLanguage: GithubLanguage {
		return GithubLanguage(name: "All Languages",
							  color: "")
	}
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.name == rhs.name
	}
}

extension GithubLanguage {
	func toFavoriteLanguage() -> FavoriteLanguage {
		let favorite = FavoriteLanguage()
		favorite.name = self.name
		favorite.color = self.color
		return favorite
	}
}
