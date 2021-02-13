//
//  MeFixture.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/10/25.
//

import Foundation
@testable import GitTime

struct MeFixture {
	static let kanz: Me = fixture([
		"id" : 1,
		"login" : "87kangsw",
		"avatar_url" : "https://avatars1.githubusercontent.com/u/6590255?v=4",
		"html_url" : "https://github.com/87kangsw",
		"bio" : "어제보다 나은 코드를 위해 💻",
		"location" : "Seoul, Korea",
		"public_repos" : 24,
		"total_private_repos" : 23,
		"following" : 55,
		"followers" : 20
	])
}
