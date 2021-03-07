//
//  LanguageCategoryViewReactor.swift
//  GitTime
//
//  Created Kanz on 2021/02/10.
//  Copyright © 2021 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class LanguageCategoryViewReactor: Reactor {
    
    enum Action {
		case selectCategory(LanguageTypes)
    }
    
    enum Mutation {
		case setCategory(LanguageTypes)
    }
    
    struct State {
		var languageCategoryType: LanguageTypes
    }
    
	let initialState: State
    
	init(languageCategoryType: LanguageTypes) {
		self.initialState = State(languageCategoryType: languageCategoryType)
	}
	
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
		case .selectCategory(let category):
			return .just(.setCategory(category))
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
		case .setCategory(let category):
			state.languageCategoryType = category
        }
        return state
    }
}
