//
//  GitTimeCrawlerAPI.swift
//  GitTime
//
//  Created by Kanz on 14/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import Moya
import RxMoya
import RxSwift

enum GitTimeCrawlerAPI {
    case trendingRepositories(language: String?, period: String?, spokenLanguage: String?)
    case trendingDevelopers(language: String?, period: String?)
    case fetchContributions(userName: String, darkMode: Bool)
    
    case trendingRepositoriesRawdata(language: String?, period: String?)
    case tredingDevelopersRawdata(language: String?, period: String?)
    case fetchContributionsRawdata(userName: String, darkMode: Bool)
}

extension GitTimeCrawlerAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .trendingRepositoriesRawdata:
            return URL(string: "https://github.com")!
        case .tredingDevelopersRawdata:
            return URL(string: "https://github.com")!
        case .fetchContributionsRawdata:
            return URL(string: "https://github.com")!
        default:
            return URL(string: "https://gittime-crawler.herokuapp.com")!
        }
        
    }
    
    var path: String {
        switch self {
        case .trendingRepositories:
            return "/repositories"
        case .trendingDevelopers:
            return "/developers"
        case let .fetchContributions(userName, _):
            return "/contribution/\(userName)"
        case .tredingDevelopersRawdata:
            return "/trending/developers"
        case .trendingRepositoriesRawdata:
            return "/trending"
        case let .fetchContributionsRawdata(userName, _):
            return "/\(userName)"
            
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
        case .trendingRepositories(let language, let period, let spokenLanguage):
            var params: [String: Any] = [:]
            if let language = language {
                params["language"] = language
            }
            if let period = period {
                params["since"] = period
            }
			if let spokenLanguage = spokenLanguage {
				params["spoken_language_code"] = spokenLanguage
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
        case .fetchContributions(_, let darkMode):
            var params: [String: Any] = [:]
            params["darkMode"] = darkMode
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case let .trendingRepositoriesRawdata(language, period):
            var params: [String: Any] = [:]
            if let language = language, !language.isEmpty {
                params["language"] = language
            }
            if let period = period, !period.isEmpty {
                params["since"] = period
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case let .tredingDevelopersRawdata(language, period):
            var params: [String: Any] = [:]
            
            if let language = language, !language.isEmpty {
                params["language"] = language
            }
            if let period = period, !period.isEmpty {
                params["since"] = period
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fetchContributionsRawdata:
            let params: [String: Any] = [:]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
