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
