//
//  AppFlow.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

class AppFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
//    private lazy var rootViewController: SplashViewController = {
//        let reactor = SplashViewReactor(keychainService: KeychainService())
//        let splashVC = SplashViewController.instantiate(withReactor: reactor)
//        return splashVC
//    }()
    private lazy var rootViewController: UIViewController = {
        let viewController = UIViewController()
        return viewController
    }()
    
    private let keyChainServices: KeychainServiceType
    
    init(keychainService: KeychainServiceType) {
        self.keyChainServices = keychainService
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? GitTimeStep else { return .none }
        switch step {
        case .goToSplash:
            return navigationToSplashScreen()
        case .tokenRevoked:
            return navigationToLoginScreen()
        default:
            return .none
        }
    }
    
    private func navigationToSplashScreen() -> FlowContributors {

//        let reactor = SplashViewReactor()
//        let splashVC = SplashViewController(reactor: reactor,
//                                            service: self.services)
//        splashVC.reactor = reactor
//        return .one(flowContributor: .contribute(withNextPresentable: splashVC, withNextStepper: splashVC))
//        let splashFlow = SplashFlow(services: self.services)
//
//        Flows.whenReady(flow1: splashFlow) { [weak self] root in
//            guard let self = self else { return }
//            self.rootViewController.pushViewController(root, animated: true)
//        }
//
//        return .one(flowContributor: .contribute(withNextPresentable: splashFlow,
//                                                 withNextStepper: OneStepper(withSingleStep: GitTimeStep.goToSplash)))
        return .none
    }
    
    private func navigationToLoginScreen() -> FlowContributors {
        return .none
    }
}
