//
//  BundleInfoConfig.swift
//  GitTime
//
//  Created by Kanz on 2021/04/11.
//

import Foundation

struct BundleInfoConfig {
	@BundleInfoWrapper(key: "CFBundleShortVersionString")
	static var appVersion: String
	
	@BundleInfoWrapper(key: "CFBundleVersion")
	static var buildNumber: String
	
	@BundleInfoWrapper(key: "CFBundleIdentifier")
	static var bundleIdentifier: String
	
	@BundleInfoWrapper(key: "CFBundleDisplayName")
	static var appName: String
}
