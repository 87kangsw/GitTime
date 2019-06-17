//
//  LoginViewReactor.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class LoginViewReactor: Reactor {
    
    enum Action {
        case login
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoggedIn(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLoggedIn: Bool = false
    }
    
    let initialState = State()
    
    fileprivate let authService: AuthServiceType
    fileprivate let keychainService: KeychainServiceType
    fileprivate let userService: UserServiceType
    init(authService: AuthServiceType,
         keychainService: KeychainServiceType,
         userService: UserServiceType) {
        self.authService = authService
        self.keychainService = keychainService
        self.userService = userService
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .login:
            let startLoading: Observable<Mutation> = .just(Mutation.setLoading(true))
            let endLoading: Observable<Mutation> = .just(Mutation.setLoading(false))
            let setLoggedIn: Observable<Mutation> = self.authService.authorize()
                .flatMap { code in self.authService.requestAccessToken(code: code) }
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
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state 
        switch mutation {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            return state
        case .setLoggedIn(let isLoggedIn):
            state.isLoggedIn = isLoggedIn
            return state
        }
    }
}
