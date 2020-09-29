//
//  UserDefaultsConfig.swift
//  GitTime
//
//  Created by Kanz on 2020/09/29.
//

struct UserDefaultsConfig {
	@UserDefaultsWrapper(Constants.UserDefaultKeys.firstLaunch.rawValue, defaultValue: true)
	static var firstLaunch: Bool
}
