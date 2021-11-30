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
import Pure
import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import SwiftyBeaver
import Toaster
import URLNavigator

let log = SwiftyBeaver.self

struct AppDependency {
	let window: UIWindow
	let configureSDKs: () -> Void
	let configureAppearance: () -> Void
}

final class CompositionRoot {
	static func resolve(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> AppDependency {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.backgroundColor = .white
		window.makeKeyAndVisible()
		
		// Navigator
		// let navigator = Navigator()
		
		// Services
		let keychainService = KeychainService()
		let authService = AuthService(keychainService: keychainService)
		let userService = UserService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
		 let followService = FollowService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
		// let appStoreService = AppStoreService(networking: GitTimeProvider<AppStoreAPI>())
		let activityService = ActivityService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
		let crawlerService = GitTimeCrawlerService(networking: GitTimeProvider<GitTimeCrawlerAPI>())
		// let searchService = SearchService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
		let realmService = RealmService()
		realmService.migration()
		
		let languageService = LanguagesService()
		let gitHubService = GitHubService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
		let userDefaultService = UserDefaultsService()
		
		// First Launch
		let firstLaunch: Bool = UserDefaultsConfig.firstLaunch
		if firstLaunch {
			try? keychainService.removeAccessToken()
			UserDefaultsConfig.firstLaunch = false
		}
		
		UserDefaultsConfig.didEnterBackgroundTime = nil
		
		var goToMainScreen: (() -> Void)!
		var goToLoginScreen: (() -> Void)!
		
		goToMainScreen = {
			let tabBarReactor = MainTabBarReactor()
			let tabBarController = MainTabBarController(reactor: tabBarReactor,
														launchOptions: launchOptions)
			
			let activityController = configureActivityScreen(activityService: activityService,
															 userService: userService,
															 crawlerService: crawlerService)
			
			let trendController = configureTrendingScreen(crawlerService: crawlerService,
														  languagesService: languageService,
														  userDefaultService: userDefaultService,
														  realmService: realmService)
			
			let buddyController = configureBuddyScreen(crawlerService: crawlerService,
													   realmService: realmService,
													   userDefaultService: userDefaultService,
													   followService: followService,
													   userService: userService,
													   githubService: gitHubService)
			
			let settingController = configureSettingScreen(authService: authService,
														   githubService: gitHubService,
														   presentLoginScreen: goToLoginScreen)
			
			tabBarController.viewControllers = [
				activityController.navigationWrap(),
				trendController.navigationWrap(),
				buddyController.navigationWrap(),
				settingController.navigationWrap()
			]
			window.rootViewController = tabBarController
		}
		
		goToLoginScreen = {
			let loginReactor = LoginViewReactor(authService: authService,
												keychainService: keychainService,
												userService: userService)
			let loginVC = LoginViewController(reactor: loginReactor,
											  goToMainScreen: goToMainScreen)
			
			window.rootViewController = loginVC
		}
		
		let splashReactor = SplashViewReactor(keychainService: keychainService,
											  userService: userService)
		let splashVC = SplashViewController(reactor: splashReactor,
											goToLoginScreen: goToLoginScreen,
											goToMainScreen: goToMainScreen)
		splashVC.goToLogin = goToLoginScreen
		splashVC.goToMain = goToMainScreen
		
		window.rootViewController = splashVC
		
		return AppDependency(window: window,
							 configureSDKs: self.configureSDKs,
							 configureAppearance: self.configureAppearance)
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
		
		let cache = ImageCache.default
		cache.clearCache()
		
		#endif
	}
	
	// MARK: Configure Appearance
	static func configureAppearance() {
		
//		let navigationAppearance = UINavigationBarAppearance()
//		navigationAppearance.configureWithOpaqueBackground()
//		navigationAppearance.backgroundColor = .red
//		UINavigationBar.appearance().standardAppearance = navigationAppearance
		
		// Toaster
		let toastAppearance = ToastView.appearance()
		toastAppearance.bottomOffsetPortrait = 30.0
		toastAppearance.textColor = .invertTitle
		toastAppearance.backgroundColor = .invertBackground
	}
}

extension CompositionRoot {
	// MARK: - Activity
	static func configureActivityScreen(
		activityService: ActivityServiceType,
		userService: UserServiceType,
		crawlerService: GitTimeCrawlerServiceType
	) -> ActivityViewController {
		let reactor = ActivityViewReactor(activityService: activityService,
										  userService: userService,
										  crawlerService: crawlerService)
		let controller = ActivityViewController(reactor: reactor)
		controller.title = "Activity"
		controller.tabBarItem.title = "Activity"
		controller.tabBarItem.image = UIImage.assetImage(name: TabBarImages.activity)
		controller.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.activityFilled)
		return controller
	}
	
