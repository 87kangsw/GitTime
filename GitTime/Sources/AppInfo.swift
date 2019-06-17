//
//  AppInfo.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum AppInfoKey {
    static let CFBundleURLTypes = "CFBundleURLTypes"
    static let CFBundleURLName = "CFBundleURLName"
    static let CFBundleURLSchemes = "CFBundleURLSchemes"
    static let CFBundleShortVersionString = "CFBundleShortVersionString"
}

final class AppInfo {
    
    static let shared = AppInfo()
    
    var infoDictionary: [String: Any] {
        return Bundle.main.infoDictionary!
    }
    
    var urlTypes: [[String: Any]] {
        guard let urlTypes = infoDictionary[AppInfoKey.CFBundleURLTypes] as? [[String: Any]] else { return [] }
        return urlTypes
    }
    
    var appVersion: String {
        guard let versionString = infoDictionary[AppInfoKey.CFBundleShortVersionString] as? String else { return "" }
        return versionString
    }
    
    var bundleID: String? {
        guard let bundleID = Bundle.main.bundleIdentifier else { return nil }
        return bundleID
    }
}
