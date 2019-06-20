//
//  SplashViewReactor.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxFlow
import RxSwift

final class SplashViewReactor: Reactor {
    
    enum Action {
        case checkAuthentication
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setAuthentication(Bool)
    }
    
    struct State {
        var isLoading: Bool = true
        var isAutheticated: Bool?
    }

    let initialState = State()
    
    fileprivate let keychainService: KeychainServiceType
    fileprivate let userService: UserServiceType
    
    init(keychainService: KeychainServiceType,
         userService: UserServiceType) {
        self.keychainService = keychainService
        self.userService = userService
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkAuthentication:
            guard keychainService.getAccessToken() != nil else {
                return .just(.setAuthentication(false))
            }
            return self.userService.fetchMe()
                .map { true }
                .catchErrorJustReturn(false)
                .map(Mutation.setAuthentication)
        }
    }

    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
        case let .setAuthentication(isAutheticated):
            state.isAutheticated = isAutheticated
            return state
        }
    }
}
