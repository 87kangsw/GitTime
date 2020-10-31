//
//  Constants.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct AppConstants {
	static let contactMailAddress = "contact@kanz.dev"
	static let contactMailTitle = "GitTime Feedback"
	static let appID = "1469013856"
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
		case selectedPeriod = "period"
		case searchHistory
		case appIconName
	}
	
	enum URLs {
		static let gitHubDomain = "https://github.com"
		static let gitTimeRepositoryURL = "https://github.com/87kangsw/GitTime"
		static let privacyURL = "http://bit.ly/2VyWrTW"
		static let twitterURL = "https://twitter.com/87kangsw"
		static let appStoreURL = "https://apps.apple.com/app/gittime/id1469013856"
	}
	
	enum Schemes {
		static let twitter = "twitter://user?screen_name=87kangsw"
	}
}
