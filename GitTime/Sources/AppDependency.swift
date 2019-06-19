//
//  AppDependency.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import Firebase
import Kingfisher
import RxCocoa
import RxDataSources
import RxFlow
import RxOptional
import RxSwift
import SwiftyBeaver

let log = SwiftyBeaver.self

final class AppDependency {
    
    static let shared = AppDependency()
    var window: UIWindow!
    
    // MARK: Properties
    
    let disposeBag = DisposeBag()
    var coordinator = FlowCoordinator()
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
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
        
        #endif
    }
    
    // MARK: - Public
    
    func configureCoordinator(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        self.coordinator.rx.willNavigate.subscribe(onNext: { (flow, step) in
//            log.debug("will navigate to flow=\(flow) and step=\(step)")
//        }).disposed(by: self.disposeBag)
//
//        self.coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
//            log.debug("did navigate to flow=\(flow) and step=\(step)")
//        }).disposed(by: self.disposeBag)
//
//        let appFlow = AppFlow(keychainService: KeychainService())
//
//        Flows.whenReady(flow1: appFlow) { root in
//            window.rootViewController = root
//            window.makeKeyAndVisible()
//        }
//
//        self.coordinator.coordinate(flow: appFlow)
//        self.coordinator.coordinate(flow: appFlow,
//                                    with: AppStepper(withServices: self.appServices))
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        let keychainService = KeychainService()
        let userDefaultsService = UserDefaultsService()
        let authService = AuthService(keychainService: keychainService)
        let userService = UserService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let followService = FollowService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let appStoreService = AppStoreService(networking: GitTimeProvider<AppStoreAPI>())
        let activityService = ActivityService(networking: GitTimeProvider<GitHubAPI>(plugins: [AuthPlugin(keychainService: keychainService)]))
        let crawlerService = GitTimeCrawlerService(networking: GitTimeProvider<GitTimeCrawlerAPI>())
        
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
            activityVC.title = "활동"
            activityVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.activity)
            activityVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.activityFilled)
            
            let trendReactor = TrendViewReactor(crawlerService: crawlerService,
                                                userdefaultsService: userDefaultsService)
            let trendVC = TrendViewController.instantiate(withReactor: trendReactor)
            trendVC.title = "트렌드"
            trendVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.trending)
            trendVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.trendingFilled)
            
            let followReactor = FollowViewReactor(followService: followService,
                                                  userService: userService)
            let followVC = FollowViewController.instantiate(withReactor: followReactor)
            followVC.title = "팔로우"
            followVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.follow)
            followVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.followFilled)
            
            let settingReactor = SettingViewReactor(userService: userService,
                                                    authService: authService,
                                                    appStoreService: appStoreService)
            let settingVC = SettingViewController.instantiate(withReactor: settingReactor)
            settingVC.title = "설정"
            settingVC.tabBarItem.image = UIImage.assetImage(name: TabBarImages.setting)
            settingVC.tabBarItem.selectedImage = UIImage.assetImage(name: TabBarImages.settingFilled)
            
            tabBarVC.viewControllers = [
                activityVC.navigationWrap(),
                trendVC.navigationWrap(),
                followVC.navigationWrap(),
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
