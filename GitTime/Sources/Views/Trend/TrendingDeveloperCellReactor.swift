//
//  TrendingDeveloperCellReactor.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class TrendingDeveloperCellReactor: Reactor {
    
    enum Action {
        case initRank(Int)
    }
    
    enum Mutation {
        case setRank(Int)
    }
    
    struct State {
        var rank: Int
        var profileURL: String
        var name: String
        var userName: String?
        var repoName: String
        var repoDescription: String?
        var url: String
		var popularRepoURL: String
    }
    
    let initialState: State
    
    init(developer: TrendDeveloper, rank: Int) {
        self.initialState = State(rank: rank,
                                  profileURL: developer.profileURL,
                                  name: developer.name ?? "",
                                  userName: developer.userName,
                                  repoName: developer.repo.name ?? "",
                                  repoDescription: developer.repo.description,
                                  url: developer.url,
								  popularRepoURL: developer.repo.url)
        _ = self.state
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initRank(let rank):
            return .just(.setRank(rank))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setRank(let rank):
            state.rank = rank + 1
        }
        return state
    }
    
}
