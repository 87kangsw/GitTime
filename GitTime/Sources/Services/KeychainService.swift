//
//  KeychainService.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import KeychainAccess

enum KeychainKey {
    static let accessToken = "accessToken"
}

protocol KeychainServiceType: AnyObject {
    func getAccessToken() -> String?
    func setAccessToken(_ token: String) throws
    func removeAccessToken() throws
}

final class KeychainService: KeychainServiceType {
    
    private var keychain: Keychain {
        return Keychain(service: "io.github.87kangsw.GitTime")
    }
    
    func getAccessToken() -> String? {
        guard let token = self.keychain[KeychainKey.accessToken] else {
            return nil
        }
        return token
    }
    
    func setAccessToken(_ token: String) throws {
        try self.keychain.set(token, key: KeychainKey.accessToken)
    }
    
    func removeAccessToken() throws {
        try self.keychain.remove(KeychainKey.accessToken)
    }
}
