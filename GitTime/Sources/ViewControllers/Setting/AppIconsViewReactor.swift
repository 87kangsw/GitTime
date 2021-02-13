//
//  AppIconsViewReactor.swift
//  GitTime
//
//  Created Kanz on 2020/10/27.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class AppIconsViewReactor: Reactor {
	
	enum Action {
		case setSelectedAppIcon(String)
	}
	
	enum Mutation {
		case setSelectedAppIcon(String)
	}
	
	struct State {
		var sections: [AppIconSection] {
			let sectionItems: [AppIconSectionItem] = [
				AppIconCellReactor(icon: .white, selectedIcon: self.selectedAppIcon),
				AppIconCellReactor(icon: .black, selectedIcon: self.selectedAppIcon),
				AppIconCellReactor(icon: .original, selectedIcon: self.selectedAppIcon)
			].map(AppIconSectionItem.appIcon)
			
			return [.appIcon(sectionItems)]
		}
		var selectedAppIcon: String
	}
	
	let initialState: State
	
	// MARK: Initializing
	init() {
		initialState = State(selectedAppIcon: UserDefaultsConfig.appIconName)
	}
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .setSelectedAppIcon(let selectedAppIcon):
			return .just(.setSelectedAppIcon(selectedAppIcon))
		}
	}
	
	func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case .setSelectedAppIcon(let selectedAppIcon):
			state.selectedAppIcon = selectedAppIcon
		}
		return state
	}
}
