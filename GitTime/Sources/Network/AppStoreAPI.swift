//
//  AppStoreAPI.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya
import RxSwift

enum AppStoreAPI {
    case lookUp(bundleID: String)
}

extension AppStoreAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
    }
    
    var path: String {
        switch self {
        case .lookUp:
            return "lookup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .lookUp:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .lookUp(let bundleID):
            let param = [
                "bundleId": bundleID
            ]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
