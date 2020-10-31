//
//  MainTabBarController.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import Pure
import ReactorKit
import RxCocoa
import RxSwift

final class MainTabBarController: UITabBarController, ReactorKit.View {
    
    lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    typealias Reactor = MainTabBarReactor
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    // MARK: - Initialize
    
    init(reactor: MainTabBarReactor,
		 launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        log.verbose("DEINIT: \(self.className)")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Layout Constraints
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        self.rx.didSelect
            .do(onNext: { viewController in
                let title = viewController.title ?? ""
                GitTimeAnalytics.shared.logEvent(key: "tab_select",
                                                 parameters: ["tab": title])
            })
            .scan((nil, nil)) { state, viewController in
                return (state.1, viewController)
            }
            // if select the view controller first time or select the same view controller again
            .filter { state in state.0 == nil || state.0 === state.1 }
            .map { state in state.1 }
            .filterNil()
            .subscribe(onNext: { [weak self] viewController in
                self?.scrollToTop(viewController) // scroll to top
            })
            .disposed(by: self.disposeBag)
    }
    
    func scrollToTop(_ viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            let topViewController = navigationController.topViewController
            let firstViewController = navigationController.viewControllers.first
            if let viewController = topViewController, topViewController === firstViewController {
                self.scrollToTop(viewController)
            }
            return
        }
        guard let scrollView = viewController.view.subviews.first as? UIScrollView else { return }
        scrollView.setContentOffset(.zero, animated: true)
    }
}
