//
//  LoginViewController.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import AuthenticationServices
import UIKit

import ReactorKit

class LoginViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = LoginViewReactor
    
    // MARK: - UI
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Properties
    var goToMain: GoToMainFunction!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        loginButton.backgroundColor = .loginButtonBackground
        loginButton.setTitleColor(.loginButtonTitle, for: .normal)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .invertBackground
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        loginButton.rx.tap
            .map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isLoggedIn }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.goToMain()
            }).disposed(by: self.disposeBag)
    }
}
 
// MARK: - ASWebAuthenticationPresentationContextProviding
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
