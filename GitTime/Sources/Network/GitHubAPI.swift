//
//  GitHubAPI.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya
import RxSwift

enum GitHubAPI {
    case fetchMe
    case activityEvent(userName: String, page: Int)
    case followers(userName: String, page: Int)
    case following(userName: String, page: Int)
    case searchUser(query: String, page: Int)
    case searchRepo(query: String, page: Int)
}

extension GitHubAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .fetchMe:
            return "user"
        case .activityEvent(let userName, _):
            return "/users/\(userName)/received_events"
        case .followers(let userName, _):
            return "/users/\(userName)/followers"
        case .following(let userName, _):
            return "/users/\(userName)/following"
        case .searchUser:
            return "/search/users"
        case .searchRepo:
            return "/search/repositories"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMe, .activityEvent, .followers, .following, .searchUser, .searchRepo:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .followers(_, page), let .following(_, page):
            let params: [String: Any] = [
                "per_page": 10,
                "page": page
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .activityEvent(_, page):
            let params: [String: Any] = [
                "per_page": 30,
                "page": page
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .searchUser(query, page),
             let .searchRepo(query, page):
            let params: [String: Any] = [
                "q": query,
                "page": page
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
}
