//
//  LoginViewReactor.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import FirebaseRemoteConfig
import ReactorKit
import RxCocoa
import RxSwift

final class LoginViewReactor: Reactor {
    
    enum Action {
        case login
        case trial
        // case checkTestMode(Bool)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoggedIn(Bool)
        // case setLoginTestMode(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLoggedIn: Bool = false
        // var isTestLoginMode: Bool = false
    }
    
    let initialState = State()
    
    fileprivate let authService: AuthServiceType
    fileprivate let keychainService: KeychainServiceType
    fileprivate let userService: UserServiceType
    var remoteConfig: RemoteConfig!
    
    init(authService: AuthServiceType,
         keychainService: KeychainServiceType,
         userService: UserServiceType) {
        self.authService = authService
        self.keychainService = keychainService
        self.userService = userService
        // self.connectRemoteConfig()
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
//        case .checkTestMode(let isTestMode):
//            return .just(.setLoginTestMode(isTestMode))
        case .login:
            GitTimeAnalytics.shared.logEvent(key: "login", parameters: nil)
            let startLoading: Observable<Mutation> = .just(Mutation.setLoading(true))
            let endLoading: Observable<Mutation> = .just(Mutation.setLoading(false))
            let setLoggedIn: Observable<Mutation> = self.getAccessToken()
                .do(onNext: { accessToken in
                    log.debug(accessToken)
                    let token = accessToken.accessToken
                    try? self.keychainService.setAccessToken(token)
                })
                .flatMap { _ in self.userService.fetchMe() }
                .map { _ in true }
                .catchError({ error -> Observable<Bool> in
                    log.error(error.localizedDescription)
                    try? self.keychainService.removeAccessToken()
                    return Observable.just(false)
                })
                .map(Mutation.setLoggedIn)
            return .concat([startLoading, setLoggedIn, endLoading])
        case .trial:
            GitTimeAnalytics.shared.logEvent(key: "trial", parameters: nil)
			// AppDependency.shared.isTrial = true
			GlobalStates.shared.isTrial.accept(true)
            return .just(.setLoggedIn(true))
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state 
        switch mutation {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setLoggedIn(let isLoggedIn):
            state.isLoggedIn = isLoggedIn
//        case .setLoginTestMode(let isTestMode):
//            state.isTestLoginMode = isTestMode
        }
        return state
    }
    
    private func testLogin() -> Observable<GitHubAccessToken> {
        return Observable.just(GitHubAccessToken.devAccessToken()) 
    }
    /*
    private func connectRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
            let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        remoteConfig.fetchAndActivate { [weak self] (status, error) in
            guard let self = self else { return }
            if let error = error {
                log.error(error.localizedDescription)
                self.action.onNext(.checkTestMode(false))
            } else if status == .successFetchedFromRemote {
                let isTestMode = self.remoteConfig["review_version"].stringValue == AppInfo.shared.appVersion
                log.debug("isTestMode: \(isTestMode)")
                self.action.onNext(.checkTestMode(isTestMode))
            }
        }
    }
    */
    private func getAccessToken() -> Observable<GitHubAccessToken> {
//        guard !self.currentState.isTestLoginMode else {
//            return self.testLogin()
//        }
        
        return self.authService.authorize()
            .flatMap { code in self.authService.requestAccessToken(code: code) }
    }
}
