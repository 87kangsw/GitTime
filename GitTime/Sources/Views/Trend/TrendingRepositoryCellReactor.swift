//
//  TrendingRepositoryCellReactor.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class TrendingRepositoryCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var repoName: String
        var author: String
        var description: String
        var totalStars: Int
        var totalForks: Int
        var language: String?
        var languageColor: String?
        var period: PeriodTypes
        var periodStar: Int
        var url: String
    }
    
    let initialState: State
    
    init(repo: TrendRepo, period: PeriodTypes) {
        self.initialState = State(repoName: repo.name,
                                  author: repo.author,
                                  description: repo.description,
                                  totalStars: repo.stars,
                                  totalForks: repo.forks,
                                  language: repo.language,
                                  languageColor: repo.languageColor,
                                  period: period,
                                  periodStar: repo.currentPeriodStars,
                                  url: repo.url)
        _ = self.state
    }

}
