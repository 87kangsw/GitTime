//
//  GitTimeCrawlerAPI.swift
//  GitTime
//
//  Created by Kanz on 14/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxSwift
import Moya

enum GitTimeCrawlerAPI {
    case trendingRepositories(language: String?, period: String?)
    case trendingDevelopers(language: String?, period: String?)
    case fetchContributions(userName: String)
}

extension GitTimeCrawlerAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://gittime-crawler.herokuapp.com")!
    }
    
    var path: String {
        switch self {
        case .trendingRepositories:
            return "/repositories"
        case .trendingDevelopers:
            return "/developers"
        case .fetchContributions(let userName):
            return "/contribution/\(userName)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .trendingRepositories(let language, let period):
            var params: [String: Any] = [:]
            if let language = language {
                params["language"] = language
            }
            if let period = period {
                params["since"] = period
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .trendingDevelopers(let language, let period):
            var params: [String: Any] = [:]
            if let language = language {
                params["language"] = language
            }
            if let period = period {
                params["since"] = period
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fetchContributions:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
