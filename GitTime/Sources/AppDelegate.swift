//
//  AppDelegate.swift
//  GitTime
//
//  Created by Kanz on 09/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import RxFlow
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppDependency.shared.configureCoordinator(launchOptions: launchOptions)
        return true
    }

}
