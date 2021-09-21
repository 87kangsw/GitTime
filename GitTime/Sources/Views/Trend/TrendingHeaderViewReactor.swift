//
//  TrendingHeaderViewReactor.swift
//  GitTime
//
//  Created Kanz on 2020/12/05.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class TrendingHeaderViewReactor: Reactor {
    
    enum Action {
		case selectPeriod(PeriodTypes)
		case selectLanguage(GithubLanguage?)
    }
    
    enum Mutation {
		case selectPeriod(PeriodTypes)
		case selectLanguage(GithubLanguage?)
    }
    
    struct State {
		var period: PeriodTypes
		var language: GithubLanguage?
		var trendingType: TrendTypes = .repositories
    }
    
	let initialState: State
	
	init(period: PeriodTypes, language: GithubLanguage?) {
		initialState = State(period: period,
							 language: language)
	}
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
		case .selectLanguage(let language):
			return .just(.selectLanguage(language))
		case .selectPeriod(let period):
			return .just(.selectPeriod(period))
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
		case .selectLanguage(let language):
			state.language = language
		case .selectPeriod(let period):
			state.period = period
        }
        return state
    }
}
