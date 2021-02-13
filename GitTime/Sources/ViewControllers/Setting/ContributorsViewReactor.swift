//
//  ContributorsViewReactor.swift
//  GitTime
//
//  Created Kanz on 2020/10/27.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class ContributorsViewReactor: Reactor {
    
    enum Action {
        case firstLoad
    }
    
    enum Mutation {
		case setLoading(Bool)
        case setContributors([User])
    }
    
    struct State {
		var isLoading: Bool = false
		var contributors: [User] = []
		var sections: [ContributorSection] {
			return contributors.map { user -> ContributorCellReactor in
				return ContributorCellReactor(user: user)
			}
			.map(ContributorSectionItem.contributor)
			.map { sectionItem -> ContributorSection in
				ContributorSection.contributor([sectionItem])
			}
		}
    }
    
    let initialState: State
	private let gitHubService: GitHubServiceType
	
    // MARK: Initializing
    init(gitHubService: GitHubServiceType) {
		self.gitHubService = gitHubService
		
        initialState = State()
    }
    
	// MARK: Mutate
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .firstLoad:
			guard self.currentState.isLoading == false else { return .empty() }
			let startLoading: Observable<Mutation> = .just(.setLoading(true))
			let endLoading: Observable<Mutation> = .just(.setLoading(false))
			let request: Observable<Mutation> = self.requestContributors()
			return .concat(startLoading, request, endLoading)
		}
	}
	
	// MARK: Reduce
	
	func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case .setLoading(let isLoading):
			state.isLoading = isLoading
		case .setContributors(let contributors):
			state.contributors = contributors
		}
		return state
	}
	
	private func requestContributors() -> Observable<Mutation> {
		self.gitHubService.contributors()
			.map { users -> Mutation in
				return .setContributors(users)
			}.catchErrorJustReturn(.setContributors([]))
	}
}
