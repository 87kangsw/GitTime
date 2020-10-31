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
	private let logoImageView = UIImageView().then {
		$0.image = UIImage(named: "logo")
	}
	
	let loginButton = UIButton().then {
		$0.setImage(UIImage(named: "github"), for: .normal)
		$0.setTitle("GitHub Login", for: .normal)
		$0.titleLabel?.font = .boldSystemFont(ofSize: 18.0)
		$0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0.0)
		$0.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
		$0.layer.cornerRadius = 8.0
		$0.layer.masksToBounds = true
		
		$0.backgroundColor = .loginButtonBackground
		$0.setTitleColor(.loginButtonTitle, for: .normal)
		$0.titleLabel?.adjustsFontSizeToFitWidth = true
	}
	
	let trialButton = UIButton().then {
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 13.0),
			.foregroundColor: UIColor.title,
			.underlineStyle: NSUnderlineStyle.single.rawValue
		]
		let attrString = NSAttributedString(string: "Trial",
											attributes: attributes)
		$0.setAttributedTitle(attrString, for: .normal)
	}
	
	private let loadingIndicator = UIActivityIndicatorView().then {
		$0.color = .invertBackground
		$0.hidesWhenStopped = true
	}
	
    // MARK: - Properties
    var goToMain: GoToMainFunction!
    
	// MARK: - Initializing
	init(reactor: Reactor,
		 goToMainScreen: @escaping () -> Void) {
		defer { self.reactor = reactor }
		self.goToMain = goToMainScreen
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(logoImageView)
		self.view.addSubview(loginButton)
		self.view.addSubview(trialButton)
		self.view.addSubview(loadingIndicator)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		logoImageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(UIScreen.main.bounds.width / 2.0)
			make.height.equalTo(UIScreen.main.bounds.width / 2.0)
		}
		
		loginButton.snp.makeConstraints { make in
			make.width.equalTo(UIScreen.main.bounds.width / 2.0)
			make.bottom.equalTo(-100.0)
			make.centerX.equalToSuperview()
			make.height.equalTo(60.0)
		}
		
		trialButton.snp.makeConstraints { make in
			make.width.equalTo(60.0)
			make.top.equalTo(loginButton.snp.bottom).offset(30.0)
			make.centerX.equalToSuperview()
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
	
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        loginButton.rx.tap
            .map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        trialButton.rx.tap
            .map { Reactor.Action.trial }
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
