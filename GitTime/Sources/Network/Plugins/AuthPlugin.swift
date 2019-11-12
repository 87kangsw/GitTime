//
//  AuthPlugin.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya

struct AuthPlugin: PluginType {
    
    fileprivate let keychainService: KeychainServiceType
    
    init(keychainService: KeychainServiceType) {
        self.keychainService = keychainService
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let accessToken = keychainService.getAccessToken() {
            // log.debug("Bearer Token: \(accessToken)")
            request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
