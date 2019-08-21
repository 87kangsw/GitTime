//
//  SettingViewReactor.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class SettingViewReactor: Reactor {
    
    enum Action {
        case logout
        case versionCheck
    }
    
    enum Mutation {
        case setLoggedOut
        case setVersion(String)
    }

    struct State {
        var isLoggedOut: Bool
        var pageURL: String
        var me: Me?
        var storeVersion: String
        var meSection: [SettingSection] {
            guard let me = self.me else { return [] }
            return [.aboutMe([.myProfile(SettingUserProfileCellReactor(me: me))])]
        }
        var logOutSection: [SettingSection] {
            return [.logout([.logout(SettingLogoutCellReactor())])]
        }
        var aboutAppSection: [SettingSection] {
            let version = self.storeVersion
            return [.aboutApp([
                .githubRepo(SettingItemCellReactor(title: "GitTime Repo", subTitle: "GitHub")),
                .acknowledgements(SettingItemCellReactor(title: "Open Source License", subTitle: nil)),
                .contact(SettingItemCellReactor(title: "Contact Email", subTitle: nil)),
                .rateApp(SettingItemCellReactor(title: "Rate App", subTitle: nil)),
                .version(SettingItemCellReactor(title: "App Version", subTitle: version))
                ])]
        }
        var settingSections: [SettingSection] {
            var sections: [SettingSection] = []
            sections += meSection
            sections += aboutAppSection
            sections += logOutSection
            return sections
        }
        
    }
    
    let initialState: State
    
    fileprivate let userService: UserServiceType
    fileprivate let authService: AuthServiceType
    fileprivate let appStoreService: AppStoreServiceType
    
    init(userService: UserServiceType,
         authService: AuthServiceType,
         appStoreService: AppStoreServiceType) {
        self.userService = userService
        self.authService = authService
        self.appStoreService = appStoreService
        
        let me = userService.me

        self.initialState = State(isLoggedOut: false,
                                  pageURL: me?.url ?? "" ,
                                  me: me,
                                  storeVersion: "")
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .logout:
            self.authService.logOut()
            return .just(.setLoggedOut)
        case .versionCheck:
            let versionMutation: Observable<Mutation> = self.appStoreService.getLatestVersion()
                .map { version -> Mutation in
                    let storeVersion = version.results[0].version
                    return .setVersion(storeVersion)
            }.catchErrorJustReturn(.setVersion("⚠️"))
            return versionMutation
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoggedOut:
            state.isLoggedOut = true
        case .setVersion(let version):
            state.storeVersion = version
        }
        return state
    }
    
    private func configureProfileSection() -> [SettingSectionItem] {
        guard let me = self.userService.me else { return [] }
        let reactor = SettingUserProfileCellReactor(me: me)
        return [.myProfile(reactor)]
    }
}
