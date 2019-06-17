//
//  UserDefaultsService.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case langauge
    case period
    case firstLaunch
}

protocol UserDefaultsServiceType {
    func value<T>(forKey key: UserDefaultsKey) -> T?
    func set<T>(value: T?, forKey key: UserDefaultsKey)
}

final class UserDefaultsService: UserDefaultsServiceType {
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func value<T>(forKey key: UserDefaultsKey) -> T? {
        return self.defaults.value(forKey: key.rawValue) as? T
    }
    
    func set<T>(value: T?, forKey key: UserDefaultsKey) {
        self.defaults.set(value, forKey: key.rawValue)
        self.defaults.synchronize()
    }
}
