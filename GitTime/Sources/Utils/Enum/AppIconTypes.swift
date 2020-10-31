//
//  AppIconTypes.swift
//  GitTime
//
//  Created by Kanz on 2020/10/28.
//

import Foundation

enum AppIconTypes: String, CaseIterable {
	case black = "appicon_black"
	case white = "appicon_white"
	case original = "appicon_original"
	
	var imageName: String {
		self.rawValue
	}
	
	var title: String {
		switch self {
		case .black:
			return "Dark"
		case .white:
			return "White"
		case .original:
			return "Original"
		}
	}
	
	// Plist 에 구분된 identifier
	var plistIconName: String {
		switch self {
		case .black:
			return "AppIconDark"
		case .white:
			return "CFBundlePrimaryIcon"
		case .original:
			return "AppIconOriginal"
		}
	}
}
