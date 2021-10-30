//
//  AppDelegate.swift
//  GitTime
//
//  Created by Kanz on 09/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	var dependency: AppDependency!
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.dependency = self.dependency ?? CompositionRoot.resolve(launchOptions: launchOptions)
		self.dependency.configureSDKs()
		self.dependency.configureAppearance()
		self.window = self.dependency.window
		return true
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		UserDefaultsConfig.didEnterBackgroundTime = Date()
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		if let didEnterBackgroundTime = UserDefaultsConfig.didEnterBackgroundTime {
			if didEnterBackgroundTime.anHourAfater() == true {
				NotificationCenter.default.post(name: .backgroundRefresh, object: nil)
			}
		}
		
		UserDefaultsConfig.didEnterBackgroundTime = nil
	}
}
