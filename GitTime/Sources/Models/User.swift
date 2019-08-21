//
//  FollowUser.swift
//  GitTime
//
//  Created by Kanz on 04/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import RxDataSources

enum UserType: String {
    case organization = "Organization"
    case user = "User"
}

struct User: ModelType {
    let id: Int
    let name: String
    let profileURL: String
    let url: String
    let followersURL: String
    let followingURL: String
    let type: UserType
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "login"
        case profileURL = "avatar_url"
        case url = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profileURL = try container.decode(String.self, forKey: .profileURL)
        url = try container.decode(String.self, forKey: .url)
        followersURL = try container.decode(String.self, forKey: .followersURL)
        followingURL = try container.decode(String.self, forKey: .followingURL)
        type = UserType(rawValue: try container.decode(String.self, forKey: .type)) ?? .user
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(profileURL, forKey: .profileURL)
        try container.encode(url, forKey: .url)
        try container.encode(followersURL, forKey: .followersURL)
        try container.encode(followingURL, forKey: .followingURL)
        try container.encode(type.rawValue, forKey: .type)
    }
}

extension User {
    static func mockData() -> [User]? {
        if let url = Bundle.main.url(forResource: "followMock", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let mocks = try decoder.decode([User].self, from: data)
                return mocks
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}
