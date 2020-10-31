//
//  SettingMenuTypes.swift
//  GitTime
//
//  Created by Kanz on 2020/10/26.
//

import Foundation

enum SettingMenuTypes: CaseIterable {
	case appIcon
	
	case repo
	case opensource
	case recommend
	case appReview
	
	case terms
	case privacy
	
	case author
	case contributors
	case shareFeedback
	
	case logout
	
	var menuTitle: String {
		switch self {
		case .appIcon:
			return "App Icon"
		case .repo:
			return "GitTime Repository"
		case .opensource:
			return "Open Source"
		case .recommend:
			return "Recommend App"
		case .appReview:
			return "Rate GitTime"
		case .terms:
			return "Terms of Service"
		case .privacy:
			return "Privacy Policy"
		case .author:
			return "Author"
		case .contributors:
			return "Contributors"
		case .shareFeedback:
			return "Share Feedback"
		case .logout:
			return "Logout"
		}
	}
	
}
