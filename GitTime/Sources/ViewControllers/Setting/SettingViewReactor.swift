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
		case reviewRequest
    }
    
    enum Mutation {
        case setLoggedOut
		case setIsShowReviewRequestAlert(Bool)
    }

    struct State {
        var isLoggedOut: Bool
        var me: Me?
//        var currentVersion: String
        
        var settingSections: [SettingSection] {
            var sections: [SettingSection] = []
			let preferenceSectionItems: [SettingSectionItem] = [
				.appIcon(SettingCellReactor(settingType: .appIcon))
			]
			
			let aboutSectionItems: [SettingSectionItem] = [
				.repo(SettingCellReactor(settingType: .repo)),
				.opensource(SettingCellReactor(settingType: .opensource)),
				.recommend(SettingCellReactor(settingType: .recommend)),
				.appReview(SettingCellReactor(settingType: .appReview))
			]
			
			let privacySectionItems: [SettingSectionItem] = [
				.privacy(SettingCellReactor(settingType: .privacy))
			]
			
			let authorSectionItems: [SettingSectionItem] = [
				.author(SettingCellReactor(settingType: .author)),
				.contributors(SettingCellReactor(settingType: .contributors)),
				.shareFeedback(SettingCellReactor(settingType: .shareFeedback))
			]
			
			let logoutSectionItem: [SettingSectionItem] = [
				.logout(SettingCellReactor(settingType: .logout))
			]
			
			sections += [.appPreference(preferenceSectionItems)]
			sections += [.about(aboutSectionItems)]
			sections += [.privacy(privacySectionItems)]
			sections += [.authors(authorSectionItems)]
			sections += [.logout(logoutSectionItem)]
				
            return sections
        }
        
		var isShowReviewRereuqestAlert: Bool = false
    }
    
    let initialState: State
    
    fileprivate let authService: AuthServiceType
    
    init(authService: AuthServiceType) {
        self.authService = authService

		self.initialState = State(isLoggedOut: false,
								  me: GlobalStates.shared.currentUser.value)
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .logout:
            self.authService.logOut()
            // AppDependency.shared.isTrial = false
			GlobalStates.shared.isTrial.accept(nil)
            return .just(.setLoggedOut)
			
		case .reviewRequest:
			return self.checkIfReviewRequestEnable()
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoggedOut:
            state.isLoggedOut = true
		case .setIsShowReviewRequestAlert(let isShow):
			state.isShowReviewRereuqestAlert = isShow
        }
        return state
    }
	
	private func checkIfReviewRequestEnable() -> Observable<Mutation> {
		var isShow: Bool = false
		
		var count = UserDefaultsConfig.processCompletedCountKey
		count += 1
		UserDefaultsConfig.processCompletedCountKey = count
		
		let currentVersion = BundleInfoConfig.appVersion
		let lastVersionPromptedForReview = UserDefaultsConfig.lastVersionPromptedForReviewKey
		
		if count >= 4 && currentVersion != lastVersionPromptedForReview {
			UserDefaultsConfig.lastVersionPromptedForReviewKey = currentVersion
			isShow = true
		}
		
		return .just(.setIsShowReviewRequestAlert(isShow))
	}
	
}
