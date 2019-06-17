//
//  GitHubLoginAPI.swift
//  GitTime
//
//  Created by Kanz on 23/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya
import RxSwift

enum GitHubLoginAPI {
    case login(code: String)
}

extension GitHubLoginAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://github.com")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login/oauth/access_token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let code):
            let params: [String: Any] = [
                "client_id": GitHubInfoManager.clientID,
                "client_secret": GitHubInfoManager.clientSecret,
                "code": code
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }    
}
