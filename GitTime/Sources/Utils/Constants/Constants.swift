//
//  Constants.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct AppConstants {
	static let gitTimeRepositoryURL = "https://github.com/87kangsw/GitTime"
	static let contactMailAddress = "contact@kanz.dev"
	static let contactMailTitle = "GitTime Feedback"
	static let appID = "1469013856"
	
	static let gitHubDomain = "https://github.com"
}

struct Constants {
	
	/// 키체인
	enum KeychainKeys: String {
		case serviceName = "com.5boon.TodayMood"
		case accessToken = "access_token"
		case tokenType = "token_type"
		case refreshToken = "refresh_token"
		case expired = "expired"
	}
	
	/// UserDefaultKey
	enum UserDefaultKeys: String {
		case firstLaunch = "firstLaunch"
		
		case selectedLanguage = "langauge"
		/*
		case langauge
		case period
		case firstLaunch
		case searchHistory
		*/
	}
}
