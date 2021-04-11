//
//  UserDefaultsConfig.swift
//  GitTime
//
//  Created by Kanz on 2020/09/29.
//

struct UserDefaultsConfig {
	@UserDefaultsWrapper(Constants.UserDefaultKeys.firstLaunch.rawValue, defaultValue: true)
	static var firstLaunch: Bool
	
	@UserDefaultsWrapper(Constants.UserDefaultKeys.appIconName.rawValue, defaultValue: "CFBundlePrimaryIcon")
	static var appIconName: String
	
	@UserDefaultsWrapper(Constants.UserDefaultKeys.processCompletedCountKey.rawValue, defaultValue: 0)
	static var processCompletedCountKey: Int
	
	@UserDefaultsWrapper(Constants.UserDefaultKeys.lastVersionPromptedForReviewKey.rawValue, defaultValue: nil)
	static var lastVersionPromptedForReviewKey: String?
}
