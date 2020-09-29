//
//  CompositionRoot.swift
//  GitTime
//
//  Created by Kanz on 2020/09/29.
//

import UIKit

import Bagel
import Firebase
import Kingfisher
import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import SwiftyBeaver
import Toaster

let log = SwiftyBeaver.self

struct AppDependency {
//	typealias OpenURLHandler = (_ url: URL, _
//								options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
	
	let window: UIWindow
	let configureSDKs: () -> Void
	let configureAppearance: () -> Void
//	let openURL: OpenURLHandler
}

final class CompositionRoot {
	static func resolve() -> AppDependency {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.backgroundColor = .white
		window.makeKeyAndVisible()
		
		// Services
		let keychainService = KeychainService()
		
		// First Launch
		let firstLaunch: Bool = UserDefaultsConfig.firstLaunch
		if firstLaunch {
			try? keychainService.removeAccessToken()
			UserDefaultsConfig.firstLaunch = false
		}
		
		return AppDependency(window: window,
							 configureSDKs: self.configureSDKs,
							 configureAppearance: self.configureAppearance)
							 //openURL: <#T##AppDependency.OpenURLHandler##AppDependency.OpenURLHandler##(URL, [UIApplication.OpenURLOptionsKey : Any]) -> Bool#>)
	}
	
	// MARK: Configure SDKs
	static func configureSDKs() {
		
		// Firebase
		FirebaseApp.configure()
		
		#if DEBUG
		
		// SwiftyBeaver
		let console = ConsoleDestination()
		console.minLevel = .verbose
		log.addDestination(console)
		
		// Bagel
		Bagel.start()
		
		#endif
	}
	
	// MARK: Configure Appearance
	static func configureAppearance() {
		
		// Toaster
		let toastAppearance = ToastView.appearance()
		toastAppearance.bottomOffsetPortrait = 30.0
		toastAppearance.textColor = .invertTitle
		toastAppearance.backgroundColor = .invertBackground
	}
}
