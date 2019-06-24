//
//  TrendViewReactor.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class TrendViewReactor: Reactor {

    enum Action {
        case refresh
        case selectPeriod(PeriodTypes)
//        case selectLanguage(String?)
        case selectLanguage(Language?)
        case switchSegmentControl
        case requestTrending
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setPeriod(PeriodTypes)
//        case setLanguage(String?)
        case setLanguage(Language?)
        case setTrendType(TrendTypes)
        case fetchRepositories([TrendRepo])
        case fetchDevelopers([TrendDeveloper])
    }
    
    struct State {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var period: PeriodTypes
//        var language: String?
        var language: Language?
        var trendingType: TrendTypes
        var repositories: [TrendSectionItem] = []
        var developers: [TrendSectionItem] = []
        var trendSections: [TrendSection] {
            switch self.trendingType {
            case .repositories:
                guard !self.repositories.isEmpty else {
                    let reactor = EmptyTableViewCellReactor(type: .trendingRepo)
                    return [.repo([TrendSectionItem.empty(reactor)])]
                }
                return [.repo(self.repositories)]
            case .developers:
                guard !self.repositories.isEmpty else {
                    let reactor = EmptyTableViewCellReactor(type: .trendingDeveloper)
                    return [.repo([TrendSectionItem.empty(reactor)])]
                }
                return [.developer(self.developers)]
            }
        }
    }
    
    let initialState: TrendViewReactor.State
    
    fileprivate let crawlerService: GitTimeCrawlerServiceType
    fileprivate let userdefaultsService: UserDefaultsServiceType
    
    init(crawlerService: GitTimeCrawlerServiceType,
         userdefaultsService: UserDefaultsServiceType) {
        self.crawlerService = crawlerService
        self.userdefaultsService = userdefaultsService
        let period: PeriodTypes = PeriodTypes(rawValue: userdefaultsService.value(forKey: UserDefaultsKey.period) ?? "") ?? PeriodTypes.daily
        let language: Language? = userdefaultsService.structValue(forKey: UserDefaultsKey.langauge)
        self.initialState = State(isLoading: false,
                                  isRefreshing: false,
                                  period: period,
                                  language: language,
                                  trendingType: .repositories,
                                  repositories: [],
                                  developers: [])
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            guard !self.currentState.isRefreshing else { return .empty() }
            let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
            let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
            let requestMutation = self.requestTrending()
            return .concat([startRefreshing, endRefreshing.delay(0.5, scheduler: MainScheduler.instance), requestMutation])
        case .selectPeriod(let period):
            self.userdefaultsService.set(value: period.querySting(),
                                         forKey: UserDefaultsKey.period)
            let periodMutation: Observable<Mutation> = .just(.setPeriod(period))
            let requestMutation = self.requestTrending(period: period)
            return .concat([periodMutation, requestMutation])
        case .selectLanguage(let language):
            // self.userdefaultsService.set(value: language, forKey: UserDefaultsKey.langauge)
            self.userdefaultsService.setStruct(value: language, forKey: UserDefaultsKey.langauge)
            let languageMutation: Observable<Mutation> = .just(.setLanguage(language))
            let requestMutation = self.requestTrending(language: language)
            return .concat([languageMutation, requestMutation])
        case .switchSegmentControl:
            let trendType = self.currentState.trendingType == .repositories ? TrendTypes.developers : TrendTypes.repositories
            let trendMutation: Observable<Mutation> = .just(.setTrendType(trendType))
            let requestMutation: Observable<Mutation> = self.requestTrending(trendType: trendType)
            return .concat([trendMutation, requestMutation])
        case .requestTrending:
            let requestMutation = self.requestTrending()
            return requestMutation
        }
        
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
        case let .setPeriod(period):
            state.period = period
        case let .setLanguage(language):
            state.language = language
        case let .setTrendType(trendType):
            state.trendingType = trendType
        case let .fetchRepositories(repos):
            state.repositories = repos
                .map({ repo -> TrendingRepositoryCellReactor in
                    return TrendingRepositoryCellReactor.init(repo: repo, period: state.period)
                })
                .map(TrendSectionItem.trendingRepos)
        case let .fetchDevelopers(developers):
            state.developers = developers.map({ developer -> TrendingDeveloperCellReactor in
                    return TrendingDeveloperCellReactor(developer: developer, rank: 0)
                })
                .map(TrendSectionItem.trendingDevelopers)
        }
        
        return state
    }
    
    fileprivate func requestTrending(trendType: TrendTypes? = nil,
                                     period: PeriodTypes? = nil,
                                     language: Language? = nil) -> Observable<Mutation> {
        let currentTrendType = trendType ?? self.currentState.trendingType
        let currentPeriod = period ?? self.currentState.period
        
        let currentLanguage = language ?? self.currentState.language
        let currentLanguageName = currentLanguage?.type == LanguageTypes.all ? "" : currentLanguage?.name
 
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        switch currentTrendType {
        case .repositories:
            let fetchRepositories: Observable<Mutation>
                = self.crawlerService.fetchTrendingRepositories(language: currentLanguageName,
                                                                 period: currentPeriod.querySting())
                    .map { list -> Mutation in
                        return .fetchRepositories(list)
                    }.catchErrorJustReturn(.fetchRepositories([]))
            
            return .concat([startLoading, fetchRepositories, endLoading])
        case .developers:
            let fetchDevelopers: Observable<Mutation>
                = self.crawlerService.fetchTrendingDevelopers(language: currentLanguageName,
                                                               period: currentPeriod.querySting())
                    .map { developers -> Mutation in
                        return .fetchDevelopers(developers)
                    }.catchErrorJustReturn(.fetchDevelopers([]))
            
            return .concat([startLoading, fetchDevelopers, endLoading])
        }
    }
}
