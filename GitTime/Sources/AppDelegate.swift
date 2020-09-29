//
//  AppDelegate.swift
//  GitTime
//
//  Created by Kanz on 09/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import RxSwift

class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	var dependency: AppDependency!
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.dependency = self.dependency ?? CompositionRoot.resolve()
		self.dependency.configureSDKs()
		self.dependency.configureAppearance()
		self.window = self.dependency.window
		return true
	}
	
}
