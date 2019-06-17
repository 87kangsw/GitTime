//
//  SettingItemCellReactor.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class SettingItemCellReactor: Reactor {
    
    typealias Action = NoAction
//    enum Action {
//        case versionCheck
//    }
//
//    enum Mutation {
//        case setVersion(String)
//    }
    
    struct State {
//        var isAppVersionCell: Bool
        var title: String?
        var subTitle: String?
    }
    
    let initialState: State
    
//    fileprivate let appStoreService: AppStoreServiceType?
    
    init(title: String?, subTitle: String?) {
//        self.appStoreService = appStoreService
        self.initialState = State(title: title,
                                  subTitle: subTitle)
        _ = self.state
    }
/*
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .versionCheck:
            guard let appStoreService = self.appStoreService, self.currentState.subTitle == nil else { return .empty() }
            let versionMutation: Observable<Mutation> = appStoreService.getLatestVersion()
                .debug()
                .map { version -> Mutation in
                    let storeVersion = version.result.version
                    return .setVersion(storeVersion)
                }.catchErrorJustReturn(.setVersion("-"))
            return versionMutation
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state 
        switch mutation {
        case .setVersion(let version):
            state.subTitle = version
        }
        return state
    }
 */
}
