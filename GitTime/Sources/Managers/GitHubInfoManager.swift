//
//  GitHubAccessManager.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

enum GitHubInfoKeys {
    static let clientID = "clientID"
    static let clientSecret = "clientSecret"
    static let callbackURLScheme = "callbackURLScheme"
}

final class GitHubInfoManager {
    
    static let shared = GitHubInfoManager()
    
    class var clientID: String {
        guard let id = shared.info[GitHubInfoKeys.clientID] else { fatalError("GitHub-Info Plist error") }
        return id
    }
    
    class var clientSecret: String {
        guard let secret = shared.info[GitHubInfoKeys.clientSecret] else { fatalError("GitHub-Info Plist error") }
        return secret
    }
    
    class var callbackURLScheme: String {
        guard let scheme = shared.info[GitHubInfoKeys.callbackURLScheme] else { fatalError("GitHub-Info Plist error") }
        return scheme
    }
    
    private var info: [String: String] {
        guard let plistPath = Bundle.main.path(forResource: "GitHub-Info", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: plistPath) as? [String: String] else {
                return [:]
        }
        return plist
    }
}
