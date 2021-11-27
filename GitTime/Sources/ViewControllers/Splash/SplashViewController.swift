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

class SplashViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = SplashViewReactor
    
    // MARK: - UI
	private let loadingIndicator = UIActivityIndicatorView().then {
		$0.color = .invertBackground
		$0.hidesWhenStopped = true
	}
		
	private let logoImageView = UIImageView().then {
		$0.image = UIImage(named: "logo")
//		$0.backgroundColor = .white
//		$0.isHidden = true
	}
	
    // MARK: - Properties
    var goToLogin: GoToLoginFunction!
    var goToMain: GoToMainFunction!
	
	// MARK: - Initializing
	init(
		reactor: Reactor,
		goToLoginScreen: @escaping () -> Void,
		goToMainScreen: @escaping () -> Void
	) {
		defer { self.reactor = reactor }
		self.goToLogin = goToLoginScreen
		self.goToMain = goToMainScreen
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .systemBackground
    }
    
    // MARK: - Configure
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(logoImageView)
		self.view.addSubview(loadingIndicator)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		logoImageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(UIScreen.main.bounds.width / 2.0)
			make.height.equalTo(UIScreen.main.bounds.width / 2.0)
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
    
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
