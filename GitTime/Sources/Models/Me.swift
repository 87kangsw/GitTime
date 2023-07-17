//
//  User.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct Me: ModelType {
    let id: Int
    let name: String
	let additionalName: String
    let profileURL: String
    let url: String
    let bio: String?
    let location: String?
    let publicRepos: Int?
    let privateRepos: Int?
    let followers: Int?
    let following: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "login"
		case additionalName = "name"
        case profileURL = "avatar_url"
        case url = "html_url"
        case bio
        case location
        case publicRepos = "public_repos"
        case privateRepos = "total_private_repos"
        case followers
        case following
    }
}
