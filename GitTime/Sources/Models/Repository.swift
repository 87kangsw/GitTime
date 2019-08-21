//
//  Repository.swift
//  GitTime
//
//  Created by Kanz on 11/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct Repository: ModelType {
    let id: Int
    let owner: User
    let name: String
    let url: String
    let description: String?
    let language: String?
    var languageColor: String?
    let forkCount: Int
    let starCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case url = "html_url"
        case description
        case language
        case forkCount = "forks_count"
        case starCount = "stargazers_count"
    }
    
}
