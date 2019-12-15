//
//  TrendDeveloper.swift
//  GitTime
//
//  Created by Kanz on 17/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct TrendDeveloper: ModelType {
    var userName: String
    var name: String?
    var url: String
    var profileURL: String
    var repo: TrendDeveloperRepo
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case name
        case url
        case profileURL = "avatar"
        case repo
    }
    
    init(userName: String,
         name: String?,
         url: String,
         profileURL: String,
         repo: TrendDeveloperRepo) {
        
        self.userName = userName
        self.name = name
        self.url = url
        self.profileURL = profileURL
        self.repo = repo
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        name = try? container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        profileURL = try container.decode(String.self, forKey: .profileURL)
        repo = try container.decode(TrendDeveloperRepo.self, forKey: .repo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(profileURL, forKey: .profileURL)
        try container.encode(repo, forKey: .repo)
    }
}

struct TrendDeveloperRepo: ModelType {
    var name: String?
    var url: String
    var description: String
}
