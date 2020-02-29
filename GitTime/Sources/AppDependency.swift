//
//  AppDependency.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
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

final class AppDependency {
    
    static let shared = AppDependency()
    var window: UIWindow!
    
    // MARK: Properties
    
    let disposeBag = DisposeBag()
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var isTrial: Bool = false
    
    init() {
        configureSDKs()
    }
    
    // MARK: - Private
    
    private func configureSDKs() {
        
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
        
        // Toaster
        let toastAppearance = ToastView.appearance()
        toastAppearance.bottomOffsetPortrait = 30.0
        toastAppearance.textColor = .invertTitle
        toastAppearance.backgroundColor = .invertBackground
    }
    
    // MARK: - Public
    
    func configureCoordinator(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow) {
        
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window.backgroundColor = .white
//        window.makeKeyAndVisible()
        self.window = window
        
        let keychainService = KeychainService()
        let userDefaultsService = UserDefaultsService()
        let authService = AuthService(keychainService: keychainService)
        let userService = UserService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let followService = FollowService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let appStoreService = AppStoreService(networking: GitTimeProvider<AppStoreAPI>())
        let activityService = ActivityService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let crawlerService = GitTimeCrawlerService(networking: GitTimeProvider<GitTimeCrawlerAPI>())
        let searchService = SearchService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let realmService = RealmService()
        let languageService = LanguagesService()
        
        let firstLaunch: Bool = userDefaultsService.value(forKey: UserDefaultsKey.firstLaunch) ?? true
        if firstLaunch {
            try? keychainService.removeAccessToken()
            userDefaultsService.set(value: false, forKey: UserDefaultsKey.firstLaunch)
        }
        
        let goToMain: GoToMainFunction = {
            let tabBarReactor = MainTabBarReactor()
            let tabBarVC = MainTabBarController(reactor: tabBarReactor, launchOptions: launchOptions)
            
            let activityReactor = ActivityViewReactor(activityService: activityService,
                                                      userService: userService,
                                                      crawlerService: crawlerService)
            let activityVC = ActivityViewController.instantiate(withReactor: activityReactor)
            activityVC.title = "Activity"
            activityVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.activity)
            activityVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.activityFilled)
            
            let trendReactor = TrendViewReactor(crawlerService: crawlerService,
                                                userdefaultsService: userDefaultsService)
            let trendVC = TrendViewController.instantiate(withReactor: trendReactor)
            trendVC.title = "Trending"
            trendVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.trending)
            trendVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.trendingFilled)
            
            let followReactor = FollowViewReactor(followService: followService,
                                                  userService: userService)
            let followVC = FollowViewController.instantiate(withReactor: followReactor)
            followVC.title = "Follow"
            followVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.follow)
            followVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.followFilled)
            
            let searchReactor = SearchViewReactor(searchService: searchService,
                                                  languageService: languageService,
                                                  realmService: realmService,
                                                  userdefaultsService: userDefaultsService)
            
            let searchVC = SearchViewController.instantiate(withReactor: searchReactor)
            searchVC.title = "Search"
            searchVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.search)
            searchVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.search)
            
            let settingReactor = SettingViewReactor(userService: userService,
                                                    authService: authService,
                                                    appStoreService: appStoreService)
            let settingVC = SettingViewController.instantiate(withReactor: settingReactor)
            settingVC.title = "Setting"
            settingVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.setting)
            settingVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.settingFilled)
            
            tabBarVC.viewControllers = [
                activityVC.navigationWrap(),
                trendVC.navigationWrap(),
                followVC.navigationWrap(),
                searchVC.navigationWrap(),
                settingVC.navigationWrap()
            ]
            self.window.rootViewController = tabBarVC
            self.window.makeKeyAndVisible()
        }
        
        let goToLogin: GoToLoginFunction = {
            let loginReactor = LoginViewReactor(authService: authService,
                                                keychainService: keychainService,
                                                userService: userService)
            let loginVC = LoginViewController.instantiate(withReactor: loginReactor)
            loginVC.goToMain = goToMain
            self.window.rootViewController = loginVC
            self.window.makeKeyAndVisible()
        }
        
        let splashReactor = SplashViewReactor(keychainService: keychainService,
                                              userService: userService)
        let splashVC = SplashViewController.instantiate(withReactor: splashReactor)
        splashVC.goToLogin = goToLogin
        splashVC.goToMain = goToMain
        
        window.rootViewController = splashVC
    }
}
