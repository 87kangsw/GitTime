//
//  SplashViewController.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import RxOptional

typealias GoToLoginFunction = () -> Void
typealias GoToMainFunction = () -> Void

class SplashViewController: BaseViewController, ReactorBased, StoryboardView {
    
    typealias Reactor = SplashViewReactor
    
    // MARK: - UI
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var goToLogin: GoToLoginFunction!
    var goToMain: GoToMainFunction!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Configure
    
    func bind(reactor: Reactor) {
        
        // Action
        self.rx.viewDidAppear
            .map { _ in Reactor.Action.checkAuthentication }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: self.loadingIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isAutheticated }
            .filterNil()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isAutheticated in
                guard let self = self else { return }
                if !isAutheticated {
                    self.goToLogin()
                } else {
                    self.goToMain()
                }
            }).disposed(by: self.disposeBag)
        
    }
}
