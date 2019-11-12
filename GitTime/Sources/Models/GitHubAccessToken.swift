//
//  GitHubAccessToken.swift
//  GitTime
//
//  Created by Kanz on 23/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct GitHubAccessToken: ModelType {
    let accessToken: String
    let scope: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
        case tokenType = "token_type"
    }
}

extension GitHubAccessToken {
    static func devAccessToken() -> GitHubAccessToken {
        return GitHubAccessToken(accessToken: "d9709eca9a44bdd5cd9a8ddaa9cc1197930b8ddb",
                                 scope: "repo,user",
                                 tokenType: "bearer")
    }
}