	// MARK: - Follow
	static func configureFollowScreen(followService: FollowServiceType, userService: UserServiceType) -> FollowViewController {
		let reactor = FollowViewReactor(followService: followService, userService: userService)
		let controller = FollowViewController(reactor: reactor)
		controller.title = "Follow"
		controller.tabBarItem.title = "Follow"
		controller.tabBarItem.image = UIImage.assetImage(name: TabBarImages.follow)
		controller.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.followFilled)
		return controller
	}
	
	// MARK: - Setting
	static func configureSettingScreen(
		authService: AuthServiceType,
		githubService: GitHubServiceType,
		presentLoginScreen: @escaping () -> Void
	) -> SettingViewController {
		
		// 앱아이콘 변경
		var pushAppIconScreen: () -> AppIconsViewController
		pushAppIconScreen = {
			let reactor = AppIconsViewReactor()
			let controller = AppIconsViewController(reactor: reactor)
			return controller
		}
		
		// 컨트리뷰터
		var pushContributorsScreen: () -> ContributorsViewController
		pushContributorsScreen = {
			let reactor = ContributorsViewReactor(gitHubService: githubService)
			let controller = ContributorsViewController(reactor: reactor)
			return controller
		}
		
		let reactor = SettingViewReactor(authService: authService)
		let controller = SettingViewController(reactor: reactor,
											   presentLoginScreen: presentLoginScreen,
											   pushAppIconScreen: pushAppIconScreen,
											   pushContributorsScreen: pushContributorsScreen)
		controller.title = "Settings"
		controller.tabBarItem.title = "Settings"
		controller.tabBarItem.image = UIImage.assetImage(name: TabBarImages.setting)
		controller.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.settingFilled)
		return controller
	}
	
	// MARK: - Buddy
	static func configureBuddyScreen(
		crawlerService: GitTimeCrawlerServiceType,
		realmService: RealmServiceType,
		userDefaultService: UserDefaultsServiceType,
		followService: FollowServiceType,
		userService: UserServiceType,
		githubService: GitHubServiceType
	) -> BuddyViewController {
		
		var presentFollowScreen: () -> FollowViewController
		presentFollowScreen = {
			let reactor = FollowViewReactor(followService: followService,
											userService: userService)
			let controller = FollowViewController(reactor: reactor)
			return controller
		}
		
		let reactor = BuddyViewReactor(crawlerService: crawlerService,
									   realmService: realmService,
									   userDefaultService: userDefaultService,
									   githubService: githubService)
		let controller = BuddyViewController(reactor: reactor,
											 presentFollowScreen: presentFollowScreen)
		controller.title = "Buddys"
		controller.tabBarItem.title = "Buddys"
		controller.tabBarItem.image = UIImage.assetImage(name: TabBarImages.follow)
		controller.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.followFilled)
		return controller
	}
	
	// MARK: - Trending
	static func configureTrendingScreen(
		crawlerService: GitTimeCrawlerServiceType,
		languagesService: LanguagesServiceType,
		userDefaultService: UserDefaultsServiceType,
		realmService: RealmServiceType
	) -> TrendViewController {
		
		var presentLanguageScreen: () -> LanguageListViewController
		presentLanguageScreen = {
			let reactor = LanguageListViewReactor(languagesService: languagesService,
											   userDefaultsService: userDefaultService,
											   realmService: realmService)
			return LanguageListViewController(reactor: reactor)
		}
		
		var presentFavoriteScreen: () -> FavoriteLanguageViewController
		presentFavoriteScreen = {
			let reactor = FavoriteLanguageViewReactor(realmService: realmService)
			return FavoriteLanguageViewController(reactor: reactor)
		}
		
		let userdefaultsService = UserDefaultsService()
		let reactor = TrendViewReactor(crawlerService: crawlerService,
									   userdefaultsService: userdefaultsService)
		let controller = TrendViewController(reactor: reactor,
											 presentLanguageScreen: presentLanguageScreen,
											 presentFavoriteScreen: presentFavoriteScreen)
		controller.title = "Trending"
		controller.tabBarItem.title = "Trending"
		controller.tabBarItem.image = UIImage.assetImage(name: TabBarImages.trending)
		controller.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.trendingFilled)
		return controller
	}
	
}
